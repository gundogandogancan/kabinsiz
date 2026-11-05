"""Original garment sprites for the Kabinsiz Live Mirror and product thumbnails (MIR-WP02).

Every garment is modelled from primitives in this file (lofted rings, tubes, boxes); no photo,
scan, brand pattern or third-party asset is used, so every output is OWNED_ORIGINAL. Fabric is
rendered in neutral off-white so the app can tint it to the product's colour; buttons, soles and
stitching are rendered separately ("fixed" layer) and are never tinted.

For each garment form the script writes, into --out:
  <form>-<part>-fabric.png   tintable fabric layer (RGBA, neutral)
  <form>-<part>-fixed.png    untinted trims layer (RGBA), only when the part has trims
  <form>-thumb-fabric.png / -fixed.png   whole garment, front, for cards
  garments.json              per part: pixel size, the two axis anchors (a = top, b = bottom), and
                             the reference width in pixels the app scales against

Parts are rendered straight (sleeves and legs hanging down) so the app can rotate each one onto the
person's bones: torso from the shoulder midpoint to the hip midpoint, sleeves shoulder→elbow and
elbow→wrist, legs hip→knee and knee→ankle, shoes at the ankle.

Usage (headless):
  Blender -b --python tools/garments/build_garment_sprites.py -- --out <dir> [--samples 48] [--forms tee,coat]
  Blender -b --python tools/garments/build_garment_sprites.py -- --mannequin <png>
"""

import argparse
import json
import math
import os
import sys

import bmesh
import bpy
from bpy_extras.object_utils import world_to_camera_view
from mathutils import Vector

PX_PER_M = 820          # sprite resolution
MARGIN = 0.035          # metres of empty border around every part

# Rest skeleton (metres, x right on screen, z up). Matches the joints Apple Vision reports.
NECK_Z = 1.50
SHOULDER = (0.190, 1.445)     # ± x
HIP = (0.095, 0.935)
UPPER_ARM = 0.290
FOREARM = 0.255
THIGH = 0.430
SHIN = 0.420

FABRIC = (0.86, 0.85, 0.83)   # neutral off-white so a multiply tint keeps the colour

FORMS = ["tee", "longSleeveTee", "knit", "shirt", "jacket", "coat",
         "trousers", "jeans", "shorts", "skirt", "sneakers", "boots", "loafers"]


def args():
    argv = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
    p = argparse.ArgumentParser()
    p.add_argument("--out")
    p.add_argument("--samples", type=int, default=48)
    p.add_argument("--forms", default=",".join(FORMS))
    p.add_argument("--mannequin")
    p.add_argument("--variant", default="{}",
                   help="JSON: skin, hair, top, bottom, shoe (sRGB 0-1), sleeve short|long, lower trousers|shorts, "
                        "hairLong bool, wordmark text (fictional brand only)")
    return p.parse_args(argv)


# ---------------------------------------------------------------- scene

def reset():
    bpy.ops.wm.read_factory_settings(use_empty=True)
    scene = bpy.context.scene
    scene.render.engine = "CYCLES"
    scene.cycles.device = "CPU"
    scene.cycles.use_denoising = True
    scene.render.film_transparent = True
    scene.view_settings.view_transform = "Standard"
    scene.view_settings.look = "None"
    scene.render.image_settings.file_format = "PNG"
    scene.render.image_settings.color_mode = "RGBA"
    scene.render.image_settings.compression = 90
    world = bpy.data.worlds.new("world")
    world.use_nodes = True
    bg = world.node_tree.nodes.get("Background")
    bg.inputs["Color"].default_value = (0.9, 0.9, 0.9, 1)
    bg.inputs["Strength"].default_value = 0.12
    scene.world = world
    # Soft studio light: key from the upper front left, fill from the right, top light.
    for name, loc, energy, size in (
        ("key", (-2.4, -1.8, 2.4), 95, 1.2),
        ("fill", (2.2, -2.0, 1.2), 16, 3.0),
        ("top", (0.0, -0.4, 3.4), 30, 1.6),
        ("rim", (1.6, 1.8, 2.2), 40, 1.0),
    ):
        data = bpy.data.lights.new(name, "AREA")
        data.energy = energy
        data.size = size
        light = bpy.data.objects.new(name, data)
        scene.collection.objects.link(light)
        light.location = loc
        direction = Vector((0, 0, 1.0)) - Vector(loc)
        light.rotation_euler = direction.to_track_quat("-Z", "Y").to_euler()
    cam_data = bpy.data.cameras.new("cam")
    cam_data.type = "ORTHO"
    cam = bpy.data.objects.new("cam", cam_data)
    scene.collection.objects.link(cam)
    cam.rotation_euler = (math.radians(90), 0, 0)  # looks along +Y
    scene.camera = cam
    return scene


# ---------------------------------------------------------------- materials

def fabric_material(kind):
    """Neutral fabric with a weave appropriate to the kind; only luminance varies."""
    m = bpy.data.materials.new(f"fabric-{kind}")
    m.use_nodes = True
    nt = m.node_tree
    b = nt.nodes["Principled BSDF"]
    b.inputs["Base Color"].default_value = (*FABRIC, 1)
    b.inputs["Roughness"].default_value = 0.86
    coord = nt.nodes.new("ShaderNodeTexCoord")
    bump = nt.nodes.new("ShaderNodeBump")
    if kind in ("knit",):
        tex = nt.nodes.new("ShaderNodeTexWave")
        tex.wave_type = "BANDS"
        tex.bands_direction = "X"
        tex.inputs["Scale"].default_value = 140
        tex.inputs["Distortion"].default_value = 1.5
        bump.inputs["Strength"].default_value = 0.55
        b.inputs["Sheen Weight"].default_value = 0.6
    elif kind in ("denim",):
        tex = nt.nodes.new("ShaderNodeTexWave")
        tex.wave_type = "BANDS"
        tex.bands_direction = "DIAGONAL"
        tex.inputs["Scale"].default_value = 420
        tex.inputs["Distortion"].default_value = 3.0
        bump.inputs["Strength"].default_value = 0.35
    elif kind in ("wool",):
        tex = nt.nodes.new("ShaderNodeTexNoise")
        tex.inputs["Scale"].default_value = 900
        tex.inputs["Detail"].default_value = 8
        bump.inputs["Strength"].default_value = 0.25
        b.inputs["Sheen Weight"].default_value = 0.8
        b.inputs["Roughness"].default_value = 0.95
    elif kind in ("leather",):
        tex = nt.nodes.new("ShaderNodeTexNoise")
        tex.inputs["Scale"].default_value = 260
        bump.inputs["Strength"].default_value = 0.08
        b.inputs["Roughness"].default_value = 0.42
        b.inputs["Coat Weight"].default_value = 0.25
    else:  # cotton / shirting / twill
        tex = nt.nodes.new("ShaderNodeTexNoise")
        tex.inputs["Scale"].default_value = 1400
        tex.inputs["Detail"].default_value = 4
        bump.inputs["Strength"].default_value = 0.12
    nt.links.new(coord.outputs["Object"], tex.inputs["Vector"])
    nt.links.new(tex.outputs[0], bump.inputs["Height"])
    nt.links.new(bump.outputs["Normal"], b.inputs["Normal"])
    # Inside of the garment (seen through a neckline): darker.
    geo = nt.nodes.new("ShaderNodeNewGeometry")
    mix = nt.nodes.new("ShaderNodeMix")
    mix.data_type = "RGBA"
    mix.inputs["A"].default_value = (*FABRIC, 1)
    mix.inputs["B"].default_value = (0.42, 0.41, 0.40, 1)
    nt.links.new(geo.outputs["Backfacing"], mix.inputs["Factor"])
    nt.links.new(mix.outputs["Result"], b.inputs["Base Color"])
    return m


def fixed_material(name, rgb, rough=0.5, metal=0.0):
    m = bpy.data.materials.new(name)
    m.use_nodes = True
    b = m.node_tree.nodes["Principled BSDF"]
    b.inputs["Base Color"].default_value = (*rgb, 1)
    b.inputs["Roughness"].default_value = rough
    b.inputs["Metallic"].default_value = metal
    m["fixed"] = True
    return m


# ---------------------------------------------------------------- geometry helpers

def obj_from_bmesh(bm, name, material, subdiv=2, wrinkle=0.0, wrinkle_scale=0.08, solid=0.004):
    mesh = bpy.data.meshes.new(name)
    bm.to_mesh(mesh)
    bm.free()
    obj = bpy.data.objects.new(name, mesh)
    bpy.context.scene.collection.objects.link(obj)
    obj.data.materials.append(material)
    if subdiv:
        mod = obj.modifiers.new("subd", "SUBSURF")
        mod.levels = subdiv
        mod.render_levels = subdiv
    if wrinkle > 0:
        tex = bpy.data.textures.new(f"{name}-wr", "CLOUDS")
        tex.noise_scale = wrinkle_scale
        tex.noise_depth = 2
        d = obj.modifiers.new("wrinkle", "DISPLACE")
        d.texture = tex
        d.strength = wrinkle
        d.texture_coords = "OBJECT"
    if solid:
        s = obj.modifiers.new("solid", "SOLIDIFY")
        s.thickness = solid
    for poly in obj.data.polygons:
        poly.use_smooth = True
    return obj


def loft(rings, name, material, closed_top=False, **kw):
    """rings: list of lists of (x, y, z); all the same length; consecutive rings are joined."""
    bm = bmesh.new()
    verts = [[bm.verts.new(p) for p in ring] for ring in rings]
    n = len(rings[0])
    for a, b in zip(verts, verts[1:]):
        for i in range(n):
            j = (i + 1) % n
            bm.faces.new((a[i], a[j], b[j], b[i]))
    if closed_top:
        bm.faces.new(list(reversed(verts[0])))
    return obj_from_bmesh(bm, name, material, **kw)


def ellipse(cx, cz, half_w, half_d, n=40, front_drop=None, shoulder_slope=0.0):
    """A ring at height cz; x = width axis, y = depth (negative y faces the camera)."""
    out = []
    for i in range(n):
        t = 2 * math.pi * i / n
        x = cx + half_w * math.cos(t)
        y = half_d * math.sin(t)
        z = cz
        if shoulder_slope:
            z -= shoulder_slope * (abs(x - cx) / half_w) ** 2
        if front_drop and y < 0:
            # Neckline: drop the front of the top ring towards the centre.
            depth, width = front_drop
            k = max(0.0, 1 - (abs(x - cx) / width) ** 2)
            z -= depth * k * (-y / half_d)
        out.append((x, y, z))
    return out


def tube(z0, z1, r0, r1, name, material, flare=0.0, n=28, rings=6, cap=0.0, **kw):
    """A sleeve or leg along -z from z0 to z1, centred on x = 0. `cap` > 0 rounds the top into a
    sleeve head (a dome of that height above z0) instead of an open, flat-cut end."""
    rs = []
    if cap > 0:
        for k in range(5):
            ang = math.radians(78 - k * 15)          # 78° … 18° from the horizontal
            r = r0 * math.cos(ang)
            rs.append(ellipse(0, z0 + cap * math.sin(ang), r, r * 0.92, n=n))
        kw.setdefault("closed_top", True)
    for k in range(rings + 1):
        t = k / rings
        z = z0 + (z1 - z0) * t
        r = r0 + (r1 - r0) * t + flare * t * t
        rs.append(ellipse(0, z, r, r * 0.92, n=n))
    return loft(rs, name, material, **kw)


def box(name, material, loc, size, bevel=0.01, subdiv=2):
    bpy.ops.mesh.primitive_cube_add(size=1, location=loc)
    obj = bpy.context.active_object
    obj.name = name
    obj.scale = size
    bpy.ops.object.transform_apply(scale=True)
    if bevel:
        mod = obj.modifiers.new("bevel", "BEVEL")
        mod.width = bevel
        mod.segments = 3
    if subdiv:
        mod = obj.modifiers.new("subd", "SUBSURF")
        mod.levels = subdiv
        mod.render_levels = subdiv
    obj.data.materials.append(material)
    for poly in obj.data.polygons:
        poly.use_smooth = True
    return obj


def button(name, material, loc, r=0.0085):
    bpy.ops.mesh.primitive_cylinder_add(radius=r, depth=0.004, location=loc, rotation=(math.radians(90), 0, 0))
    obj = bpy.context.active_object
    obj.name = name
    obj.data.materials.append(material)
    return obj


def stitch_line(name, material, points, radius=0.0011):
    curve = bpy.data.curves.new(name, "CURVE")
    curve.dimensions = "3D"
    curve.bevel_depth = radius
    spline = curve.splines.new("POLY")
    spline.points.add(len(points) - 1)
    for p, (x, y, z) in zip(spline.points, points):
        p.co = (x, y, z, 1)
    obj = bpy.data.objects.new(name, curve)
    bpy.context.scene.collection.objects.link(obj)
    obj.data.materials.append(material)
    return obj


# ---------------------------------------------------------------- garments

def torso_rings(hem_z, hem_half_w, hem_flare=0.0, neckline=(0.06, 0.07), neck_half=0.075, ease=1.0):
    """Lofted torso from the shoulder line to the hem. Front faces -y."""
    sx = SHOULDER[0]
    levels = [
        # (z, half width, half depth)
        (SHOULDER[1] + 0.03, sx + 0.035, 0.105),
        (1.36, 0.185, 0.122),
        (1.24, 0.172, 0.125),
        (1.10, 0.160, 0.115),
        (0.98, 0.170, 0.118),
    ]
    z = 0.98
    while z - 0.10 > hem_z:
        z -= 0.10
        t = (0.98 - z) / max(0.98 - hem_z, 0.01)
        levels.append((z, 0.170 + (hem_half_w - 0.170) * t + hem_flare * t * t, 0.120 + 0.01 * t))
    levels.append((hem_z, hem_half_w + hem_flare, 0.125))
    rings = []
    for idx, (z, hw, hd) in enumerate(levels):
        if idx == 0:
            rings.append(ellipse(0, z, hw * ease, hd * ease, front_drop=neckline, shoulder_slope=0.075))
        else:
            rings.append(ellipse(0, z, hw * ease, hd * ease))
    return rings


def neck_hole_cap(ring_top, name, material, neck_half):
    """Fills the shoulder ring except for the neck opening, so shoulders read as a surface."""
    bm = bmesh.new()
    outer = [bm.verts.new(p) for p in ring_top]
    n = len(ring_top)
    inner = []
    for (x, y, z) in ring_top:
        t = math.atan2(y, x)
        inner.append(bm.verts.new((neck_half * math.cos(t), neck_half * 0.9 * math.sin(t), NECK_Z - 0.005)))
    for i in range(n):
        j = (i + 1) % n
        bm.faces.new((outer[i], outer[j], inner[j], inner[i]))
    return obj_from_bmesh(bm, name, material, subdiv=1, solid=0.003)


class Builder:
    """Builds one garment form as named parts; every part is a list of objects."""

    def __init__(self):
        self.cotton = fabric_material("cotton")
        self.knit = fabric_material("knit")
        self.denim = fabric_material("denim")
        self.wool = fabric_material("wool")
        self.leather = fabric_material("leather")
        self.button_mat = fixed_material("button", (0.20, 0.17, 0.14), rough=0.35)
        self.horn = fixed_material("horn", (0.12, 0.10, 0.09), rough=0.3)
        self.metal = fixed_material("metal", (0.72, 0.62, 0.42), rough=0.3, metal=1.0)
        self.sole_white = fixed_material("sole-white", (0.93, 0.92, 0.90), rough=0.6)
        self.sole_dark = fixed_material("sole-dark", (0.10, 0.09, 0.09), rough=0.55)
        self.stitch = fixed_material("stitch", (0.78, 0.55, 0.25), rough=0.7)
        self.lace = fixed_material("lace", (0.95, 0.95, 0.94), rough=0.8)

    # Tops -------------------------------------------------------------
    def top(self, form):
        mat = {"knit": self.knit, "coat": self.wool, "jacket": self.cotton}.get(form, self.cotton)
        hem = {"tee": 0.86, "longSleeveTee": 0.86, "knit": 0.88, "shirt": 0.80,
               "jacket": 0.78, "coat": 0.42}[form]
        hem_w = {"coat": 0.215, "jacket": 0.195}.get(form, 0.175)
        flare = 0.03 if form == "coat" else 0.0
        neck = {"tee": (0.05, 0.075), "longSleeveTee": (0.05, 0.075), "knit": (0.045, 0.08),
                "shirt": (0.02, 0.06), "jacket": (0.20, 0.07), "coat": (0.22, 0.075)}[form]
        ease = {"coat": 1.12, "jacket": 1.08, "knit": 1.05}.get(form, 1.0)
        rings = torso_rings(hem, hem_w, flare, neckline=neck, ease=ease)
        torso = [loft(rings, f"{form}-torso", mat, wrinkle=0.014, wrinkle_scale=0.06)]
        torso.append(neck_hole_cap(rings[0], f"{form}-cap", mat, 0.078))
        y_front = -0.125 * ease
        if form in ("tee", "longSleeveTee", "knit"):
            # Rib neckband.
            band = []
            for k in range(2):
                band.append(ellipse(0, NECK_Z - 0.005 - 0.014 * k, 0.082, 0.074, front_drop=(neck[0] * 0.9, 0.09)))
            torso.append(loft(band, f"{form}-band", self.knit if form == "knit" else mat, subdiv=1, solid=0.006))
            if form == "knit":
                hemband = [ellipse(0, hem + 0.05, 0.18 * ease, 0.128 * ease), ellipse(0, hem, 0.176 * ease, 0.125 * ease)]
                torso.append(loft(hemband, f"{form}-hem", self.knit, subdiv=1, solid=0.008))
        if form == "shirt":
            # Collar, placket, buttons.
            collar = [ellipse(0, NECK_Z + 0.035, 0.080, 0.072, front_drop=(0.03, 0.05)),
                      ellipse(0, NECK_Z - 0.01, 0.096, 0.088, front_drop=(0.05, 0.08))]
            torso.append(loft(collar, "shirt-collar", mat, subdiv=1, solid=0.004))
            torso.append(box("shirt-placket", mat, (0, y_front - 0.004, (NECK_Z - 0.06 + hem) / 2), (0.032, 0.004, NECK_Z - 0.06 - hem), bevel=0.002, subdiv=1))
            for i in range(6):
                z = NECK_Z - 0.09 - i * (NECK_Z - 0.14 - hem) / 6
                torso.append(button(f"shirt-btn{i}", self.button_mat, (0, y_front - 0.008, z), r=0.0055))
            torso.append(box("shirt-pocket", mat, (-0.085, y_front - 0.006, 1.27), (0.075, 0.003, 0.085), bevel=0.003, subdiv=1))
        if form in ("jacket", "coat"):
            # Lapels: two flat panels folded back from the neckline.
            for side in (-1, 1):
                bm = bmesh.new()
                pts = [(side * 0.075, y_front - 0.006, NECK_Z - 0.01), (side * 0.15, y_front - 0.004, 1.34),
                       (side * 0.10, y_front - 0.006, 1.22), (side * 0.012, y_front - 0.01, 1.22 - (0.05 if form == "coat" else 0.0))]
                vs = [bm.verts.new(p) for p in pts]
                bm.faces.new(vs)
                torso.append(obj_from_bmesh(bm, f"{form}-lapel{side}", mat, subdiv=1, solid=0.006))
            rows = [(0.0, 1.17), (0.0, 1.03)] if form == "jacket" else [(-0.055, 1.17), (0.055, 1.17), (-0.055, 1.02), (0.055, 1.02), (-0.055, 0.87), (0.055, 0.87)]
            for i, (x, z) in enumerate(rows):
                torso.append(button(f"{form}-btn{i}", self.horn, (x, y_front - 0.012, z), r=0.011))
            for side in (-1, 1):
                pz = 0.95 if form == "jacket" else 0.80
                torso.append(box(f"{form}-flap{side}", mat, (side * 0.11, y_front - 0.01, pz), (0.11, 0.004, 0.035), bevel=0.003, subdiv=1))
            # Centre front edge.
            torso.append(box(f"{form}-edge", mat, (0.004, y_front - 0.009, (1.2 + hem) / 2), (0.006, 0.003, 1.2 - hem), bevel=0.001, subdiv=1))
        parts = {"torso": torso}
        # Sleeves.
        short = form == "tee"
        sleeve_mat = mat
        r_top = {"coat": 0.078, "jacket": 0.072, "knit": 0.068}.get(form, 0.064)
        if short:
            parts["upperSleeve"] = [tube(0.0, -0.17, r_top, r_top * 0.92, "tee-sleeve", sleeve_mat, cap=0.055, wrinkle=0.004)]
        else:
            parts["upperSleeve"] = [tube(0.0, -UPPER_ARM - 0.02, r_top, r_top * 0.86, f"{form}-upper", sleeve_mat, cap=0.055, wrinkle=0.010, wrinkle_scale=0.04)]
            lower = [tube(-UPPER_ARM + 0.01, -UPPER_ARM - FOREARM - 0.015, r_top * 0.84, r_top * 0.72, f"{form}-lower", sleeve_mat, wrinkle=0.010, wrinkle_scale=0.04)]
            if form in ("knit", "longSleeveTee"):
                cuff = [ellipse(0, -UPPER_ARM - FOREARM + 0.04, r_top * 0.66, r_top * 0.62), ellipse(0, -UPPER_ARM - FOREARM - 0.012, r_top * 0.64, r_top * 0.6)]
                lower.append(loft(cuff, f"{form}-cuff", self.knit, subdiv=1, solid=0.006))
            if form == "shirt":
                cuff = [ellipse(0, -UPPER_ARM - FOREARM + 0.05, r_top * 0.7, r_top * 0.66), ellipse(0, -UPPER_ARM - FOREARM - 0.012, r_top * 0.7, r_top * 0.66)]
                lower.append(loft(cuff, "shirt-cuff", mat, subdiv=1, solid=0.004))
                lower.append(button("shirt-cuffbtn", self.button_mat, (0.02, -r_top * 0.7, -UPPER_ARM - FOREARM + 0.02), r=0.005))
            if form in ("jacket", "coat"):
                for i in range(3):
                    lower.append(button(f"{form}-sbtn{i}", self.horn, (0.035, -r_top * 0.62, -UPPER_ARM - FOREARM + 0.03 + i * 0.022), r=0.006))
            parts["lowerSleeve"] = lower
        return parts

    # Bottoms ----------------------------------------------------------
    def bottom(self, form):
        mat = self.denim if form in ("jeans", "shorts") else self.cotton
        waist_z = HIP[1] + 0.085
        crotch_z = HIP[1] - 0.115
        parts = {}
        if form == "skirt":
            rings = [ellipse(0, waist_z, 0.158, 0.112), ellipse(0, HIP[1], 0.178, 0.124)]
            for k in range(1, 5):
                z = HIP[1] - 0.12 * k
                rings.append(ellipse(0, z, 0.185 + 0.025 * k, 0.13 + 0.012 * k))
            seat = [loft(rings, "skirt-body", mat, wrinkle=0.006)]
            seat.append(loft([ellipse(0, waist_z + 0.03, 0.156, 0.11), ellipse(0, waist_z, 0.158, 0.112)], "skirt-band", mat, subdiv=1, solid=0.006))
            parts["seat"] = seat
            return parts
        rings = [ellipse(0, waist_z, 0.162, 0.115), ellipse(0, HIP[1], 0.182, 0.128), ellipse(0, crotch_z + 0.02, 0.188, 0.122)]
        seat = [loft(rings, f"{form}-seat", mat, wrinkle=0.004)]
        seat.append(loft([ellipse(0, waist_z + 0.038, 0.160, 0.113), ellipse(0, waist_z, 0.163, 0.116)], f"{form}-band", mat, subdiv=1, solid=0.006))
        seat.append(button(f"{form}-waistbtn", self.metal if form in ("jeans", "shorts") else self.button_mat, (0, -0.122, waist_z + 0.018), r=0.008))
        if form in ("jeans", "shorts"):
            seat.append(stitch_line(f"{form}-fly", self.stitch, [(0.02, -0.125, waist_z), (0.02, -0.126, crotch_z + 0.06), (0.0, -0.125, crotch_z + 0.03)]))
            for side in (-1, 1):
                seat.append(stitch_line(f"{form}-pocket{side}", self.stitch, [(side * 0.14, -0.105, waist_z), (side * 0.11, -0.118, waist_z - 0.06), (side * 0.07, -0.123, waist_z - 0.075)]))
            for x in (-0.12, -0.05, 0.05, 0.12):
                seat.append(box(f"{form}-loop{x}", mat, (x, -0.123, waist_z + 0.018), (0.01, 0.003, 0.04), bevel=0.001, subdiv=1))
        parts["seat"] = seat
        r_hip = 0.098
        if form == "shorts":
            parts["thigh"] = [tube(0.03, -THIGH * 0.55, r_hip, r_hip * 0.94, "shorts-leg", mat, wrinkle=0.004)]
            return parts
        parts["thigh"] = [tube(0.03, -THIGH - 0.02, r_hip, r_hip * 0.72, f"{form}-thigh", mat, wrinkle=0.010, wrinkle_scale=0.05)]
        shin = [tube(-THIGH + 0.01, -THIGH - SHIN - 0.03, r_hip * 0.74, r_hip * (0.66 if form == "jeans" else 0.68), f"{form}-shin", mat, wrinkle=0.010, wrinkle_scale=0.05)]
        if form == "trousers":
            # Pressed crease: a thin raised ridge down the front.
            shin.append(box("trousers-crease", mat, (0, -r_hip * 0.66, -THIGH - SHIN / 2), (0.003, 0.004, SHIN), bevel=0.001, subdiv=1))
            parts["thigh"].append(box("trousers-crease-t", mat, (0, -r_hip * 0.8, -THIGH / 2), (0.003, 0.004, THIGH), bevel=0.001, subdiv=1))
        if form == "jeans":
            shin.append(stitch_line("jeans-outseam", self.stitch, [(r_hip * 0.7, -0.02, -THIGH), (r_hip * 0.64, -0.02, -THIGH - SHIN)]))
        parts["shin"] = shin
        return parts

    # Shoes ------------------------------------------------------------
    def shoe(self, form):
        upper_mat = self.leather if form in ("boots", "loafers") else self.cotton
        parts = []
        if form == "sneakers":
            parts.append(box("sneaker-upper", upper_mat, (0, -0.035, 0.045), (0.095, 0.27, 0.075), bevel=0.03))
            parts.append(box("sneaker-sole", self.sole_white, (0, -0.035, 0.012), (0.104, 0.285, 0.026), bevel=0.01))
            for i in range(4):
                parts.append(box(f"sneaker-lace{i}", self.lace, (0, -0.10 - i * 0.003, 0.075 - i * 0.005), (0.05, 0.006, 0.006), bevel=0.002, subdiv=1))
        elif form == "boots":
            parts.append(box("boot-shaft", upper_mat, (0, 0.03, 0.12), (0.10, 0.12, 0.17), bevel=0.03))
            parts.append(box("boot-foot", upper_mat, (0, -0.05, 0.05), (0.10, 0.25, 0.08), bevel=0.035))
            parts.append(box("boot-sole", self.sole_dark, (0, -0.04, 0.012), (0.106, 0.27, 0.026), bevel=0.008))
        else:
            parts.append(box("loafer-upper", upper_mat, (0, -0.04, 0.038), (0.094, 0.27, 0.058), bevel=0.028))
            parts.append(box("loafer-sole", self.sole_dark, (0, -0.04, 0.009), (0.098, 0.28, 0.018), bevel=0.006))
            parts.append(box("loafer-strap", upper_mat, (0, -0.11, 0.066), (0.07, 0.03, 0.012), bevel=0.004, subdiv=1))
        return {"shoe": parts}


# ---------------------------------------------------------------- rendering

def visible_only(objs, scene):
    keep = set(o.name for o in objs)
    for o in scene.objects:
        if o.type in ("MESH", "CURVE"):
            o.hide_render = o.name not in keep


def frame_camera(scene, objs, extra_points=()):
    """Fits the ortho camera to the objects' front bounding box (plus margin) at PX_PER_M."""
    bpy.context.view_layer.update()
    depsgraph = bpy.context.evaluated_depsgraph_get()
    xs, zs = [], []
    for o in objs:
        if o.type != "MESH":
            continue  # stitch curves lie on the garment; their bounds are not reliable after copying
        ev = o.evaluated_get(depsgraph)
        for corner in ev.bound_box:
            w = ev.matrix_world @ Vector(corner)
            xs.append(w.x)
            zs.append(w.z)
    for (x, z) in extra_points:
        xs.append(x)
        zs.append(z)
    x0, x1 = min(xs) - MARGIN, max(xs) + MARGIN
    z0, z1 = min(zs) - MARGIN, max(zs) + MARGIN
    w, h = x1 - x0, z1 - z0
    cam = scene.camera
    cam.location = ((x0 + x1) / 2, -4.0, (z0 + z1) / 2)
    cam.data.ortho_scale = max(w, h)
    scene.render.resolution_x = max(8, round(w * PX_PER_M))
    scene.render.resolution_y = max(8, round(h * PX_PER_M))
    # Ortho scale applies to the larger side; set sensor fit accordingly.
    cam.data.sensor_fit = "HORIZONTAL" if w >= h else "VERTICAL"
    return x0, z1


def to_px(scene, point3):
    v = world_to_camera_view(scene, scene.camera, Vector(point3))
    return [round(v.x * scene.render.resolution_x, 1), round((1 - v.y) * scene.render.resolution_y, 1)]


def render_layers(scene, objs, path_base):
    """Writes <base>-fabric.png (tintable) and, if any trims, <base>-fixed.png."""
    fixed = [o for o in objs if o.active_material and o.active_material.get("fixed")]
    fabric = [o for o in objs if o not in fixed]
    files = {}
    for layer, show, hold in (("fabric", fabric, fixed), ("fixed", fixed, fabric)):
        if not show:
            continue
        for o in objs:
            o.is_holdout = o in hold
        scene.render.filepath = f"{path_base}-{layer}.png"
        bpy.ops.render.render(write_still=True)
        files[layer] = os.path.basename(scene.render.filepath)
    for o in objs:
        o.is_holdout = False
    return files


def build_form(form, out, samples):
    scene = reset()
    scene.cycles.samples = samples
    b = Builder()
    if form in ("tee", "longSleeveTee", "knit", "shirt", "jacket", "coat"):
        parts = b.top(form)
        family = "top"
    elif form in ("trousers", "jeans", "shorts", "skirt"):
        parts = b.bottom(form)
        family = "bottom"
    else:
        parts = b.shoe(form)
        family = "shoe"

    spec = {"form": form, "family": family, "pxPerMetre": PX_PER_M, "parts": {}}
    for name, objs in parts.items():
        visible_only(objs, scene)
        if name == "torso":
            a3, b3 = (0, 0, SHOULDER[1]), (0, 0, HIP[1])
            ref = [(-SHOULDER[0], 0, SHOULDER[1]), (SHOULDER[0], 0, SHOULDER[1])]
        elif name == "upperSleeve":
            a3, b3 = (0, 0, 0), (0, 0, -UPPER_ARM)
            ref = None
        elif name == "lowerSleeve":
            a3, b3 = (0, 0, -UPPER_ARM), (0, 0, -UPPER_ARM - FOREARM)
            ref = None
        elif name == "seat":
            a3, b3 = (0, 0, HIP[1]), (0, 0, HIP[1] - THIGH)
            ref = [(-HIP[0], 0, HIP[1]), (HIP[0], 0, HIP[1])]
        elif name == "thigh":
            a3, b3 = (0, 0, 0), (0, 0, -THIGH)
            ref = None
        elif name == "shin":
            a3, b3 = (0, 0, -THIGH), (0, 0, -THIGH - SHIN)
            ref = None
        else:  # shoe: ankle above the heel, toe towards the camera
            a3, b3 = (0, 0.06, 0.11), (0, 0.06, 0.0)
            ref = None
        frame_camera(scene, objs, extra_points=[(a3[0], a3[2]), (b3[0], b3[2])])
        files = render_layers(scene, objs, os.path.join(out, f"{form}-{name}"))
        entry = {
            "size": [scene.render.resolution_x, scene.render.resolution_y],
            "a": to_px(scene, a3),
            "b": to_px(scene, b3),
            "files": files,
        }
        if ref:
            p, q = to_px(scene, ref[0]), to_px(scene, ref[1])
            entry["refWidth"] = round(abs(q[0] - p[0]), 1)
        spec["parts"][name] = entry

    # Whole garment for cards: parts placed on the rest skeleton.
    every = []
    for name, objs in parts.items():
        for o in objs:
            if name in ("upperSleeve", "lowerSleeve"):
                for side in (-1, 1):
                    dup = o.copy()
                    dup.data = o.data.copy() if o.data else None
                    scene.collection.objects.link(dup)
                    dup.rotation_euler = (0, side * -math.radians(11), 0)
                    dup.location = (side * (SHOULDER[0] + 0.018), 0, SHOULDER[1] - 0.02)
                    every.append(dup)
                o.hide_render = True
            elif name in ("thigh", "shin"):
                for side in (-1, 1):
                    dup = o.copy()
                    dup.data = o.data.copy() if o.data else None
                    scene.collection.objects.link(dup)
                    dup.location = (side * (HIP[0] + 0.012), 0, HIP[1])
                    every.append(dup)
                o.hide_render = True
            elif name == "shoe":
                # A pair in profile, the far shoe a little behind and higher, toes to the right.
                for k, (dx, dz) in enumerate(((0.0, 0.0), (-0.07, 0.035))):
                    dup = o.copy()
                    dup.data = o.data.copy() if o.data else None
                    scene.collection.objects.link(dup)
                    dup.location = (dx, 0.12 * k, dz)
                    dup.rotation_euler = (0, 0, math.radians(90))
                    every.append(dup)
                o.hide_render = True
            else:
                every.append(o)
    visible_only(every, scene)
    bpy.context.view_layer.update()
    frame_camera(scene, every)
    files = render_layers(scene, every, os.path.join(out, f"{form}-thumb"))
    spec["thumb"] = {"size": [scene.render.resolution_x, scene.render.resolution_y], "files": files}
    return spec


# ---------------------------------------------------------------- mannequin (simulator fixture)

def build_mannequin(path, variant=None):
    """A plain human figure (no face, no identity) for the Simulator mirror fixture and the V37 self-model
    fixtures. `variant` changes skin, hair, clothes and an optional fictional wordmark on the chest; every
    value is ours, so the render stays OWNED_ORIGINAL with known ground truth."""
    v = variant or {}
    scene = reset()
    scene.cycles.samples = 64
    skin = fixed_material("skin", tuple(v.get("skin", (0.62, 0.47, 0.38))), rough=0.6)
    cloth = fixed_material("base", tuple(v.get("top", (0.34, 0.35, 0.37))), rough=0.85)
    lower = fixed_material("lower", tuple(v.get("bottom", v.get("top", (0.34, 0.35, 0.37)))), rough=0.85)
    hair = fixed_material("hair", tuple(v.get("hair", (0.08, 0.06, 0.05))), rough=0.7)
    shoe = fixed_material("shoe", tuple(v.get("shoe", v.get("hair", (0.08, 0.06, 0.05)))), rough=0.6)
    eye = fixed_material("eye", (0.05, 0.04, 0.04), rough=0.5)
    long_sleeve = v.get("sleeve", "short") == "long"
    shorts = v.get("lower", "trousers") == "shorts"

    def capsule(a, b, r0, r1, mat, name):
        a, b = Vector(a), Vector(b)
        bpy.ops.mesh.primitive_cylinder_add(radius=1, depth=1, vertices=32)
        o = bpy.context.active_object
        o.name = name
        mid = (a + b) / 2
        o.location = mid
        d = b - a
        o.rotation_euler = d.to_track_quat("Z", "Y").to_euler()
        o.scale = (r0, r0, d.length)
        bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
        # taper
        for v in o.data.vertices:
            t = v.co.z / d.length + 0.5
            k = (r0 + (r1 - r0) * t) / r0
            v.co.x *= k
            v.co.y *= k
        o.data.materials.append(mat)
        for end, r in ((a, r0), (b, r1)):
            bpy.ops.mesh.primitive_uv_sphere_add(radius=r, location=end)
            s = bpy.context.active_object
            s.data.materials.append(mat)
            for p in s.data.polygons:
                p.use_smooth = True
        for p in o.data.polygons:
            p.use_smooth = True
        return o

    sx, sz = SHOULDER
    hx, hz = HIP
    # Torso (fitted base layer), neck, head with hair.
    rings = torso_rings(0.86, 0.165, ease=0.92)
    t = loft(rings, "body-torso", cloth, closed_top=True, wrinkle=0.0)
    capsule((0, 0, NECK_Z - 0.03), (0, 0, NECK_Z + 0.07), 0.055, 0.05, skin, "neck")
    bpy.ops.mesh.primitive_uv_sphere_add(radius=0.105, location=(0, 0, 1.64))
    head = bpy.context.active_object
    head.scale = (0.86, 0.95, 1.08)
    head.data.materials.append(skin)
    for p in head.data.polygons:
        p.use_smooth = True
    bpy.ops.mesh.primitive_uv_sphere_add(radius=0.108, location=(0, 0.012, 1.675))
    hr = bpy.context.active_object
    hr.scale = (0.9, 0.98, 0.95)
    hr.data.materials.append(hair)
    if v.get("hairLong"):
        bpy.ops.mesh.primitive_uv_sphere_add(radius=0.1, location=(0, 0.045, 1.56))
        back = bpy.context.active_object
        back.scale = (1.0, 0.55, 1.55)
        back.data.materials.append(hair)
    # Simple eyes and nose shading so a face reads as a face (no identity).
    for side in (-1, 1):
        bpy.ops.mesh.primitive_uv_sphere_add(radius=0.011, location=(side * 0.035, -0.088, 1.655))
        bpy.context.active_object.data.materials.append(eye)
    capsule((0, -0.095, 1.645), (0, -0.104, 1.62), 0.012, 0.014, skin, "nose")
    # Arms slightly away from the body, legs apart.
    for side in (-1, 1):
        sh = (side * sx, 0, sz)
        el = (side * (sx + 0.06), 0, sz - UPPER_ARM)
        wr = (side * (sx + 0.10), -0.02, sz - UPPER_ARM - FOREARM)
        capsule(sh, el, 0.052, 0.043, cloth, f"upperarm{side}")
        capsule(el, wr, 0.040, 0.032, cloth if long_sleeve else skin, f"forearm{side}")
        bpy.ops.mesh.primitive_uv_sphere_add(radius=0.045, location=(wr[0] + side * 0.01, -0.02, wr[2] - 0.06))
        hand = bpy.context.active_object
        hand.scale = (0.6, 0.35, 1.0)
        hand.data.materials.append(skin)
        hp = (side * hx, 0, hz)
        kn = (side * (hx + 0.015), 0, hz - THIGH)
        an = (side * (hx + 0.03), 0, hz - THIGH - SHIN)
        capsule(hp, kn, 0.085, 0.058, lower, f"thigh{side}")
        capsule(kn, an, 0.055, 0.040, skin if shorts else lower, f"shin{side}")
        bpy.ops.mesh.primitive_cube_add(size=1, location=(an[0], -0.05, 0.04))
        foot = bpy.context.active_object
        foot.scale = (0.09, 0.24, 0.07)
        foot.data.materials.append(shoe)
    if v.get("wordmark"):
        bpy.ops.object.text_add(location=(0, -0.2, 1.30), rotation=(math.radians(90), 0, 0))
        txt = bpy.context.active_object
        txt.data.body = v["wordmark"]
        txt.data.align_x = "CENTER"
        txt.data.size = 0.05
        txt.data.extrude = 0.002
        txt.data.materials.append(fixed_material("mark", tuple(v.get("markColour", (0.96, 0.96, 0.95))), rough=0.5))
    # Room: a soft wall and floor behind the person, like a mirror at home.
    bpy.ops.mesh.primitive_plane_add(size=8, location=(0, 1.2, 1.5), rotation=(math.radians(90), 0, 0))
    bpy.context.active_object.data.materials.append(fixed_material("wall", (0.78, 0.74, 0.68), rough=0.9))
    bpy.ops.mesh.primitive_plane_add(size=8, location=(0, 0, 0))
    bpy.context.active_object.data.materials.append(fixed_material("floor", (0.55, 0.45, 0.36), rough=0.6))
    scene.render.film_transparent = False
    cam = scene.camera
    cam.data.type = "PERSP"
    cam.data.lens = 24
    cam.location = (0, -2.35, 1.0)
    cam.data.lens = 22
    cam.rotation_euler = (math.radians(90), 0, 0)
    scene.render.resolution_x = 720
    scene.render.resolution_y = 1280
    scene.render.image_settings.file_format = "JPEG"
    scene.render.image_settings.quality = 85
    scene.view_settings.view_transform = "AgX"
    scene.render.filepath = path
    bpy.ops.render.render(write_still=True)
    print("WROTE", path)


def main():
    a = args()
    if a.mannequin:
        build_mannequin(a.mannequin, json.loads(a.variant))
        return
    os.makedirs(a.out, exist_ok=True)
    specs = {}
    for form in a.forms.split(","):
        specs[form] = build_form(form, a.out, a.samples)
        print("FORM", form, json.dumps(specs[form]["parts"].keys().__repr__()))
    manifest = os.path.join(a.out, "garments.json")
    old = {}
    if os.path.exists(manifest):
        with open(manifest) as f:
            old = json.load(f).get("forms", {})
    old.update(specs)
    with open(manifest, "w") as f:
        json.dump({"provenance": "OWNED_ORIGINAL", "generator": "tools/garments/build_garment_sprites.py",
                   "forms": old}, f, indent=1, sort_keys=True)
    print("WROTE", manifest)


if __name__ == "__main__":
    main()
