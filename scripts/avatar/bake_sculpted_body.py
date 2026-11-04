"""Bake the sculpted neutral body (ADR-010) from NAVER Anny into a small on-device basis.

Offline tool. Runs once on a developer Mac; nothing here ships in the app except its output files.
The app never runs Anny, PyTorch or any network code: it only mixes the baked shapes below.

Pipeline (every step is linear in the vertex positions, so mixing baked shapes on the phone matches
what Anny itself would produce up to the small pose/phenotype cross-terms reported at the end):

1. Anny (Apache-2.0 code, MakeHuman/MPFB2 CC0 assets), default `anny` topology only. The optional
   `smplx`/`smpl` topologies are non-commercial and are never loaded.
2. One neutral phenotype (gender 0.5, young adult) — no gendered or ethnic shaping is ever applied.
3. Arms lowered from the rest A-pose to hang beside the body (fixed pose for every shape).
4. Eye, mouth and tongue cavities removed, the openings closed, then the head smoothed into a
   faceless mannequin head (v1.5 §108.3: covered, faceless, no anatomical detail).
5. One-sided shape bases: MakeHuman measurement targets (shoulder, bust, waist, hips) and the
   weight phenotype. Their effect on four tape measurements gives a Jacobian the app solves with.

Usage (from the repo root, with a venv that has `pip install ./vendor/anny`):
    ANNY_CACHE_DIR=vendor/.anny-cache vendor/.venv-anny/bin/python -I scripts/avatar/bake_sculpted_body.py \
        --out Packages/KabinsizCore/Sources/BodyGeometry/Resources --preview /tmp/sculpted
"""
from __future__ import annotations

import argparse
import hashlib
import json
import subprocess
from collections import defaultdict
from pathlib import Path

import anny
import numpy as np
import roma
import torch
from anny.face_segmentation import get_face_segmentation_mask

FORMAT_VERSION = 1
# Neutral, ungendered young adult. Age 2/3 is Anny's "young" anchor; 0.5 elsewhere is the midpoint.
BASE_PHENOTYPE = dict(gender=0.5, age=2 / 3, muscle=0.5, weight=0.5, height=0.5, proportions=0.5)
ARM_TILT_DEG = 9.0  # arms hang this far out from vertical, in the frontal plane
CAVITY_LABELS = [
    "eye_back.L", "eye_front.L", "eye_cavity.L",
    "eye_back.R", "eye_front.R", "eye_cavity.R",
    "mouth_cavity", "tongue",
]
HEAD_SMOOTH_ITERATIONS = 30  # Taubin λ|μ pairs over the head region, after the face refill
# Mannequin egg head (metres, neutral base, app frame).
HEAD_EGG_HEIGHT = 0.205  # crown to the bottom of the egg (chin)
HEAD_EGG_FORWARD = 0.0  # egg centre at the skull's mid-depth
HEAD_EGG_WIDTH_SCALE = 0.88
HEAD_EGG_DEPTH_SCALE = 0.92
HEAD_EGG_TILT_DEG = 16.0  # chin end forward, like a head held level
HEAD_CHIN_ABSORB = 0.03  # vertices this far below the egg's bottom still go fully onto the egg
HEAD_NECK_BLEND = 0.05  # below that, the egg fades into the real neck over this height
# Covered form: landmark patches (metres) smoothed with a fixed rim.
COVER_RADIUS_NIPPLE = 0.04
COVER_RADIUS_NAVEL = 0.045
COVER_RADIUS_CROTCH = 0.08
COVER_SMOOTH_ITERATIONS = 150
HEAD_RELAX_ITERATIONS = 30  # enough to open the eyelid/lip folds; more shrinks inner triangles (Tutte effect)
TAUBIN_LAMBDA, TAUBIN_MU = 0.6, -0.63
# (name, kind, key, value): local change in [-1, 1] or phenotype value, each applied on its own.
BASES = [
    ("shoulder+", "local", "measure-shoulder-dist-incr", 1.0),
    ("shoulder-", "local", "measure-shoulder-dist-incr", -1.0),
    ("bust+", "local", "measure-bust-circ-incr", 1.0),
    ("bust-", "local", "measure-bust-circ-incr", -1.0),
    ("waist+", "local", "measure-waist-circ-incr", 1.0),
    ("waist-", "local", "measure-waist-circ-incr", -1.0),
    ("hips+", "local", "measure-hips-circ-incr", 1.0),
    ("hips-", "local", "measure-hips-circ-incr", -1.0),
    ("torsoWide+", "local", "torso-scale-horiz-incr", 1.0),
    ("torsoWide-", "local", "torso-scale-horiz-incr", -1.0),
    ("torsoDeep+", "local", "torso-scale-depth-incr", 1.0),
    ("torsoDeep-", "local", "torso-scale-depth-incr", -1.0),
    ("hipWide+", "local", "hip-scale-horiz-incr", 1.0),
    ("hipWide-", "local", "hip-scale-horiz-incr", -1.0),
    ("hipDeep+", "local", "hip-scale-depth-incr", 1.0),
    ("hipDeep-", "local", "hip-scale-depth-incr", -1.0),
    ("weight+", "phenotype", "weight", 1.0),
    ("weight-", "phenotype", "weight", 0.0),
]
MEASURES = ["shoulderWidth", "chest", "waist", "hip"]


def to_app(v: np.ndarray) -> np.ndarray:
    """Anny (z up, face towards -y) → app (y up, face towards +z, x to the viewer's right). A rotation."""
    return np.stack([v[:, 0], v[:, 2], -v[:, 1]], axis=1)


class Baker:
    def __init__(self) -> None:
        self.model = anny.Anny(topology="anny", local_changes="default").to(dtype=torch.float32)
        m = self.model
        self.faces = np.asarray(m.faces, dtype=np.int64)
        self.nv = m.template_vertices.shape[0]
        self.identity = torch.eye(4)[None, None].repeat(1, m.bone_count, 1, 1)
        self.pose = self._arms_down_pose()

    # --- Anny evaluation -------------------------------------------------------------------------
    def evaluate(self, phenotype: dict, local: dict, pose=None) -> np.ndarray:
        out = self.model(
            pose_parameters=self.pose if pose is None else pose,
            phenotype_kwargs=phenotype,
            local_changes_kwargs=local,
            pose_parameterization="local-bone",
        )
        return to_app(out["vertices"][0].detach().numpy().astype(np.float64))

    def _arms_down_pose(self) -> torch.Tensor:
        m = self.model
        out = m(pose_parameters=self.identity, phenotype_kwargs=BASE_PHENOTYPE, pose_parameterization="local-bone")
        rest = out["rest_bone_poses"][0]
        pose = self.identity.clone()
        for side, sx in (("L", 1.0), ("R", -1.0)):
            i = m.bone_labels.index(f"upperarm01.{side}")
            j = m.bone_labels.index(f"lowerarm02.{side}")
            d0 = rest[j, :3, 3] - rest[i, :3, 3]
            t = np.radians(ARM_TILT_DEG)
            d1 = torch.tensor([sx * np.sin(t), 0.0, -np.cos(t)], dtype=torch.float32)  # Anny frame, z up
            a, b = d0 / d0.norm(), d1 / d1.norm()
            axis = torch.linalg.cross(a, b)
            rw = roma.rotvec_to_rotmat(axis / axis.norm() * torch.atan2(axis.norm(), torch.dot(a, b)))
            rb = rest[i, :3, :3]
            pose[0, i, :3, :3] = rb.T @ rw @ rb
        return pose

    # --- Topology: drop cavities, close the openings ----------------------------------------------
    def build_topology(self) -> None:
        drop = get_face_segmentation_mask(self.model, CAVITY_LABELS)
        drop = np.asarray(drop, dtype=bool)
        head_faces = np.asarray(get_face_segmentation_mask(self.model, ["head"]), dtype=bool)
        kept = self.faces[~drop]
        loops = boundary_loops(kept)
        print(f"cavities: dropped {drop.sum()} faces, {len(loops)} openings ({[len(l) for l in loops]})")
        used = np.unique(kept)
        remap = -np.ones(self.nv, dtype=np.int64)
        remap[used] = np.arange(len(used))
        # Output vertex = kept vertex, or the mean of an opening's rim (one fan centre per opening).
        rows: list[list[tuple[int, float]]] = [[(int(v), 1.0)] for v in used]
        tris = [remap[t] for t in kept]
        for loop in loops:
            centre = len(rows)
            rows.append([(int(v), 1.0 / len(loop)) for v in loop])
            for a, b in zip(loop, loop[1:] + loop[:1]):
                # The rim runs along the kept triangles' edges a→b; the cap uses b→a to stay closed.
                tris.append(np.array([remap[b], remap[a], centre]))
        self.rows = rows
        self.out_faces = np.array(tris, dtype=np.int64)
        head_vertices = set(np.unique(self.faces[head_faces & ~drop]).tolist())
        self.smooth_mask = np.array(
            [len(r) > 1 or r[0][0] in head_vertices for r in rows], dtype=bool
        )
        self.neighbours = vertex_neighbours(self.out_faces, len(rows))
        # Never move the rim where the head meets the neck: the smoothing then cannot pull the neck.
        border = {i for i in np.flatnonzero(self.smooth_mask) if any(not self.smooth_mask[n] for n in self.neighbours[i])}
        self.head_border = np.zeros(len(rows), dtype=bool)
        for i in border:
            self.smooth_mask[i] = False
            self.head_border[i] = True
        print(f"output: {len(rows)} vertices, {len(self.out_faces)} triangles, {self.smooth_mask.sum()} smoothed")

    def finish(self, anny_vertices: np.ndarray) -> np.ndarray:
        """Anny vertices (app frame) → output vertices: cavity caps, then the faceless head."""
        if not hasattr(self, "_kept"):
            self._kept = np.array([r[0][0] for r in self.rows if len(r) == 1])
            self._caps = [np.array([i for i, _ in r]) for r in self.rows if len(r) > 1]
            idx = np.flatnonzero(self.smooth_mask)
            deg = max(len(self.neighbours[i]) for i in idx)
            pad = len(self.rows)  # index of an all-zero row appended below
            self._smooth_idx = idx
            self._nbr = np.array([self.neighbours[i] + [pad] * (deg - len(self.neighbours[i])) for i in idx])
            self._deg = np.array([len(self.neighbours[i]) for i in idx], dtype=np.float64)[:, None]
        v = np.concatenate([anny_vertices[self._kept], np.array([anny_vertices[c].mean(axis=0) for c in self._caps])])
        if not hasattr(self, "_face_fill"):
            self._face_fill = self._make_face_fill(v)  # region picked once, on the neutral base
        region, fill = self._face_fill
        v[region] = fill(v)
        idx = self._smooth_idx
        for _ in range(HEAD_SMOOTH_ITERATIONS):
            for k in (TAUBIN_LAMBDA, TAUBIN_MU):
                ext = np.concatenate([v, np.zeros((1, 3))])
                avg = ext[self._nbr].sum(axis=1) / self._deg
                v[idx] += k * (avg - v[idx])
        if not hasattr(self, "_covered"):
            self._covered = self._make_covered_patches(v)  # regions picked once, on the neutral base
        for patch, nbr, deg in self._covered:
            for _ in range(COVER_SMOOTH_ITERATIONS):
                ext = np.concatenate([v, np.zeros((1, 3))])
                v[patch] += 0.5 * (ext[nbr].sum(axis=1) / deg - v[patch])
        return v

    def _make_covered_patches(self, v: np.ndarray):
        """Covered form (v1.5 §108.3): nipples, navel and the crotch are smoothed away. Each patch is a
        small region around a landmark on the neutral base; its rim stays fixed, the inside relaxes
        towards the surface spanning the rim (linear, so it holds for every mixed shape)."""
        y0 = v[:, 1].min(); h = v[:, 1].max() - y0
        y = (v[:, 1] - y0) / h
        centres = []
        for side in (1, -1):  # nipples: the most forward point of each breast
            band = np.flatnonzero((y > 0.70) & (y < 0.78) & (side * v[:, 0] > 0.05) & (side * v[:, 0] < 0.15))
            centres.append((v[band[np.argmax(v[band, 2])]], COVER_RADIUS_NIPPLE))
        mid = np.flatnonzero((np.abs(v[:, 0]) < 0.012) & (y > 0.56) & (y < 0.63))  # navel on the centre line
        centres.append((v[mid[np.argmax(v[mid, 2])]] * np.array([0, 1, 1]), COVER_RADIUS_NAVEL))
        crotch = np.flatnonzero((np.abs(v[:, 0]) < 0.02) & (y > 0.45) & (y < 0.52))
        centres.append((v[crotch[np.argmax(v[crotch, 2])]] * np.array([0, 1, 1]), COVER_RADIUS_CROTCH))
        patches = []
        for c, r in centres:
            inside = np.linalg.norm(v - c, axis=1) < r
            idx = np.flatnonzero(inside & ~self.arm_like(v))
            deg = max(len(self.neighbours[i]) for i in idx)
            pad = len(v)
            nbr = np.array([self.neighbours[i] + [pad] * (deg - len(self.neighbours[i])) for i in idx])
            # Pad entries point at the appended zero row; count only real neighbours.
            real = np.array([len(self.neighbours[i]) for i in idx], dtype=np.float64)[:, None]
            patches.append((idx, nbr, real))
        print("covered patches:", [len(p[0]) for p in patches])
        return patches

    def arm_like(self, v: np.ndarray) -> np.ndarray:
        """Hands hang beside the hips: keep them out of the crotch patch by distance from the centre."""
        return np.abs(v[:, 0]) > 0.16

    def _make_face_fill(self, v: np.ndarray):
        """Faceless head: every head vertex is pulled onto one smooth egg (an ellipsoid fitted to the
        neutral skull, chin end tilted forward), blended into the original shape down the neck. The
        egg is fixed for every shape, so the head is identical across bodies (scaled with height)."""
        head = self.smooth_mask | self.head_border
        y = v[:, 1]
        top = y.max()
        jaw = top - HEAD_EGG_HEIGHT
        skull = head & (y > top - 0.09)
        centre = np.array([0.0, (top + jaw) / 2, v[skull, 2].min() / 2 + v[skull, 2].max() / 2 + HEAD_EGG_FORWARD])
        radii = np.array([
            np.percentile(np.abs(v[skull, 0]), 99) * HEAD_EGG_WIDTH_SCALE,
            (top - jaw) / 2,
            (v[skull, 2].max() - v[skull, 2].min()) / 2 * HEAD_EGG_DEPTH_SCALE,
        ])
        tilt = np.radians(HEAD_EGG_TILT_DEG)
        rot = np.array([[1, 0, 0], [0, np.cos(tilt), -np.sin(tilt)], [0, np.sin(tilt), np.cos(tilt)]])
        # Fully on the egg down to just below its bottom (so the real chin and lips are absorbed),
        # then fading into the real neck.
        full_below = jaw - HEAD_CHIN_ABSORB
        region = np.flatnonzero(head & (y > full_below - HEAD_NECK_BLEND))
        weight = np.clip((y[region] - (full_below - HEAD_NECK_BLEND)) / HEAD_NECK_BLEND, 0, 1)
        weight = (weight * weight * (3 - 2 * weight))[:, None]
        print(f"faceless head: {len(region)} vertices on the egg, radii {np.round(radii, 3)}")

        def project(points: np.ndarray) -> np.ndarray:
            local = (points - centre) @ rot  # egg frame
            d = local / np.linalg.norm(local, axis=1, keepdims=True)
            r = 1 / np.sqrt(((d / radii) ** 2).sum(axis=1, keepdims=True))
            return centre + (d * r) @ rot.T

        # Eyelids and lips are folded layers; projected as-is they leave creases on the egg. Relax the
        # fully-on-egg vertices across the surface (neighbour average, back onto the egg) until the
        # folds open. Done once on the neutral base: those vertices are the same for every body.
        egg_pos = project(v[region])
        full = weight[:, 0] >= 1.0
        local_index = -np.ones(len(v), dtype=np.int64)
        local_index[region] = np.arange(len(region))
        work = v.copy()
        work[region] = (1 - weight) * v[region] + weight * egg_pos
        movable = region[full]
        nbrs = [np.array(self.neighbours[i]) for i in movable]
        for _ in range(HEAD_RELAX_ITERATIONS):
            avg = np.array([work[n].mean(axis=0) for n in nbrs])
            work[movable] = project(avg)
        fixed_egg = work[movable]

        def fill(verts: np.ndarray) -> np.ndarray:
            out = (1 - weight) * verts[region] + weight * project(verts[region])
            out[full] = fixed_egg
            return out

        return region, fill

    # --- Measurements (mirrored exactly by SculptedBody.swift) -------------------------------------
    def build_tapes(self, v: np.ndarray) -> None:
        m = self.model
        def parent(b):
            p = m.bone_parents[b]
            if isinstance(p, str):
                return m.bone_labels.index(p)
            return None if p is None or int(p) < 0 else int(p)

        roots = {m.bone_labels.index(f"upperarm01.{s}") for s in "LR"}
        arm_bones = set()
        for b in range(m.bone_count):
            p = b
            while p is not None:
                if p in roots:
                    arm_bones.add(b)
                    break
                p = parent(p)
        idx = m.vertex_bone_indices.detach().numpy()
        w = m.vertex_bone_weights.detach().numpy()
        dominant = idx[np.arange(self.nv), w.argmax(axis=1)]
        arm_vertex = np.isin(dominant, list(arm_bones))
        torso = np.array([not any(arm_vertex[i] for i, _ in r) for r in self.rows])
        edges = unique_edges(self.out_faces)
        edges = edges[torso[edges[:, 0]] & torso[edges[:, 1]]]
        y0, y1 = v[:, 1].min(), v[:, 1].max()
        h = y1 - y0

        def slice_at(frac):
            y = y0 + frac * h
            a, b = v[edges[:, 0], 1] - y, v[edges[:, 1], 1] - y
            hit = a * b < 0
            e = edges[hit]
            t = a[hit] / (a[hit] - b[hit])
            pts = v[e[:, 0]] + t[:, None] * (v[e[:, 1]] - v[e[:, 0]])
            return [(int(i), int(j), float(s)) for (i, j), s in zip(e, t)], hull_perimeter(pts[:, [0, 2]])

        profile = {round(f, 3): slice_at(f)[1] for f in np.arange(0.44, 0.80, 0.005)}
        self.profile = profile
        pick = lambda lo, hi, best: best((f for f in profile if lo <= f <= hi), key=profile.get)
        # Bands from the neutral profile: bust between the underbust and the armpits, natural waist
        # (narrowest), seat (widest) above the crotch so the tape never runs around both thighs.
        self.tape_fractions = {
            "chest": float(pick(0.71, 0.75, max)),
            "waist": float(pick(0.58, 0.68, min)),
            "hip": float(pick(0.48, 0.54, max)),
        }
        self.tapes = {k: slice_at(f)[0] for k, f in self.tape_fractions.items()}
        # Shoulder width: shoulder point to shoulder point (top of the shoulder, just outside the
        # upper-arm joint), the way a tailor measures across the shoulders.
        out = m(pose_parameters=self.pose, phenotype_kwargs=BASE_PHENOTYPE, pose_parameterization="local-bone")
        joint = to_app(out["bone_poses"][0][:, :3, 3].detach().numpy().astype(np.float64))[m.bone_labels.index("upperarm01.L")]
        joint = joint + (v[:, 1].min() - to_app(out["vertices"][0].detach().numpy().astype(np.float64))[:, 1].min()) * np.array([0, 1, 0])
        near = (np.abs(v[:, 0] - (joint[0] + 0.02)) < 0.012) & (np.abs(v[:, 2] - joint[2]) < 0.03)
        cand = np.flatnonzero(near)
        left = int(cand[np.argmax(v[cand, 1])])
        mirror = v[left] * np.array([-1, 1, 1])
        right = int(np.argmin(np.linalg.norm(v - mirror, axis=1)))
        self.shoulder_pair = (left, right)
        self.arm_mask = np.array([any(arm_vertex[i] for i, _ in r) for r in self.rows])
        print("tape heights (fraction of height):", self.tape_fractions, "shoulder points", np.round(v[[left, right]], 3).tolist())

    def measure(self, v: np.ndarray) -> np.ndarray:
        out = [np.linalg.norm(v[self.shoulder_pair[0]] - v[self.shoulder_pair[1]])]
        for k in ("chest", "waist", "hip"):
            e = self.tapes[k]
            a = v[[i for i, _, _ in e]]
            b = v[[j for _, j, _ in e]]
            t = np.array([s for _, _, s in e])[:, None]
            out.append(hull_perimeter((a + t * (b - a))[:, [0, 2]]))
        return np.array(out) * 100  # cm


# --- Geometry helpers ------------------------------------------------------------------------------
def unique_edges(faces: np.ndarray) -> np.ndarray:
    e = np.concatenate([faces[:, [0, 1]], faces[:, [1, 2]], faces[:, [2, 0]]])
    return np.unique(np.sort(e, axis=1), axis=0)


def vertex_neighbours(faces: np.ndarray, n: int) -> list[list[int]]:
    nb = [set() for _ in range(n)]
    for a, b in unique_edges(faces):
        nb[a].add(int(b)); nb[b].add(int(a))
    return [sorted(s) for s in nb]


def boundary_loops(faces: np.ndarray) -> list[list[int]]:
    directed = defaultdict(int)
    for t in faces:
        for a, b in ((t[0], t[1]), (t[1], t[2]), (t[2], t[0])):
            directed[(int(a), int(b))] += 1
    nxt = {a: b for (a, b) in directed if (b, a) not in directed}
    loops, seen = [], set()
    for start in nxt:
        if start in seen:
            continue
        loop, cur = [], start
        while cur not in seen:
            seen.add(cur); loop.append(cur); cur = nxt[cur]
        loops.append(loop)
    return loops


def hull_perimeter(p: np.ndarray) -> float:
    """Convex hull perimeter (a tape measure pulled around the slice). Andrew's monotone chain."""
    pts = sorted(set(map(tuple, np.round(p, 9))))
    if len(pts) < 3:
        return 0.0
    cross = lambda o, a, b: (a[0] - o[0]) * (b[1] - o[1]) - (a[1] - o[1]) * (b[0] - o[0])
    lower, upper = [], []
    for q in pts:
        while len(lower) >= 2 and cross(lower[-2], lower[-1], q) <= 0:
            lower.pop()
        lower.append(q)
    for q in reversed(pts):
        while len(upper) >= 2 and cross(upper[-2], upper[-1], q) <= 0:
            upper.pop()
        upper.append(q)
    hull = np.array(lower[:-1] + upper[:-1])
    return float(np.linalg.norm(hull - np.roll(hull, 1, axis=0), axis=1).sum())


def signed_volume(v: np.ndarray, f: np.ndarray) -> float:
    a, b, c = v[f[:, 0]], v[f[:, 1]], v[f[:, 2]]
    return float(np.einsum("ij,ij->i", a, np.cross(b, c)).sum() / 6)


# --- Main --------------------------------------------------------------------------------------------
def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--out", type=Path, required=True)
    ap.add_argument("--preview", type=Path)
    ap.add_argument("--anny-src", type=Path, default=Path("vendor/anny"), help="the Anny git clone that was pip-installed")
    args = ap.parse_args()

    bk = Baker()
    bk.build_topology()
    base_anny = bk.evaluate(BASE_PHENOTYPE, {})
    base = bk.finish(base_anny)
    if signed_volume(base, bk.out_faces) < 0:
        bk.out_faces = bk.out_faces[:, [0, 2, 1]]
    bk.build_tapes(base)
    m0 = bk.measure(base)

    deltas, jac = [], []
    for name, kind, key, value in BASES:
        ph, lc = dict(BASE_PHENOTYPE), {}
        if kind == "phenotype":
            ph[key] = value
        else:
            lc[key] = value
        shape = bk.finish(bk.evaluate(ph, lc))
        deltas.append(shape - base)
        jac.append(bk.measure(shape) - m0)
        print(f"{name:10s} Δcm {np.round(jac[-1], 2)}  max|Δ| {np.abs(deltas[-1]).max() * 100:.1f} cm")
    deltas = np.stack(deltas)  # K × N × 3
    jac = np.array(jac).T  # 4 × K

    # Linearity check: random mixes of one local change per measure + weight, true Anny vs the basis.
    rng = np.random.default_rng(7)
    worst = 0.0
    for _ in range(6):
        ph, lc, w = dict(BASE_PHENOTYPE), {}, np.zeros(len(BASES))
        for m_i, key in enumerate(["measure-shoulder-dist-incr", "measure-bust-circ-incr", "measure-waist-circ-incr", "measure-hips-circ-incr"]):
            val = float(rng.uniform(-1, 1))
            lc[key] = val
            w[2 * m_i + (0 if val >= 0 else 1)] = abs(val)
        wt = float(rng.uniform(0, 1))
        ph["weight"] = wt
        names = [b[0] for b in BASES]
        w[names.index("weight+" if wt >= 0.5 else "weight-")] = abs(wt - 0.5) * 2
        true = bk.finish(bk.evaluate(ph, lc))
        mixed = base + np.tensordot(w, deltas, axes=1)
        worst = max(worst, float(np.abs(true - mixed).max()))
    print(f"linearity: worst vertex error over 6 random mixes = {worst * 1000:.1f} mm")

    # Quantise deltas to int16 with one scale per basis.
    scales = np.abs(deltas).reshape(len(BASES), -1).max(axis=1) / 32767
    q = np.round(deltas / scales[:, None, None]).astype("<i2")
    args.out.mkdir(parents=True, exist_ok=True)
    # Layout: base positions f32[N·3] | triangles u16[T·3] | deltas i16[K·N·3] | arm flags u8[N].
    blob = (
        base.astype("<f4").tobytes()
        + bk.out_faces.astype("<u2").tobytes()
        + q.tobytes()
        + bk.arm_mask.astype("u1").tobytes()
    )
    (args.out / "SculptedBody.bin").write_bytes(blob)
    # The installed package has no git metadata: read the commit from the clone it was installed from.
    try:
        top = subprocess.run(["git", "-C", str(args.anny_src), "rev-parse", "--show-toplevel"], capture_output=True, text=True).stdout.strip()
        ok = top and Path(top).resolve() == args.anny_src.resolve()
        commit = subprocess.run(["git", "-C", str(args.anny_src), "rev-parse", "HEAD"], capture_output=True, text=True).stdout.strip() if ok else ""
    except OSError:
        commit = ""
    meta = {
        "formatVersion": FORMAT_VERSION,
        "vertexCount": int(len(base)),
        "triangleCount": int(len(bk.out_faces)),
        "bases": [b[0] for b in BASES],
        "deltaScales": [float(s) for s in scales],
        "baseHeightM": float(base[:, 1].max() - base[:, 1].min()),
        "measures": MEASURES,
        "baseMeasuresCm": [float(x) for x in m0],
        "jacobianCm": [[float(x) for x in row] for row in jac],
        "shoulderPair": list(bk.shoulder_pair),
        "tapes": {k: [[i, j, round(t, 6)] for i, j, t in e] for k, e in bk.tapes.items()},
        "tapeHeightFractions": bk.tape_fractions,
        "binarySHA256": hashlib.sha256(blob).hexdigest(),
        "provenance": {
            "source": "NAVER Anny (https://github.com/naver/anny)",
            "annyVersion": getattr(anny, "__version__", "UNKNOWN"),
            "annyCommit": commit or "UNKNOWN",
            "codeLicense": "Apache-2.0",
            "assetLicense": "CC0-1.0 (MakeHuman / MPFB2)",
            "topology": "anny (MakeHuman-derived; non-commercial smplx/smpl topologies not used)",
            "phenotype": BASE_PHENOTYPE,
            "armTiltDeg": ARM_TILT_DEG,
            "headSmoothing": {"iterations": HEAD_SMOOTH_ITERATIONS, "lambda": TAUBIN_LAMBDA, "mu": TAUBIN_MU},
            "linearityWorstMm": round(worst * 1000, 2),
        },
    }
    (args.out / "SculptedBody.json").write_text(json.dumps(meta, indent=1) + "\n")
    print(f"wrote {len(blob) / 1e6:.2f} MB, base measures cm {np.round(m0, 1)}, height {meta['baseHeightM']:.3f} m")

    if args.preview:
        import sys
        sys.path.insert(0, str(args.preview.parent))
        args.preview.mkdir(parents=True, exist_ok=True)
        np.save(args.preview / "base.npy", base)
        np.save(args.preview / "faces.npy", bk.out_faces)
        np.save(args.preview / "deltas.npy", deltas)


if __name__ == "__main__":
    main()
