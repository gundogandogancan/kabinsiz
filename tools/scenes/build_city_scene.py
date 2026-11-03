"""Original city street backdrops for the Kabinsiz home world (v2.5 §3, V25-05).

Every object, material and light is built from primitives in this file: no photo, map data,
scanned model or third-party asset is used, so the renders are owned (provenance OWNED_ORIGINAL).
The scenes evoke a city ("Galata çevresi", "Eixample") without claiming to be an exact place.

The camera matches the app's RealityKit camera (WorldStage.swift): horizontal, CAMERA_HEIGHT above
the ground, CAMERA_DISTANCE in front of the spot where the figure stands, vertical field of view
FOV_Y. The figure is drawn by the app at the origin; the backdrop leaves that spot clear.

Usage (headless):
  Blender -b --python tools/scenes/build_city_scene.py -- --city istanbul --weather wet --out out.png [--scale 0.5]
"""

import argparse
import math
import random
import sys

import bpy
from mathutils import Vector

CAMERA_HEIGHT = 0.45
CAMERA_DISTANCE = 3.40
FOV_Y = math.radians(60)
WIDTH, HEIGHT = 1600, 2600


def args():
    argv = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
    p = argparse.ArgumentParser()
    p.add_argument("--city", choices=["istanbul", "barcelona"], required=True)
    p.add_argument("--weather", choices=["dry", "wet"], default="dry")
    p.add_argument("--out", required=True)
    p.add_argument("--scale", type=float, default=1.0)
    p.add_argument("--samples", type=int, default=96)
    return p.parse_args(argv)


# ---------------------------------------------------------------- materials

def node_material(name):
    m = bpy.data.materials.new(name)
    m.use_nodes = True
    nt = m.node_tree
    for n in list(nt.nodes):
        nt.nodes.remove(n)
    out = nt.nodes.new("ShaderNodeOutputMaterial")
    bsdf = nt.nodes.new("ShaderNodeBsdfPrincipled")
    nt.links.new(bsdf.outputs["BSDF"], out.inputs["Surface"])
    return m, nt, bsdf


def plain(name, rgb, rough=0.8, metal=0.0, emit=None, strength=0.0):
    m, nt, b = node_material(name)
    b.inputs["Base Color"].default_value = (*rgb, 1)
    b.inputs["Roughness"].default_value = rough
    b.inputs["Metallic"].default_value = metal
    if emit:
        b.inputs["Emission Color"].default_value = (*emit, 1)
        b.inputs["Emission Strength"].default_value = strength
    return m


def plaster(name, rgb, rough=0.85):
    """Facade plaster with soft noise in colour and bump, so walls are not flat CG colour."""
    m, nt, b = node_material(name)
    tex = nt.nodes.new("ShaderNodeTexNoise")
    tex.inputs["Scale"].default_value = 3.0
    tex.inputs["Detail"].default_value = 8.0
    ramp = nt.nodes.new("ShaderNodeValToRGB")
    ramp.color_ramp.elements[0].color = (rgb[0] * 0.82, rgb[1] * 0.80, rgb[2] * 0.78, 1)
    ramp.color_ramp.elements[1].color = (*rgb, 1)
    nt.links.new(tex.outputs["Fac"], ramp.inputs["Fac"])
    nt.links.new(ramp.outputs["Color"], b.inputs["Base Color"])
    bump = nt.nodes.new("ShaderNodeBump")
    bump.inputs["Strength"].default_value = 0.15
    nt.links.new(tex.outputs["Fac"], bump.inputs["Height"])
    nt.links.new(bump.outputs["Normal"], b.inputs["Normal"])
    b.inputs["Roughness"].default_value = rough
    return m


def asphalt(name, wet):
    m, nt, b = node_material(name)
    geo = nt.nodes.new("ShaderNodeNewGeometry")
    n = nt.nodes.new("ShaderNodeTexNoise")
    nt.links.new(geo.outputs["Position"], n.inputs["Vector"])
    n.inputs["Scale"].default_value = 9.0
    n.inputs["Detail"].default_value = 10.0
    ramp = nt.nodes.new("ShaderNodeValToRGB")
    k = 0.55 if wet else 1.0
    ramp.color_ramp.elements[0].color = (0.14 * k, 0.125 * k, 0.11 * k, 1)
    ramp.color_ramp.elements[1].color = (0.30 * k, 0.27 * k, 0.24 * k, 1)
    nt.links.new(n.outputs["Fac"], ramp.inputs["Fac"])
    nt.links.new(ramp.outputs["Color"], b.inputs["Base Color"])
    b.inputs["Roughness"].default_value = 0.12 if wet else 0.85
    return m


def tiles(name, wet):
    """Square pavement tiles with a soft four-petal relief (a generic hydraulic tile, not a copy)."""
    m, nt, b = node_material(name)
    geo = nt.nodes.new("ShaderNodeNewGeometry")
    mapping = nt.nodes.new("ShaderNodeMapping")
    mapping.inputs["Scale"].default_value = (5, 5, 1)
    nt.links.new(geo.outputs["Position"], mapping.inputs["Vector"])
    brick = nt.nodes.new("ShaderNodeTexBrick")
    brick.offset = 0.0
    brick.inputs["Scale"].default_value = 1.0
    brick.inputs["Mortar Size"].default_value = 0.02
    brick.inputs["Brick Width"].default_value = 1.0
    brick.inputs["Row Height"].default_value = 1.0
    k = 0.6 if wet else 1.0
    brick.inputs["Color1"].default_value = (0.66 * k, 0.58 * k, 0.48 * k, 1)
    brick.inputs["Color2"].default_value = (0.60 * k, 0.53 * k, 0.44 * k, 1)
    brick.inputs["Mortar"].default_value = (0.25 * k, 0.24 * k, 0.22 * k, 1)
    nt.links.new(mapping.outputs["Vector"], brick.inputs["Vector"])
    nt.links.new(brick.outputs["Color"], b.inputs["Base Color"])
    bump = nt.nodes.new("ShaderNodeBump")
    bump.inputs["Strength"].default_value = 0.3
    nt.links.new(brick.outputs["Fac"], bump.inputs["Height"])
    nt.links.new(bump.outputs["Normal"], b.inputs["Normal"])
    b.inputs["Roughness"].default_value = 0.2 if wet else 0.75
    return m


def cobbles(name, wet):
    """Cobblestones: Voronoi cells for stones, darker gaps; wet = low roughness with puddles."""
    m, nt, b = node_material(name)
    geo = nt.nodes.new("ShaderNodeNewGeometry")
    mapping = nt.nodes.new("ShaderNodeMapping")
    # World position, so stones keep their size however the plane is scaled: about 22 x 30 cm.
    mapping.inputs["Scale"].default_value = (8.5, 6.0, 1)
    nt.links.new(geo.outputs["Position"], mapping.inputs["Vector"])
    vor = nt.nodes.new("ShaderNodeTexVoronoi")
    vor.feature = "DISTANCE_TO_EDGE"
    vor.inputs["Scale"].default_value = 1.0
    nt.links.new(mapping.outputs["Vector"], vor.inputs["Vector"])
    edge = nt.nodes.new("ShaderNodeMapRange")
    edge.inputs["From Min"].default_value = 0.0
    edge.inputs["From Max"].default_value = 0.08
    nt.links.new(vor.outputs["Distance"], edge.inputs["Value"])
    cell = nt.nodes.new("ShaderNodeTexVoronoi")
    cell.inputs["Scale"].default_value = 1.0
    nt.links.new(mapping.outputs["Vector"], cell.inputs["Vector"])
    ramp = nt.nodes.new("ShaderNodeValToRGB")
    dark = 0.55 if wet else 1.0
    ramp.color_ramp.elements[0].color = (0.16 * dark, 0.145 * dark, 0.13 * dark, 1)
    ramp.color_ramp.elements[1].color = (0.34 * dark, 0.31 * dark, 0.27 * dark, 1)
    nt.links.new(cell.outputs["Color"], ramp.inputs["Fac"])
    mix = nt.nodes.new("ShaderNodeMix")
    mix.data_type = "RGBA"
    mix.inputs["B"].default_value = (0.05, 0.045, 0.04, 1)
    nt.links.new(ramp.outputs["Color"], mix.inputs["A"])
    inv = nt.nodes.new("ShaderNodeMath")
    inv.operation = "SUBTRACT"
    inv.inputs[0].default_value = 1.0
    nt.links.new(edge.outputs["Result"], inv.inputs[1])
    nt.links.new(inv.outputs["Value"], mix.inputs["Factor"])
    nt.links.new(mix.outputs["Result"], b.inputs["Base Color"])
    bump = nt.nodes.new("ShaderNodeBump")
    bump.inputs["Strength"].default_value = 0.6
    nt.links.new(edge.outputs["Result"], bump.inputs["Height"])
    nt.links.new(bump.outputs["Normal"], b.inputs["Normal"])
    if wet:
        puddle = nt.nodes.new("ShaderNodeTexNoise")
        puddle.inputs["Scale"].default_value = 0.35
        puddle.inputs["Detail"].default_value = 4.0
        rr = nt.nodes.new("ShaderNodeMapRange")
        rr.inputs["From Min"].default_value = 0.45
        rr.inputs["From Max"].default_value = 0.6
        rr.inputs["To Min"].default_value = 0.22
        rr.inputs["To Max"].default_value = 0.02
        nt.links.new(puddle.outputs["Fac"], rr.inputs["Value"])
        nt.links.new(rr.outputs["Result"], b.inputs["Roughness"])
        b.inputs["Specular IOR Level"].default_value = 0.7
    else:
        b.inputs["Roughness"].default_value = 0.78
    return m


# ---------------------------------------------------------------- geometry helpers

def box(name, size, loc, mat, rot_z=0.0):
    bpy.ops.mesh.primitive_cube_add(size=1, location=loc)
    o = bpy.context.active_object
    o.name = name
    o.scale = size
    o.rotation_euler[2] = rot_z
    o.data.materials.append(mat)
    return o


def cylinder(name, r, depth, loc, mat, verts=32, r2=None):
    if r2 is None:
        bpy.ops.mesh.primitive_cylinder_add(vertices=verts, radius=r, depth=depth, location=loc)
    else:
        bpy.ops.mesh.primitive_cone_add(vertices=verts, radius1=r, radius2=r2, depth=depth, location=loc)
    o = bpy.context.active_object
    o.name = name
    o.data.materials.append(mat)
    return o


def sphere(name, r, loc, mat):
    bpy.ops.mesh.primitive_uv_sphere_add(radius=r, location=loc, segments=24, ring_count=12)
    o = bpy.context.active_object
    o.name = name
    o.data.materials.append(mat)
    bpy.ops.object.shade_smooth()
    return o


def point_light(loc, energy, color, radius=0.15):
    d = bpy.data.lights.new("lamp", "POINT")
    d.energy = energy
    d.color = color
    d.shadow_soft_size = radius
    o = bpy.data.objects.new("lamp", d)
    o.location = loc
    bpy.context.collection.objects.link(o)
    return o


def facade(side, y0, width, height, depth_x, palette, rng, window_lit, glass, frame, style):
    """One building on one side of the street. side = -1 (left) or +1 (right); depth_x = facade plane."""
    wall = palette[rng.randrange(len(palette))]
    cx = side * (depth_x + 4)
    box(f"bld_{side}_{y0:.0f}", (8, width, height), (cx, y0 + width / 2, height / 2), wall)
    floors = max(3, int(height / 3.2))
    cols = max(2, int(width / 2.4))
    face_x = side * depth_x
    for f in range(1, floors):
        z = f * 3.2 + 1.4
        if z > height - 1.0:
            break
        for c in range(cols):
            y = y0 + (c + 0.5) * width / cols
            lit = rng.random() < window_lit
            mat = window_mats[lit][rng.randrange(len(window_mats[lit]))]
            box("win", (0.08, 1.05, 1.6), (face_x - side * 0.03, y, z), mat)
            box("sill", (0.18, 1.25, 0.08), (face_x - side * 0.06, y, z - 0.86), frame)
            if style == "barcelona" and f >= 1:
                # Iron balcony: a thin slab and a dark rail.
                box("balc", (0.7, 1.5, 0.07), (face_x - side * 0.36, y, z - 0.9), frame)
                box("rail", (0.03, 1.5, 0.9), (face_x - side * 0.70, y, z - 0.45), iron)
        if style == "istanbul" and f >= 2 and rng.random() < 0.35:
            # Cumba: a closed timber bay window on an upper floor.
            y = y0 + width / 2
            box("cumba", (1.0, min(3.2, width * 0.6), 2.6), (face_x - side * 0.5, y, f * 3.2 + 1.5), palette_wood[rng.randrange(len(palette_wood))])
    # Ground floor: shop window, some lit, with an awning in Istanbul.
    shop_lit = rng.random() < 0.7
    box("shop", (0.1, width * 0.7, 2.4), (face_x - side * 0.05, y0 + width / 2, 1.3), shop_mats[shop_lit])
    if style == "istanbul" and rng.random() < 0.5:
        a = box("awning", (1.3, width * 0.75, 0.06), (face_x - side * 0.65, y0 + width / 2, 2.85), awning)
        a.rotation_euler[1] = side * math.radians(-14)
    return floors


def build(city, wet, rng):
    global window_mats, palette_wood, iron, awning
    bpy.ops.wm.read_factory_settings(use_empty=True)
    scene = bpy.context.scene
    scene.render.engine = "BLENDER_EEVEE"

    ground = cobbles("cobbles", wet)
    curb = plain("curb", (0.42, 0.40, 0.37), 0.5 if wet else 0.8)
    iron = plain("iron", (0.03, 0.03, 0.03), 0.45, 0.6)
    frame = plain("frame", (0.85, 0.82, 0.76), 0.7)
    awning = plain("awning", (0.32, 0.06, 0.07), 0.9)
    warm = [plain("winlit1", (0.9, 0.7, 0.45), 0.3, emit=(1.0, 0.62, 0.32), strength=1.4),
            plain("winlit2", (0.9, 0.75, 0.55), 0.3, emit=(1.0, 0.8, 0.55), strength=1.6)]
    dark = [plain("windark1", (0.05, 0.06, 0.07), 0.08, 0.3), plain("windark2", (0.08, 0.08, 0.09), 0.1, 0.2)]
    window_mats = {True: warm, False: dark}
    global shop_mats
    shop_mats = {True: plain("shoplit", (0.6, 0.45, 0.3), 0.2, emit=(1.0, 0.6, 0.3), strength=0.9), False: dark[0]}
    palette_wood = [plain("wood1", (0.30, 0.18, 0.11), 0.75), plain("wood2", (0.42, 0.30, 0.20), 0.75)]

    if city == "istanbul":
        palette = [plaster("p1", (0.78, 0.62, 0.42)), plaster("p2", (0.70, 0.58, 0.50)), plaster("p3", (0.62, 0.55, 0.47)),
                   plaster("p4", (0.80, 0.70, 0.55)), plaster("p5", (0.55, 0.36, 0.30)), plaster("p6", (0.66, 0.66, 0.62))]
        street_half, walk = 2.4, 1.2
        window_lit = 0.55
    else:
        # Eixample sandstone and ochre in late-afternoon sun.
        palette = [plaster("b1", (0.86, 0.70, 0.50)), plaster("b2", (0.80, 0.62, 0.44)), plaster("b3", (0.90, 0.80, 0.64)),
                   plaster("b4", (0.74, 0.56, 0.40)), plaster("b5", (0.84, 0.66, 0.52))]
        street_half, walk = 5.0, 4.0
        window_lit = 0.22

    face_x = street_half + walk
    if city == "barcelona":
        ground = asphalt("asphalt", wet)
        curb = tiles("panot", wet)
    # Street and pavements.
    bpy.ops.mesh.primitive_plane_add(size=1, location=(0, 60, 0))
    road = bpy.context.active_object
    road.scale = (street_half * 2, 160, 1)
    road.data.materials.append(ground)
    for side in (-1, 1):
        box("walk", (walk, 160, 0.14), (side * (street_half + walk / 2), 60, 0.07), curb)

    # Buildings on both sides.
    for side in (-1, 1):
        y = -6.0
        while y < 90:
            width = rng.uniform(6, 10) if city == "istanbul" else rng.uniform(11, 15)
            height = rng.uniform(11, 17) if city == "istanbul" else rng.uniform(19, 23)
            facade(side, y, width, height, face_x, palette, rng, window_lit, None, frame, city)
            y += width + (0.0 if city == "barcelona" else rng.uniform(0, 0.4))

    if city == "istanbul":
        # A round stone tower with a conical roof up the hill at the end of the street (evokes Galata).
        stone = plaster("stone", (0.62, 0.58, 0.52), 0.9)
        roof = plain("roof", (0.20, 0.22, 0.26), 0.5, 0.3)
        tx, ty, base = 0.0, 105.0, 10.0
        cylinder("tower", 7.5, 42, (tx, ty, base + 21), stone, verts=48)
        cylinder("gallery", 8.6, 1.2, (tx, ty, base + 42.6), frame, verts=48)
        cylinder("drum", 6.8, 5, (tx, ty, base + 45.5), stone, verts=48)
        cylinder("cone", 7.6, 15, (tx, ty, base + 55.5), roof, verts=48, r2=0.2)
        for k in range(16):
            a = 2 * math.pi * k / 16
            for z in (base + 30, base + 38, base + 45.5):
                box("twin", (0.15, 1.0, 1.8), (tx + 7.6 * math.cos(a), ty + 7.6 * math.sin(a), z),
                    window_mats[z > base + 40][0], rot_z=a)
        # Hill under the tower so it rises above the end of the street.
        box("hill", (60, 40, base), (tx, ty + 6, base / 2), plaster("hillp", (0.35, 0.30, 0.26)))
        # Street lamps.
        lamp_mat = plain("lampglass", (1, 0.85, 0.6), 0.2, emit=(1.0, 0.70, 0.38), strength=9)
        for k in range(7):
            for side in (-1, 1):
                y = 3 + k * 9 + (4.5 if side > 0 else 0)
                x = side * (street_half + 0.35)
                cylinder("pole", 0.06, 3.6, (x, y, 1.8), iron, verts=12)
                sphere("lantern", 0.22, (x, y, 3.75), lamp_mat)
                point_light((x, y, 3.6), 420 if k < 4 else 260, (1.0, 0.70, 0.42), 0.25)
        # The tower is floodlit from below, as historic towers are at night.
        for a in (0.6, 2.2, 3.9):
            spot = bpy.data.lights.new("flood", "SPOT")
            spot.energy = 90000
            spot.color = (1.0, 0.78, 0.55)
            spot.spot_size = math.radians(40)
            so = bpy.data.objects.new("flood", spot)
            so.location = (tx + 22 * math.cos(a) * 0.5, ty - 22, base + 1)
            direction = Vector((tx, ty, base + 32)) - so.location
            so.rotation_euler = direction.to_track_quat("-Z", "Y").to_euler()
            bpy.context.collection.objects.link(so)
        # Soft moonlight so facades read in the dark.
        moon = bpy.data.lights.new("moon", "SUN")
        moon.energy = 0.35
        moon.color = (0.65, 0.72, 1.0)
        mo = bpy.data.objects.new("moon", moon)
        mo.rotation_euler = (math.radians(60), 0, math.radians(30))
        bpy.context.collection.objects.link(mo)
        sky_top, sky_bottom, sun_strength = (0.03, 0.06, 0.16), (0.45, 0.28, 0.24), 0.0
        fog = 0.0022 if wet else 0.0012
    else:
        # Plane trees on the pavements and a cluster of slender stone spires far away.
        bark = plain("bark", (0.42, 0.38, 0.30), 0.9)
        leaves = plaster("leaves", (0.36, 0.50, 0.20), 0.8)
        for k in range(9):
            for side in (-1, 1):
                y = 4 + k * 8 + (4 if side > 0 else 0)
                x = side * (street_half + 1.0)
                cylinder("trunk", 0.18, 6.5, (x, y, 3.25), bark, verts=12)
                for j in range(7):
                    c = sphere("crown", rng.uniform(1.1, 1.7), (x + rng.uniform(-1.3, 1.3), y + rng.uniform(-1.5, 1.5), 7.6 + rng.uniform(-0.6, 1.6)), leaves)
                    disp = c.modifiers.new("lumpy", "DISPLACE")
                    tex = bpy.data.textures.new("leafnoise", "CLOUDS")
                    tex.noise_scale = 0.35
                    disp.texture = tex
                    disp.strength = 0.9
                    c.modifiers.new("sub", "SUBSURF").levels = 1
        # A zebra crossing across the street in the middle distance, as at an Eixample corner.
        paint = plain("paint", (0.86, 0.85, 0.80), 0.35 if wet else 0.7)
        x = -street_half + 0.45
        while x < street_half - 0.3:
            box("zebra", (0.5, 3.2, 0.012), (x, 8.0, 0.006), paint)
            x += 1.0
        spire = plaster("spire", (0.82, 0.70, 0.54), 0.9)
        for k, (dx, h) in enumerate([(-9, 70), (-4, 86), (4, 90), (9, 74)]):
            cylinder("spire", 2.6, h, (dx, 220, h / 2), spire, verts=24, r2=0.6)
        # Golden hour: deep blue overhead, warm haze at the horizon, a low raking sun.
        sky_top, sky_bottom, sun_strength = (0.10, 0.28, 0.78), (0.98, 0.80, 0.62), 5.4
        fog = 0.0016 if wet else 0.0008

    # World: vertical gradient sky + optional sun.
    world = bpy.data.worlds.new("sky")
    scene.world = world
    world.use_nodes = True
    nt = world.node_tree
    for n in list(nt.nodes):
        nt.nodes.remove(n)
    out = nt.nodes.new("ShaderNodeOutputWorld")
    bg = nt.nodes.new("ShaderNodeBackground")
    grad = nt.nodes.new("ShaderNodeTexGradient")
    coord = nt.nodes.new("ShaderNodeTexCoord")
    sep = nt.nodes.new("ShaderNodeSeparateXYZ")
    nt.links.new(coord.outputs["Generated"], sep.inputs["Vector"])
    ramp = nt.nodes.new("ShaderNodeValToRGB")
    # Generated Z in a world shader is the view direction's height (0 at the horizon), so the camera
    # sees roughly 0...0.5. Istanbul keeps its dusk tone across the whole sky; Barcelona fades from a
    # warm horizon to blue overhead.
    ramp.color_ramp.elements[0].position = 0.5 if city == "istanbul" else 0.02
    ramp.color_ramp.elements[0].color = (*sky_bottom, 1)
    ramp.color_ramp.elements[1].position = 0.78 if city == "istanbul" else 0.32
    ramp.color_ramp.elements[1].color = (*sky_top, 1)
    nt.links.new(sep.outputs["Z"], ramp.inputs["Fac"])
    nt.links.new(ramp.outputs["Color"], bg.inputs["Color"])
    # Barcelona's blue sky would tint every shadow blue at full strength; the sun carries the light.
    bg.inputs["Strength"].default_value = 1.0 if city == "istanbul" else 0.55
    nt.links.new(bg.outputs["Background"], out.inputs["Surface"])
    if wet:
        # Overcast: a darker, flatter sky.
        ramp.color_ramp.elements[0].color = tuple(c * 0.75 for c in (*sky_bottom, 1))[:3] + (1,)
        ramp.color_ramp.elements[1].color = tuple(c * 0.8 for c in (*sky_top, 1))[:3] + (1,)
    if sun_strength > 0:
        sun = bpy.data.lights.new("sun", "SUN")
        sun.energy = sun_strength * (0.45 if wet else 1.0)
        sun.angle = math.radians(2 if not wet else 20)
        so = bpy.data.objects.new("sun", sun)
        sun.color = (1.0, 0.80, 0.58) if city == "barcelona" else (1.0, 1.0, 1.0)
        so.rotation_euler = (math.radians(68), 0, math.radians(-62))
        bpy.context.collection.objects.link(so)
    # Atmospheric depth in a bounded volume along the street (a world volume would hide the sky).
    haze = bpy.data.materials.new("haze")
    haze.use_nodes = True
    hn = haze.node_tree
    for n in list(hn.nodes):
        hn.nodes.remove(n)
    hout = hn.nodes.new("ShaderNodeOutputMaterial")
    vol = hn.nodes.new("ShaderNodeVolumePrincipled")
    vol.inputs["Density"].default_value = fog
    vol.inputs["Color"].default_value = (*sky_bottom, 1)
    hn.links.new(vol.outputs["Volume"], hout.inputs["Volume"])
    # Depth: EEVEE treats volumes in a way that hid the scene, so atmospheric perspective is a
    # mist pass mixed in the compositor (see main()).
    scene["haze_color"] = list(sky_bottom)
    scene["haze_amount"] = (0.38 if wet else 0.22) if city == "istanbul" else (0.22 if wet else 0.08)

    # Camera: the app's camera.
    cam_data = bpy.data.cameras.new("cam")
    cam_data.sensor_fit = "VERTICAL"
    cam_data.angle_y = FOV_Y
    cam_data.clip_end = 600
    cam = bpy.data.objects.new("cam", cam_data)
    cam.location = (0, -CAMERA_DISTANCE, CAMERA_HEIGHT)
    cam.rotation_euler = (math.radians(90), 0, 0)
    bpy.context.collection.objects.link(cam)
    scene.camera = cam
    return scene


def add_haze(scene):
    """Compositor: mix the render towards the sky colour by the mist pass (Blender 5 node groups)."""
    tree = bpy.data.node_groups.new("haze", "CompositorNodeTree")
    scene.compositing_node_group = tree
    tree.interface.new_socket("Image", in_out="OUTPUT", socket_type="NodeSocketColor")
    rl = tree.nodes.new("CompositorNodeRLayers")
    amount = tree.nodes.new("ShaderNodeMath")
    amount.operation = "MULTIPLY"
    amount.inputs[1].default_value = scene["haze_amount"]
    tree.links.new(rl.outputs["Mist"], amount.inputs[0])
    mix = tree.nodes.new("ShaderNodeMix")
    mix.data_type = "RGBA"
    tree.links.new(amount.outputs[0], mix.inputs["Factor"])
    tree.links.new(rl.outputs["Image"], mix.inputs["A"])
    c = scene["haze_color"]
    mix.inputs["B"].default_value = (c[0], c[1], c[2], 1)
    out = tree.nodes.new("NodeGroupOutput")
    tree.links.new(mix.outputs["Result"], out.inputs[0])


def main():
    a = args()
    rng = random.Random(7 if a.city == "istanbul" else 11)
    scene = build(a.city, a.weather == "wet", rng)
    r = scene.render
    r.resolution_x = int(WIDTH * a.scale)
    r.resolution_y = int(HEIGHT * a.scale)
    r.resolution_percentage = 100
    r.image_settings.file_format = "JPEG"
    r.image_settings.quality = 88
    r.filepath = a.out
    ee = scene.eevee
    ee.taa_render_samples = a.samples
    for attr, value in (("use_raytracing", True), ("use_shadows", True), ("volumetric_end", 220.0), ("volumetric_tile_size", "4")):
        if hasattr(ee, attr):
            try:
                setattr(ee, attr, value)
            except Exception:
                pass
    scene.view_settings.view_transform = "AgX"
    scene.view_settings.exposure = -0.1 if a.city == "barcelona" else -0.55
    # Mist pass → sky-coloured atmospheric perspective.
    scene.view_layers[0].use_pass_mist = True
    scene.world.mist_settings.start = 8
    scene.world.mist_settings.depth = 140 if a.city == "istanbul" else 220
    scene.world.mist_settings.falloff = "QUADRATIC"
    add_haze(scene)
    scene.view_settings.look = "AgX - Medium High Contrast"
    bpy.ops.render.render(write_still=True)
    print("WROTE", a.out)


if __name__ == "__main__":
    main()
