"""Real-time 3D city for the Kabinsiz home world (v2.8 UI28-05, §06).

Builds the same owned street as build_city_scene.py (every mesh, material and light from primitives
in that file: provenance OWNED_ORIGINAL, no photo, map data or scanned model), then turns it into an
asset RealityKit draws in real time behind the figure:

  1. Static geometry is joined into four groups (ground, left, right, far) and sliced so that large
     faces get enough vertices for texel-density control.
  2. Each group gets a lightmap-style UV atlas. Before unwrapping, vertices are pulled towards the
     app camera (distance compressed as d0 * (d / d0) ** ALPHA), so surfaces near the camera get
     many more texels than the end of the street. Faces the camera can never see (outside a widened
     frustum or facing away) are shrunk to almost nothing in the atlas.
  3. Cycles bakes the full lighting (direct + indirect, lamps, emissive windows, wet reflections seen
     from the app camera) plus the atmospheric haze of the 2D renders into each atlas. The image is
     saved through the scene's view transform (AgX), so the app shows it unlit and unchanged.
  4. Invisible faces are dropped and the groups are exported as one USDZ (Y up, metres) whose
     materials carry the baked image as emission over black, so Quick Look shows it as the app does.
  5. The wet variant is baked onto the identical UV layout. Both variants also ship as JPEGs next to
     the USDZ; the app loads the set for the current surface state and drops the other.

The lighting is precomputed ("baked") for the app camera; geometry, depth, occlusion, parallax and
rain are real-time. The app must say so and never call the 2D render "3D".

Usage (headless, about 10-20 min per city on an M5 GPU at full quality):
  Blender -b --python tools/scenes/build_city_usdz.py -- --city istanbul --out apps/ios/Kabinsiz/Features/World/City
  [--atlas 2048] [--samples 256] [--quick]
"""

import argparse
import hashlib
import json
import math
import os
import random
import sys
import time

import bmesh
import bpy
import mathutils.kdtree
from mathutils import Vector

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import build_city_scene as street  # noqa: E402

CAM = Vector((0.0, -street.CAMERA_DISTANCE, street.CAMERA_HEIGHT))
# Texel density control: no compression inside D0, beyond it distance grows as d ** ALPHA.
D0 = 4.0
ALPHA = 0.32
# Widened frustum for "can the camera ever see this face" (portrait phone FOV + zoom-out margin + parallax).
HALF_H = math.radians(30)
HALF_V = math.radians(36)
GROUPS = ("ground", "left", "right", "far")
# The street floor in front of and around the figure gets its own atlas: it fills most of the screen.
NEAR_Y = 13.0
FAR_PREFIXES = ("tower", "gallery", "drum", "cone", "twin", "hill", "spire")
GROUND_PREFIXES = ("Plane", "walk", "zebra")


def args():
    argv = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
    p = argparse.ArgumentParser()
    p.add_argument("--city", choices=["istanbul", "barcelona"], required=True)
    p.add_argument("--out", required=True)
    p.add_argument("--work", default="build/city")
    p.add_argument("--atlas", type=int, default=2048)
    p.add_argument("--samples", type=int, default=256)
    p.add_argument("--quick", action="store_true", help="tiny atlases and few samples, for pipeline checks")
    return p.parse_args(argv)


def log(*parts):
    print("[city]", *parts, flush=True)


# ---------------------------------------------------------------- scene preparation

def select_only(objs, active=None):
    if bpy.context.object and bpy.context.object.mode != "OBJECT":
        bpy.ops.object.mode_set(mode="OBJECT")
    for o in bpy.context.view_layer.objects:
        o.select_set(False)
    for o in objs:
        o.select_set(True)
    bpy.context.view_layer.objects.active = active or (objs[0] if objs else None)


def classify(o):
    name = o.name
    if name.startswith(GROUND_PREFIXES):
        return "ground"
    corners = [o.matrix_world @ Vector(c) for c in o.bound_box]
    cy = sum(c.y for c in corners) / 8
    cx = sum(c.x for c in corners) / 8
    if name.startswith(FAR_PREFIXES) or cy > 95:
        return "far"
    return "left" if cx < 0 else "right"


def geometric_cuts(start, first, ratio, end):
    cuts, step, x = [], first, start
    while x < end:
        cuts.append(x)
        x += step
        step *= ratio
    return cuts


def slice_mesh(obj):
    """Cut big faces along y (spacing grows with distance), z and x so the density warp has vertices."""
    bm = bmesh.new()
    bm.from_mesh(obj.data)
    planes = [((0, y, 0), (0, 1, 0)) for y in geometric_cuts(CAM.y + 0.6, 0.8, 1.12, 260)]
    planes += [((0, 0, z), (0, 0, 1)) for z in geometric_cuts(0.6, 0.8, 1.18, 70)]
    planes += [((x, 0, 0), (1, 0, 0)) for x in (-6, -4.5, -3.2, -2.2, -1.4, -0.7, 0, 0.7, 1.4, 2.2, 3.2, 4.5, 6)]
    for co, no in planes:
        big = [f for f in bm.faces if f.calc_area() > 0.6]
        if not big:
            break
        # Ordered de-duplication (not a set): the result must be identical between the dry and wet passes.
        geom = list(dict.fromkeys(v for f in big for v in f.verts)) + list(dict.fromkeys(e for f in big for e in f.edges)) + big
        bmesh.ops.bisect_plane(bm, geom=geom, plane_co=co, plane_no=no)
    bm.to_mesh(obj.data)
    bm.free()


def join_groups():
    """Realise modifiers, decimate tree crowns, join static geometry per group, slice it."""
    meshes = [o for o in bpy.context.scene.objects if o.type == "MESH"]
    for o in meshes:
        if o.name.startswith("crown"):
            d = o.modifiers.new("lod", "DECIMATE")
            d.ratio = 0.3
    select_only(meshes)
    bpy.ops.object.convert(target="MESH")
    bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)
    by_group = {g: [] for g in GROUPS}
    for o in sorted(meshes, key=lambda o: o.name):
        by_group[classify(o)].append(o)
    joined = {}
    for g, objs in by_group.items():
        if not objs:
            continue
        select_only(objs, objs[0])
        bpy.ops.object.join()
        o = bpy.context.view_layer.objects.active
        o.name = f"city_{g}"
        o.data.name = f"city_{g}"
        slice_mesh(o)
        joined[g] = o
        if g == "ground":
            joined["near"] = split_near(o)
    for g, o in joined.items():
        log(g, "faces", len(o.data.polygons))
    return joined


def split_near(ground):
    """Move the floor faces nearer than NEAR_Y into their own object (city_near)."""
    select_only([ground])
    for p in ground.data.polygons:
        p.select = (ground.matrix_world @ p.center).y < NEAR_Y
    bpy.ops.object.mode_set(mode="EDIT")
    bpy.ops.mesh.separate(type="SELECTED")
    bpy.ops.object.mode_set(mode="OBJECT")
    near = next(o for o in bpy.context.selected_objects if o != ground)
    near.name = "city_near"
    near.data.name = "city_near"
    return near


# ---------------------------------------------------------------- visibility and UVs

def face_hidden(center, normal, verts):
    """True when no camera pose the app allows can see the face."""
    to_face = center - CAM
    if to_face.length > 1e-6 and normal.dot(to_face.normalized()) > 0.03:
        return True  # faces away from the camera (roofs, back walls)
    tan_h, tan_v = math.tan(HALF_H), math.tan(HALF_V)
    left = right = below = above = behind = 0
    for v in verts:
        d = v - CAM
        depth = d.y
        if depth < 0.05:
            behind += 1
            continue
        if d.x < -depth * tan_h - 0.4:
            left += 1
        elif d.x > depth * tan_h + 0.4:
            right += 1
        if d.z < -depth * tan_v - 0.3:
            below += 1
        elif d.z > depth * tan_v + 0.3:
            above += 1
    n = len(verts)
    return behind == n or left + behind == n or right + behind == n or below + behind == n or above + behind == n


def hidden_faces(obj):
    me = obj.data
    mw = obj.matrix_world
    hidden = []
    for p in me.polygons:
        verts = [mw @ me.vertices[i].co for i in p.vertices]
        hidden.append(face_hidden(mw @ p.center, (mw.to_3x3() @ p.normal).normalized(), verts))
    return hidden


def lightmap_uv(obj, hidden):
    me = obj.data
    while me.uv_layers:
        me.uv_layers.remove(me.uv_layers[0])
    me.uv_layers.new(name="st")
    original = [v.co.copy() for v in me.vertices]
    for v in me.vertices:
        d = v.co - CAM
        r = d.length
        if r > D0:
            v.co = CAM + d * (D0 * (r / D0) ** ALPHA / r)
    select_only([obj])
    bpy.ops.object.mode_set(mode="EDIT")
    bpy.ops.mesh.select_all(action="SELECT")
    bpy.ops.uv.smart_project(angle_limit=math.radians(60), island_margin=0.0015, area_weight=0.0,
                             correct_aspect=True, scale_to_bounds=False)
    bpy.ops.object.mode_set(mode="OBJECT")
    for v, co in zip(me.vertices, original):
        v.co = co
    # Faces nobody can see keep a speck of atlas, so the bake still has a target but wastes nothing.
    uv = me.uv_layers["st"].data
    for p, h in zip(me.polygons, hidden):
        if not h:
            continue
        loops = list(p.loop_indices)
        cu = sum((uv[i].uv for i in loops), Vector((0, 0))) / len(loops)
        for i in loops:
            uv[i].uv = cu + (uv[i].uv - cu) * 0.02
    select_only([obj])
    bpy.ops.object.mode_set(mode="EDIT")
    bpy.ops.mesh.select_all(action="SELECT")
    bpy.ops.uv.select_all(action="SELECT")
    bpy.ops.uv.pack_islands(rotate=True, scale=True, margin=0.002)
    bpy.ops.object.mode_set(mode="OBJECT")


def vkey(co):
    return (round(co.x, 3), round(co.y, 3), round(co.z, 3))


def uv_table(obj):
    """UVs keyed by face and vertex position, so the wet pass can reuse the dry layout whatever the face order.
    Faces whose slicing produced float noise are matched by nearest centroid instead (see apply_uv_table)."""
    me = obj.data
    uv = me.uv_layers["st"].data
    exact, faces = {}, []
    for p in me.polygons:
        corners = [(me.vertices[v].co.copy(), tuple(uv[li].uv)) for li, v in zip(p.loop_indices, p.vertices)]
        exact[tuple(sorted(vkey(co) for co, _ in corners))] = {vkey(co): t for co, t in corners}
        faces.append((p.center.copy(), corners))
    tree = mathutils.kdtree.KDTree(len(faces))
    for i, (c, _) in enumerate(faces):
        tree.insert(c, i)
    tree.balance()
    return {"exact": exact, "faces": faces, "tree": tree}


def apply_uv_table(obj, table):
    me = obj.data
    while me.uv_layers:
        me.uv_layers.remove(me.uv_layers[0])
    me.uv_layers.new(name="st")
    uv = me.uv_layers["st"].data
    missing = 0
    for p in me.polygons:
        keys = [vkey(me.vertices[v].co) for v in p.vertices]
        corners = table["exact"].get(tuple(sorted(keys)))
        if corners is not None:
            for li, k in zip(p.loop_indices, keys):
                uv[li].uv = corners[k]
            continue
        _, i, dist = table["tree"].find(p.center)
        if i is None or dist > 0.02:
            missing += 1
            continue
        dry = table["faces"][i][1]
        for li, v in zip(p.loop_indices, p.vertices):
            co = me.vertices[v].co
            uv[li].uv = min(dry, key=lambda c: (c[0] - co).length_squared)[1]
    return missing


def density_report(obj, atlas, hidden):
    """Texels per metre at a few distances from the camera (visible faces only)."""
    me = obj.data
    uv = me.uv_layers["st"].data
    buckets = {}
    for p, h in zip(me.polygons, hidden):
        if h or p.area < 1e-4:
            continue
        loops = list(p.loop_indices)
        a = 0.0
        for k in range(1, len(loops) - 1):
            u0, u1, u2 = uv[loops[0]].uv, uv[loops[k]].uv, uv[loops[k + 1]].uv
            a += abs((u1 - u0).cross(u2 - u0)) / 2
        d = (p.center - CAM).length
        b = min(int(d // 4) * 4, 40)
        s = buckets.setdefault(b, [0.0, 0.0])
        s[0] += a * atlas * atlas
        s[1] += p.area
    return {f"{b}-{b + 4}m": round(math.sqrt(t / w), 1) for b, (t, w) in sorted(buckets.items()) if w > 0.05}


# ---------------------------------------------------------------- bake

def add_haze(mat, color, amount, start, depth):
    """Atmospheric perspective of the 2D renders' mist pass, as a shader mix the bake can capture."""
    if not mat.use_nodes:
        return
    nt = mat.node_tree
    out = next((n for n in nt.nodes if n.type == "OUTPUT_MATERIAL"), None)
    if out is None or not out.inputs["Surface"].links:
        return
    surface = out.inputs["Surface"].links[0].from_socket
    geo = nt.nodes.new("ShaderNodeNewGeometry")
    dist = nt.nodes.new("ShaderNodeVectorMath")
    dist.operation = "DISTANCE"
    dist.inputs[1].default_value = CAM
    nt.links.new(geo.outputs["Position"], dist.inputs[0])
    rng = nt.nodes.new("ShaderNodeMapRange")
    rng.inputs["From Min"].default_value = start
    rng.inputs["From Max"].default_value = start + depth
    nt.links.new(dist.outputs["Value"], rng.inputs["Value"])
    sq = nt.nodes.new("ShaderNodeMath")
    sq.operation = "POWER"
    sq.inputs[1].default_value = 2.0
    nt.links.new(rng.outputs["Result"], sq.inputs[0])
    amt = nt.nodes.new("ShaderNodeMath")
    amt.operation = "MULTIPLY"
    amt.inputs[1].default_value = amount
    nt.links.new(sq.outputs["Value"], amt.inputs[0])
    emit = nt.nodes.new("ShaderNodeEmission")
    emit.inputs["Color"].default_value = (*color, 1)
    mix = nt.nodes.new("ShaderNodeMixShader")
    nt.links.new(amt.outputs["Value"], mix.inputs["Fac"])
    nt.links.new(surface, mix.inputs[1])
    nt.links.new(emit.outputs["Emission"], mix.inputs[2])
    nt.links.new(mix.outputs["Shader"], out.inputs["Surface"])


def setup_render(scene, city, samples):
    prefs = bpy.context.preferences.addons["cycles"].preferences
    prefs.compute_device_type = "METAL"
    prefs.get_devices()
    for d in prefs.devices:
        d.use = d.type == "METAL"
    scene.render.engine = "CYCLES"
    scene.cycles.device = "GPU"
    scene.cycles.samples = samples
    scene.cycles.sample_clamp_indirect = 4.0
    scene.cycles.max_bounces = 6
    scene.view_settings.view_transform = "AgX"
    scene.view_settings.look = "AgX - Medium High Contrast"
    scene.view_settings.exposure = -0.1 if city == "barcelona" else -0.55
    scene.render.image_settings.file_format = "JPEG"
    scene.render.image_settings.quality = 90
    bake = scene.render.bake
    bake.use_pass_direct = True
    bake.use_pass_indirect = True
    bake.use_pass_diffuse = True
    bake.use_pass_glossy = True
    bake.use_pass_transmission = True
    bake.use_pass_emit = True
    bake.margin = 8
    bake.margin_type = "EXTEND"
    bake.view_from = "ACTIVE_CAMERA"
    bake.target = "IMAGE_TEXTURES"
    bake.use_clear = True


def bake_group(obj, image, kind="COMBINED"):
    for slot in obj.material_slots:
        m = slot.material
        if m is None or not m.use_nodes:
            continue
        node = m.node_tree.nodes.get("BAKE_TARGET") or m.node_tree.nodes.new("ShaderNodeTexImage")
        node.name = "BAKE_TARGET"
        node.image = image
        m.node_tree.nodes.active = node
    select_only([obj])
    bpy.ops.object.bake(type=kind)


def save_baked(image, path, scene):
    image.save_render(filepath=path, scene=scene)
    return path


def sky_dome(scene, city, wet):
    """An inward-facing sphere around the camera that shows the scene's sky gradient (no sun disc)."""
    world = scene.world
    ramp = next(n for n in world.node_tree.nodes if n.type == "VALTORGB")
    bg = next(n for n in world.node_tree.nodes if n.type == "BACKGROUND")
    bpy.ops.mesh.primitive_uv_sphere_add(segments=48, ring_count=24, radius=420, location=CAM)
    dome = bpy.context.active_object
    dome.name = "city_sky"
    dome.data.name = "city_sky"
    bpy.ops.object.mode_set(mode="EDIT")
    bpy.ops.mesh.select_all(action="SELECT")
    bpy.ops.mesh.flip_normals()
    bpy.ops.object.mode_set(mode="OBJECT")
    for p in dome.data.polygons:
        p.use_smooth = True
    m = bpy.data.materials.new("sky_emit")
    m.use_nodes = True
    nt = m.node_tree
    for n in list(nt.nodes):
        nt.nodes.remove(n)
    out = nt.nodes.new("ShaderNodeOutputMaterial")
    emit = nt.nodes.new("ShaderNodeEmission")
    emit.inputs["Strength"].default_value = bg.inputs["Strength"].default_value
    geo = nt.nodes.new("ShaderNodeNewGeometry")
    sub = nt.nodes.new("ShaderNodeVectorMath")
    sub.operation = "SUBTRACT"
    sub.inputs[1].default_value = CAM
    nt.links.new(geo.outputs["Position"], sub.inputs[0])
    norm = nt.nodes.new("ShaderNodeVectorMath")
    norm.operation = "NORMALIZE"
    nt.links.new(sub.outputs["Vector"], norm.inputs[0])
    sep = nt.nodes.new("ShaderNodeSeparateXYZ")
    nt.links.new(norm.outputs["Vector"], sep.inputs["Vector"])
    r2 = nt.nodes.new("ShaderNodeValToRGB")
    for k, e in enumerate(ramp.color_ramp.elements):
        if k >= len(r2.color_ramp.elements):
            r2.color_ramp.elements.new(e.position)
        r2.color_ramp.elements[k].position = e.position
        r2.color_ramp.elements[k].color = e.color
    nt.links.new(sep.outputs["Z"], r2.inputs["Fac"])
    nt.links.new(r2.outputs["Color"], emit.inputs["Color"])
    nt.links.new(emit.outputs["Emission"], out.inputs["Surface"])
    dome.data.materials.append(m)
    return dome


def visible_only(obj, hidden):
    bm = bmesh.new()
    bm.from_mesh(obj.data)
    bm.faces.ensure_lookup_table()
    bmesh.ops.delete(bm, geom=[bm.faces[i] for i, h in enumerate(hidden) if h], context="FACES")
    bm.to_mesh(obj.data)
    bm.free()


def export_material(name, texture_path):
    m = bpy.data.materials.new(name)
    m.use_nodes = True
    nt = m.node_tree
    for n in list(nt.nodes):
        nt.nodes.remove(n)
    out = nt.nodes.new("ShaderNodeOutputMaterial")
    b = nt.nodes.new("ShaderNodeBsdfPrincipled")
    b.inputs["Base Color"].default_value = (0, 0, 0, 1)
    b.inputs["Roughness"].default_value = 1.0
    b.inputs["Specular IOR Level"].default_value = 0.0
    b.inputs["Emission Strength"].default_value = 1.0
    tex = nt.nodes.new("ShaderNodeTexImage")
    tex.image = bpy.data.images.load(texture_path, check_existing=True)
    nt.links.new(tex.outputs["Color"], b.inputs["Emission Color"])
    nt.links.new(b.outputs["BSDF"], out.inputs["Surface"])
    return m


def sha256(path):
    h = hashlib.sha256()
    with open(path, "rb") as f:
        for chunk in iter(lambda: f.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()


# ---------------------------------------------------------------- passes

def prepare(city, wet):
    rng = random.Random(7 if city == "istanbul" else 11)
    scene = street.build(city, wet, rng)
    haze_color = list(scene["haze_color"])
    haze_amount = float(scene["haze_amount"])
    depth = 140 if city == "istanbul" else 220
    for m in bpy.data.materials:
        add_haze(m, haze_color, haze_amount, 8.0, depth)
    groups = join_groups()
    return scene, groups


def run_pass(a, wet, uv_in=None):
    t0 = time.time()
    weather = "wet" if wet else "dry"
    scene, groups = prepare(a.city, wet)
    atlas = 256 if a.quick else a.atlas
    samples = 16 if a.quick else a.samples
    setup_render(scene, a.city, samples)
    sizes = {"near": atlas, "ground": atlas, "left": atlas, "right": atlas, "far": atlas // 2}
    hidden, uv_out, report, textures = {}, {}, {}, {}
    for g, o in groups.items():
        hidden[g] = hidden_faces(o)
        if uv_in is None:
            lightmap_uv(o, hidden[g])
            uv_out[g] = uv_table(o)
        else:
            missing = apply_uv_table(o, uv_in[g])
            log(weather, g, "faces without a dry match", missing)
            assert missing <= max(2, len(o.data.polygons) // 1000), f"{g}: wet geometry differs from dry"
        report[g] = density_report(o, sizes[g], hidden[g])
        log(weather, g, "texels/m", report[g])
    os.makedirs(a.work, exist_ok=True)
    for g, o in groups.items():
        img = bpy.data.images.new(f"{a.city}-{g}-{weather}", sizes[g], sizes[g], float_buffer=True)
        t = time.time()
        bake_group(o, img)
        path = os.path.join(a.work, f"city-{a.city}-{g}-{weather}.jpg")
        textures[g] = save_baked(img, path, scene)
        log(weather, g, f"baked in {time.time() - t:.0f}s")
    dome = sky_dome(scene, a.city, wet)
    sky_img = bpy.data.images.new(f"{a.city}-sky-{weather}", atlas // 2, atlas // 4, float_buffer=True)
    scene.cycles.samples = 4
    bake_group(dome, sky_img, kind="EMIT")
    textures["sky"] = save_baked(sky_img, os.path.join(a.work, f"city-{a.city}-sky-{weather}.jpg"), scene)
    groups["sky"] = dome
    hidden["sky"] = [False] * len(dome.data.polygons)
    log(weather, f"pass done in {time.time() - t0:.0f}s")
    return scene, groups, hidden, uv_out, textures, report


def export_usdz(a, groups, hidden, textures):
    for g, o in groups.items():
        visible_only(o, hidden[g])
        o.data.materials.clear()
        o.data.materials.append(export_material(f"M_{g}", os.path.abspath(textures[g])))
        for p in o.data.polygons:
            p.material_index = 0
    keep = list(groups.values())
    for o in list(bpy.context.scene.objects):
        if o not in keep:
            bpy.data.objects.remove(o, do_unlink=True)
    select_only(keep)
    os.makedirs(a.out, exist_ok=True)
    path = os.path.abspath(os.path.join(a.out, f"city-{a.city}.usdz"))
    bpy.ops.wm.usd_export(filepath=path, selected_objects_only=True, export_materials=True, generate_preview_surface=True,
                          export_textures_mode="NEW", overwrite_textures=True, convert_orientation=True,
                          export_global_forward_selection="NEGATIVE_Z", export_global_up_selection="Y",
                          export_normals=False, export_lights=False, export_cameras=False, convert_world_material=False,
                          triangulate_meshes=True, export_animation=False, root_prim_path="/city", author_blender_name=False)
    tris = sum(sum(len(p.vertices) - 2 for p in o.data.polygons) for o in keep)
    return path, tris


def main():
    a = args()
    log("city", a.city, "atlas", a.atlas, "samples", a.samples, "quick", a.quick)
    _, groups, hidden, uvs, dry_tex, report = run_pass(a, wet=False)
    usdz, tris = export_usdz(a, groups, hidden, dry_tex)
    log("exported", usdz, "triangles", tris)
    _, _, _, _, wet_tex, _ = run_pass(a, wet=True, uv_in=uvs)
    shipped = {}
    for g, src in list(dry_tex.items()) + list(wet_tex.items()):
        dst = os.path.join(a.out, os.path.basename(src))
        with open(src, "rb") as f, open(dst, "wb") as w:
            w.write(f.read())
        shipped[os.path.basename(dst)] = sha256(dst)
    rights = {
        "schema": "kabinsiz.asset-rights.v1",
        "asset_id": f"city-{a.city}",
        "source_owner": "Kabinsiz (built by tools/scenes from primitives)",
        "provenance": "OWNED_ORIGINAL",
        "licence_document_id": None,
        "commercial_allowed": True,
        "derivative_allowed": True,
        "on_device_distribution_allowed": True,
        "attribution": None,
        "territory": "worldwide",
        "expiry": None,
        "revocation_policy": "not applicable (owned)",
        "third_party_inputs": [],
        "generator": f"tools/scenes/build_city_usdz.py --city {a.city} --atlas {a.atlas} --samples {a.samples}",
        "blender": bpy.app.version_string,
        "lighting": "baked for the app camera (Cycles); geometry, depth and rain are real time",
        "triangles": tris,
        "texels_per_metre": report,
        "artifact_hash": {os.path.basename(usdz): sha256(usdz), **shipped},
        "reviewer": None,
        "approved_at": None,
    }
    with open(os.path.join(a.out, f"city-{a.city}.asset-rights.json"), "w") as f:
        json.dump(rights, f, indent=2, ensure_ascii=False)
    log("done", json.dumps({"usdz_bytes": os.path.getsize(usdz), "triangles": tris}))


main()
