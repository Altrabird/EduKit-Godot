"""Low-poly education props -> GLB, built headless in Blender 5.x:
  blender -b --factory-startup -P tools/build_models.py [-- name ...]
Units are metres, origin at the bottom centre, +Y up in Godot (glTF converts Z-up).
Materials are created after each scene reset (old ones are freed with the scene)."""
import bpy, math, os, sys, json

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(ROOT, "assets", "models")

COL = {"wood": "#C68B59", "dwood": "#7A4A2A", "white": "#F4F4F0", "paper": "#FDFCF7", "ink": "#2B2D42", "chalk": "#2F5D50", "grey": "#ADB5BD", "dgrey": "#6C757D",
       "lgrey": "#DEE2E6", "blue": "#3A86FF", "navy": "#1D3557", "sky": "#8ECAE6", "red": "#EF476F", "dred": "#C1121F", "green": "#6BCB77", "dgreen": "#2D936C",
       "yellow": "#FFD166", "gold": "#F4A100", "orange": "#FF9F1C", "purple": "#9B5DE5", "pink": "#F15BB5", "teal": "#2EC4B6", "glass": "#D7F3FF", "cream": "#FFF3D6",
       "black": "#22223B", "brown": "#A0663F", "skin": "#E8B48A"}
MATS = {}


def srgb_to_lin(c):
    return c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4


def mat(name, alpha=1.0, rough=0.9, metal=0.0, emit=0.0):
    key = (name, alpha, metal, emit)
    if key in MATS:
        return MATS[key]
    h = COL.get(name, name).lstrip("#")
    rgb = [srgb_to_lin(int(h[i:i + 2], 16) / 255) for i in (0, 2, 4)]
    m = bpy.data.materials.new(f"{name}{'_glass' if alpha < 1 else ''}{'_emit' if emit else ''}")
    m.use_nodes = True
    bsdf = next(n for n in m.node_tree.nodes if n.type == "BSDF_PRINCIPLED")
    bsdf.inputs["Base Color"].default_value = (*rgb, 1)
    bsdf.inputs["Roughness"].default_value = rough
    bsdf.inputs["Metallic"].default_value = metal
    if alpha < 1:
        bsdf.inputs["Alpha"].default_value = alpha
        try:
            m.surface_render_method = "BLENDED"
        except Exception:
            pass
    if emit:
        bsdf.inputs["Emission Color"].default_value = (*rgb, 1)
        bsdf.inputs["Emission Strength"].default_value = emit
    MATS[key] = m
    return m


def reset():
    bpy.ops.wm.read_factory_settings(use_empty=True)
    MATS.clear()


def _finish(obj, m, bevel=0.0, smooth=False):
    obj.data.materials.append(m if isinstance(m, bpy.types.Material) else mat(m))
    if bevel:
        mod = obj.modifiers.new("bevel", "BEVEL")
        mod.width = bevel
        mod.segments = 2
        mod.limit_method = "ANGLE"
    if smooth:
        bpy.ops.object.shade_smooth()
    else:
        bpy.ops.object.shade_flat()
    return obj


def box(sx, sy, sz, loc, m, bevel=0.01, rot=(0, 0, 0)):
    """Size in metres, loc = centre (x, y, z), Z up."""
    bpy.ops.mesh.primitive_cube_add(size=1, location=loc, rotation=rot)
    o = bpy.context.object
    o.scale = (sx, sy, sz)
    bpy.ops.object.transform_apply(scale=True)
    return _finish(o, m, bevel)


def cyl(r, h, loc, m, verts=24, rot=(0, 0, 0), bevel=0.0, r2=None, smooth=True):
    if r2 is None:
        bpy.ops.mesh.primitive_cylinder_add(vertices=verts, radius=r, depth=h, location=loc, rotation=rot)
    else:
        bpy.ops.mesh.primitive_cone_add(vertices=verts, radius1=r, radius2=r2, depth=h, location=loc, rotation=rot)
    return _finish(bpy.context.object, m, bevel, smooth)


def sphere(r, loc, m, seg=24, scale=(1, 1, 1)):
    bpy.ops.mesh.primitive_uv_sphere_add(segments=seg, ring_count=seg // 2, radius=r, location=loc)
    o = bpy.context.object
    o.scale = scale
    bpy.ops.object.transform_apply(scale=True)
    return _finish(o, m, smooth=True)


def torus(R, r, loc, m, rot=(0, 0, 0)):
    bpy.ops.mesh.primitive_torus_add(major_radius=R, minor_radius=r, location=loc, rotation=rot, major_segments=32, minor_segments=10)
    return _finish(bpy.context.object, m, smooth=True)


def cone(r, h, loc, m, verts=24, rot=(0, 0, 0)):
    bpy.ops.mesh.primitive_cone_add(vertices=verts, radius1=r, radius2=0, depth=h, location=loc, rotation=rot)
    return _finish(bpy.context.object, m, smooth=verts > 8)


def export(name, folder):
    path = os.path.join(OUT, folder, name + ".glb")
    os.makedirs(os.path.dirname(path), exist_ok=True)
    for o in bpy.context.scene.objects:
        o.select_set(o.type == "MESH")
    bpy.context.view_layer.objects.active = next(o for o in bpy.context.scene.objects if o.type == "MESH")
    bpy.ops.object.join()
    o = bpy.context.object
    o.name = name
    # origin at bottom centre so props sit on the floor when placed at y = 0
    mins = [min(v.co[i] for v in o.data.vertices) for i in range(3)]
    maxs = [max(v.co[i] for v in o.data.vertices) for i in range(3)]
    bpy.context.scene.cursor.location = ((mins[0] + maxs[0]) / 2, (mins[1] + maxs[1]) / 2, mins[2])
    bpy.ops.object.origin_set(type="ORIGIN_CURSOR")
    o.location = (0, 0, 0)
    bpy.ops.export_scene.gltf(filepath=path, export_format="GLB", export_apply=True, use_selection=False)
    return {"id": name, "folder": folder, "path": f"res://assets/models/{folder}/{name}.glb", "size_m": [round(maxs[i] - mins[i], 3) for i in (0, 2, 1)]}


MODELS = {}


def model(folder, en, bm):
    def deco(fn):
        MODELS[fn.__name__] = (folder, fn, en, bm)
        return fn
    return deco


# ---------------- classroom ----------------
@model("classroom", "Student desk", "Meja murid")
def desk():
    box(0.7, 0.5, 0.04, (0, 0, 0.72), "wood")
    box(0.64, 0.44, 0.12, (0, 0, 0.64), "dwood", bevel=0.005)
    for x in (-0.32, 0.32):
        for y in (-0.22, 0.22):
            box(0.035, 0.035, 0.6, (x, y, 0.3), "grey", bevel=0.005)


@model("classroom", "Student chair", "Kerusi murid")
def chair():
    box(0.42, 0.4, 0.035, (0, 0, 0.44), "wood")
    box(0.42, 0.035, 0.3, (0, 0.2, 0.72), "wood")
    for x in (-0.19, 0.19):
        for y in (-0.17, 0.18):
            box(0.03, 0.03, 0.44 if y < 0 else 0.86, (x, y, 0.22 if y < 0 else 0.43), "grey", bevel=0.004)


@model("classroom", "Teacher's desk", "Meja guru")
def teacher_desk():
    box(1.4, 0.7, 0.05, (0, 0, 0.76), "wood")
    box(0.45, 0.66, 0.7, (-0.45, 0, 0.37), "dwood")
    box(0.45, 0.66, 0.7, (0.45, 0, 0.37), "dwood")
    for z in (0.2, 0.42, 0.62):
        box(0.12, 0.02, 0.03, (-0.45, -0.34, z), "gold", bevel=0.004)
    box(0.25, 0.18, 0.06, (0.4, 0, 0.82), "red")
    box(0.24, 0.17, 0.02, (0.4, 0, 0.86), "paper")


@model("classroom", "Chalkboard", "Papan hitam")
def chalkboard():
    box(2.4, 0.06, 1.2, (0, 0, 1.4), "dwood")
    box(2.24, 0.07, 1.06, (0, -0.005, 1.4), "chalk", bevel=0.002)
    box(2.3, 0.14, 0.04, (0, -0.07, 0.8), "wood")
    box(0.12, 0.04, 0.03, (0.6, -0.1, 0.835), "white", bevel=0.003)
    box(0.1, 0.03, 0.03, (0.8, -0.1, 0.835), "yellow", bevel=0.003)


@model("classroom", "Whiteboard", "Papan putih")
def whiteboard():
    box(2.0, 0.04, 1.1, (0, 0, 1.45), "lgrey")
    box(1.92, 0.05, 1.02, (0, -0.004, 1.45), "white", bevel=0.002)
    box(1.9, 0.1, 0.03, (0, -0.06, 0.9), "lgrey")
    for i, c in enumerate(("red", "blue", "green")):
        cyl(0.012, 0.13, (0.3 + i * 0.06, -0.07, 0.93), c, verts=10, rot=(0, math.pi / 2, 0))


@model("classroom", "Bookshelf", "Rak buku")
def bookshelf():
    box(1.2, 0.35, 0.03, (0, 0, 1.8), "dwood")
    for x in (-0.585, 0.585):
        box(0.03, 0.35, 1.8, (x, 0, 0.9), "dwood")
    box(1.2, 0.02, 1.8, (0, 0.165, 0.9), "dwood")
    cols = ["red", "blue", "green", "yellow", "purple", "orange", "teal", "pink", "navy"]
    k = 0
    for shelf in range(4):
        z = 0.03 + shelf * 0.45
        box(1.17, 0.33, 0.025, (0, 0, z), "wood")
        x = -0.55
        while x < 0.5:
            w = 0.04 + (k * 7 % 5) * 0.01
            h = 0.26 + (k * 3 % 4) * 0.025
            box(w, 0.24, h, (x + w / 2, 0, z + 0.0125 + h / 2), cols[k % len(cols)], bevel=0.003)
            x += w + 0.006
            k += 1


@model("classroom", "Book", "Buku")
def book():
    box(0.17, 0.24, 0.035, (0, 0, 0.0175), "blue", bevel=0.004)
    box(0.16, 0.225, 0.028, (0.006, 0, 0.0175), "paper")


@model("classroom", "Stack of books", "Timbunan buku")
def book_stack():
    for i, c in enumerate(("red", "green", "blue", "yellow")):
        box(0.2 - i * 0.01, 0.27 - i * 0.012, 0.04, (0.006 * (i % 2), 0, 0.02 + i * 0.042), c, bevel=0.004, rot=(0, 0, (i - 1.5) * 0.12))
        box(0.19 - i * 0.01, 0.255 - i * 0.012, 0.032, (0.012 + 0.006 * (i % 2), 0, 0.02 + i * 0.042), "paper", rot=(0, 0, (i - 1.5) * 0.12))


@model("classroom", "Globe", "Glob")
def globe():
    cyl(0.12, 0.03, (0, 0, 0.015), "dwood")
    cyl(0.015, 0.12, (0, 0, 0.09), "dwood", verts=8)
    sphere(0.16, (0, 0, 0.32), "blue", seg=32)
    sphere(0.07, (0.11, -0.06, 0.38), "green", seg=12, scale=(1, 0.6, 1))
    sphere(0.08, (-0.1, -0.07, 0.27), "green", seg=12, scale=(1, 0.6, 1.2))
    torus(0.19, 0.008, (0, 0, 0.32), "gold", rot=(0, math.radians(23), 0))


@model("classroom", "Wall clock", "Jam dinding")
def wall_clock():
    cyl(0.18, 0.05, (0, 0, 0.18), "blue", rot=(math.pi / 2, 0, 0))
    cyl(0.155, 0.052, (0, -0.002, 0.18), "white", rot=(math.pi / 2, 0, 0))
    box(0.012, 0.01, 0.1, (0, -0.03, 0.23), "ink", bevel=0)
    box(0.08, 0.01, 0.012, (0.04, -0.032, 0.18), "ink", bevel=0)
    for a in range(0, 360, 30):
        r = math.radians(a)
        box(0.012, 0.008, 0.025, (0.13 * math.sin(r), -0.03, 0.18 + 0.13 * math.cos(r)), "ink", bevel=0, rot=(0, r, 0))


@model("classroom", "School bag", "Beg sekolah")
def school_bag():
    box(0.32, 0.16, 0.4, (0, 0, 0.2), "red", bevel=0.04)
    box(0.26, 0.06, 0.18, (0, -0.1, 0.14), "orange", bevel=0.025)
    box(0.04, 0.03, 0.3, (-0.09, 0.09, 0.22), "dred", bevel=0.01)
    box(0.04, 0.03, 0.3, (0.09, 0.09, 0.22), "dred", bevel=0.01)
    torus(0.04, 0.01, (0, 0, 0.42), "dred", rot=(math.pi / 2, 0, 0))


@model("classroom", "Pencil", "Pensel")
def pencil():
    cyl(0.008, 0.16, (0, 0, 0.08 + 0.02), "yellow", verts=6, smooth=False)
    cone(0.008, 0.025, (0, 0, 0.0125 - 0.0), "cream", verts=6, rot=(math.pi, 0, 0))
    cyl(0.0085, 0.015, (0, 0, 0.1875), "grey", verts=12)
    cyl(0.008, 0.02, (0, 0, 0.205), "pink", verts=12)


@model("classroom", "Apple", "Epal")
def apple():
    sphere(0.045, (0, 0, 0.045), "red", seg=20, scale=(1, 1, 0.9))
    cyl(0.004, 0.025, (0, 0, 0.095), "dwood", verts=6)
    sphere(0.015, (0.012, 0, 0.098), "green", seg=8, scale=(1.4, 0.5, 0.6))


@model("classroom", "Trophy", "Piala")
def trophy():
    box(0.16, 0.16, 0.05, (0, 0, 0.025), "dwood")
    cyl(0.03, 0.08, (0, 0, 0.09), "gold", verts=16)
    cyl(0.09, 0.14, (0, 0, 0.2), "yellow", r2=0.03, rot=(math.pi, 0, 0))
    torus(0.04, 0.01, (-0.09, 0, 0.22), "gold", rot=(math.pi / 2, 0, 0))
    torus(0.04, 0.01, (0.09, 0, 0.22), "gold", rot=(math.pi / 2, 0, 0))


@model("classroom", "Laptop", "Komputer riba")
def laptop():
    box(0.34, 0.24, 0.015, (0, 0, 0.0075), "dgrey", bevel=0.004)
    box(0.34, 0.012, 0.22, (0, 0.12, 0.11), "dgrey", bevel=0.004, rot=(math.radians(-12), 0, 0))
    box(0.31, 0.004, 0.19, (0, 0.11, 0.11), "navy", rot=(math.radians(-12), 0, 0))
    box(0.3, 0.16, 0.004, (0, -0.02, 0.016), "lgrey", bevel=0)


# ---------------- sains ----------------
@model("sains", "Beaker", "Bikar")
def beaker():
    cyl(0.05, 0.12, (0, 0, 0.06), mat("glass", alpha=0.35, rough=0.05), verts=24)
    cyl(0.046, 0.06, (0, 0, 0.032), "blue", verts=24)


@model("sains", "Conical flask", "Kelalang kon")
def flask():
    cyl(0.07, 0.12, (0, 0, 0.06), mat("glass", alpha=0.35, rough=0.05), r2=0.02)
    cyl(0.02, 0.06, (0, 0, 0.15), mat("glass", alpha=0.35, rough=0.05), verts=16)
    cyl(0.064, 0.05, (0, 0, 0.027), "green", r2=0.044)


@model("sains", "Test tube rack", "Rak tabung uji")
def test_tube_rack():
    box(0.3, 0.08, 0.02, (0, 0, 0.01), "wood")
    box(0.3, 0.08, 0.02, (0, 0, 0.1), "wood")
    for x in (-0.14, 0.14):
        box(0.02, 0.08, 0.11, (x, 0, 0.055), "dwood")
    for i, c in enumerate(("red", "yellow", "teal", "purple")):
        x = -0.09 + i * 0.06
        cyl(0.012, 0.15, (x, 0, 0.09), mat("glass", alpha=0.35, rough=0.05), verts=12)
        cyl(0.011, 0.06, (x, 0, 0.05), c, verts=12)


@model("sains", "Microscope", "Mikroskop")
def microscope():
    box(0.18, 0.22, 0.03, (0, 0, 0.015), "navy", bevel=0.008)
    box(0.04, 0.05, 0.25, (0, 0.08, 0.15), "navy", bevel=0.008)
    box(0.14, 0.12, 0.012, (0, -0.01, 0.11), "dgrey")
    cyl(0.025, 0.16, (0, 0.02, 0.24), "lgrey", rot=(math.radians(-20), 0, 0))
    cyl(0.02, 0.05, (0, 0.05, 0.33), "dgrey", rot=(math.radians(-20), 0, 0))
    cyl(0.02, 0.03, (0.04, 0.08, 0.15), "grey", rot=(0, math.pi / 2, 0))


@model("sains", "Horseshoe magnet", "Magnet ladam")
def magnet():
    bpy.ops.mesh.primitive_torus_add(major_radius=0.06, minor_radius=0.02, location=(0, 0, 0.08), rotation=(math.pi / 2, 0, 0), major_segments=32, minor_segments=12)
    o = bpy.context.object
    bpy.ops.object.mode_set(mode="EDIT")
    bpy.ops.mesh.select_all(action="DESELECT")
    bpy.ops.object.mode_set(mode="OBJECT")
    for v in o.data.vertices:
        v.select = v.co.y < -0.01  # local Y becomes world Z after rotation: drop the top half
    bpy.ops.object.mode_set(mode="EDIT")
    bpy.ops.mesh.delete(type="VERT")
    bpy.ops.object.mode_set(mode="OBJECT")
    _finish(o, "red", smooth=True)
    for x in (-0.06, 0.06):
        cyl(0.02, 0.06, (x, 0, 0.11), "red", verts=16)
        cyl(0.0205, 0.025, (x, 0, 0.152), "lgrey", verts=16)


@model("sains", "Light bulb", "Mentol")
def light_bulb():
    cyl(0.018, 0.03, (0, 0, 0.015), "dgrey", verts=16)
    cyl(0.022, 0.025, (0, 0, 0.04), "grey", verts=16)
    sphere(0.05, (0, 0, 0.1), mat("yellow", alpha=0.9, emit=1.5), seg=24, scale=(1, 1, 1.15))


@model("sains", "Rocket", "Roket")
def rocket():
    cyl(0.12, 0.6, (0, 0, 0.42), "white", verts=24)
    cone(0.12, 0.28, (0, 0, 0.86), "red", verts=24)
    cyl(0.07, 0.12, (0, 0, 0.06), "dgrey", r2=0.1)
    cyl(0.05, 0.02, (0, -0.11, 0.55), "sky", rot=(math.pi / 2, 0, 0))
    for a in range(0, 360, 120):
        r = math.radians(a)
        box(0.02, 0.14, 0.2, (0.16 * math.cos(r), 0.16 * math.sin(r), 0.2), "red", rot=(0, 0, r + math.pi / 2), bevel=0.005)


@model("sains", "Telescope", "Teleskop")
def telescope():
    for a in (0, 120, 240):
        r = math.radians(a)
        cyl(0.012, 0.9, (0.2 * math.cos(r), 0.2 * math.sin(r), 0.43), "dwood", verts=8, rot=(0.23 * math.sin(r), -0.23 * math.cos(r), 0))
    cyl(0.06, 0.8, (0, 0, 1.0), "blue", rot=(0, math.radians(65), 0))
    cyl(0.07, 0.15, (0.32, 0, 1.15), "navy", rot=(0, math.radians(65), 0))
    cyl(0.025, 0.1, (-0.38, 0, 0.82), "dgrey", rot=(0, math.radians(65), 0))


@model("sains", "Potted plant", "Pokok dalam pasu")
def potted_plant():
    cyl(0.12, 0.2, (0, 0, 0.1), "wood", r2=0.15)
    cyl(0.15, 0.03, (0, 0, 0.2), "dwood")
    cyl(0.012, 0.3, (0, 0, 0.35), "dgreen", verts=8)
    for i in range(6):
        a = i * math.pi / 3
        sphere(0.08, (0.08 * math.cos(a), 0.08 * math.sin(a), 0.32 + i * 0.04), "green", seg=10, scale=(1.4, 0.6, 0.35))
    for a in range(0, 360, 60):
        r = math.radians(a)
        sphere(0.035, (0.04 * math.cos(r), 0.04 * math.sin(r), 0.52), "pink", seg=10)
    sphere(0.03, (0, 0, 0.53), "yellow", seg=10)


@model("sains", "Lab table", "Meja makmal")
def lab_table():
    box(1.8, 0.8, 0.05, (0, 0, 0.88), "dgrey")
    box(1.76, 0.76, 0.84, (0, 0, 0.43), "lgrey")
    for x in (-0.6, 0, 0.6):
        box(0.5, 0.02, 0.7, (x, -0.385, 0.43), "white", bevel=0.005)
        box(0.08, 0.02, 0.02, (x, -0.4, 0.7), "dgrey", bevel=0.004)
    cyl(0.015, 0.25, (0.7, 0.3, 1.0), "grey", verts=10)
    cyl(0.012, 0.12, (0.7, 0.24, 1.12), "grey", verts=10, rot=(math.pi / 2, 0, 0))


PLANETS = (("sun", "Sun", "Matahari", 0.6, "yellow", 1.5), ("mercury", "Mercury", "Utarid", 0.08, "#B7A99A", 0), ("venus", "Venus", "Zuhrah", 0.14, "#F2C879", 0),
           ("earth", "Earth", "Bumi", 0.15, "blue", 0), ("moon", "Moon", "Bulan", 0.05, "lgrey", 0), ("mars", "Mars", "Marikh", 0.1, "#E2725B", 0),
           ("jupiter", "Jupiter", "Musytari", 0.4, "#E8C39E", 0), ("saturn", "Saturn", "Zuhal", 0.33, "#F1D592", 0), ("uranus", "Uranus", "Uranus", 0.22, "#9BE0E6", 0),
           ("neptune", "Neptune", "Neptun", 0.21, "#4C7BE8", 0))
for _pid, _en, _bm, _r, _c, _emit in PLANETS:
    def _mk(r=_r, c=_c, emit=_emit, pid=_pid):
        sphere(r, (0, 0, r), mat(c, emit=emit) if emit else c, seg=32)
        if pid == "earth":
            for x, y, z, s in ((0.06, -0.1, 0.2, 0.06), (-0.08, -0.08, 0.12, 0.07), (0.1, 0.05, 0.08, 0.05)):
                sphere(s, (x, y, z), "green", seg=10, scale=(1.2, 0.9, 0.8))
        if pid == "jupiter":
            torus(r * 0.99, r * 0.03, (0, 0, r * 1.15), "#B5734A")
            torus(r * 0.95, r * 0.03, (0, 0, r * 0.7), "#C98E5B")
        if pid == "saturn":
            torus(r * 1.7, r * 0.12, (0, 0, r), "#C9A86A", rot=(math.radians(20), 0, 0))
            bpy.context.object.scale = (1, 1, 0.15)
            bpy.ops.object.transform_apply(scale=True)
    _mk.__name__ = "planet_" + _pid
    model("sains", _en, _bm)(_mk)


# ---------------- matematik ----------------
SOLIDS = {"solid_cube": ("Cube", "Kubus", "blue"), "solid_cuboid": ("Cuboid", "Kuboid", "green"), "solid_cylinder": ("Cylinder", "Silinder", "red"),
          "solid_cone": ("Cone", "Kon", "orange"), "solid_sphere": ("Sphere", "Sfera", "purple"), "solid_pyramid": ("Square pyramid", "Piramid", "yellow"),
          "solid_prism": ("Triangular prism", "Prisma segi tiga", "pink"), "solid_hemisphere": ("Hemisphere", "Hemisfera", "teal")}
for _id, (_en, _bm, _c) in SOLIDS.items():
    def _mk(i=_id, c=_c):
        if i == "solid_cube":
            box(0.2, 0.2, 0.2, (0, 0, 0.1), c, bevel=0.004)
        elif i == "solid_cuboid":
            box(0.3, 0.15, 0.12, (0, 0, 0.06), c, bevel=0.004)
        elif i == "solid_cylinder":
            cyl(0.09, 0.22, (0, 0, 0.11), c, verts=32)
        elif i == "solid_cone":
            cone(0.1, 0.24, (0, 0, 0.12), c, verts=32)
        elif i == "solid_sphere":
            sphere(0.11, (0, 0, 0.11), c, seg=32)
        elif i == "solid_pyramid":
            cone(0.15, 0.2, (0, 0, 0.1), c, verts=4, rot=(0, 0, math.pi / 4))
        elif i == "solid_prism":
            cyl(0.1, 0.26, (0, 0, 0.05), c, verts=3, rot=(math.pi / 2, 0, 0), smooth=False)
        elif i == "solid_hemisphere":
            sphere(0.12, (0, 0, 0), c, seg=32)
            o = bpy.context.object
            bpy.ops.object.mode_set(mode="EDIT"); bpy.ops.mesh.select_all(action="DESELECT"); bpy.ops.object.mode_set(mode="OBJECT")
            for v in o.data.vertices:
                v.select = v.co.z < -1e-4
            bpy.ops.object.mode_set(mode="EDIT"); bpy.ops.mesh.delete(type="VERT")
            bpy.ops.mesh.select_all(action="SELECT"); bpy.ops.mesh.fill_holes(sides=0); bpy.ops.object.mode_set(mode="OBJECT")
    _mk.__name__ = _id
    model("matematik", _en, _bm)(_mk)


@model("matematik", "Dice", "Dadu")
def dice():
    box(0.08, 0.08, 0.08, (0, 0, 0.04), "white", bevel=0.012)
    pips = {(0, 0, 1): [(0, 0)], (0, 0, -1): [(-1, -1), (1, -1), (-1, 0), (1, 0), (-1, 1), (1, 1)], (1, 0, 0): [(-1, -1), (1, 1)],
            (-1, 0, 0): [(-1, -1), (1, -1), (-1, 1), (1, 1), (0, 0)], (0, -1, 0): [(-1, -1), (0, 0), (1, 1)], (0, 1, 0): [(-1, -1), (1, -1), (-1, 1), (1, 1)]}
    for (nx, ny, nz), pts in pips.items():
        for a, b in pts:
            off = 0.02
            if nz:
                loc = (a * off, b * off, 0.04 + nz * 0.04)
            elif nx:
                loc = (nx * 0.04, a * off, 0.04 + b * off)
            else:
                loc = (a * off, ny * 0.04, 0.04 + b * off)
            sphere(0.0075, loc, "red" if len(pts) == 1 else "ink", seg=8)


@model("matematik", "Abacus (sempoa)", "Sempoa")
def sempoa():
    box(0.42, 0.04, 0.03, (0, 0, 0.015), "dwood")
    box(0.42, 0.04, 0.03, (0, 0, 0.285), "dwood")
    box(0.03, 0.04, 0.3, (-0.195, 0, 0.15), "dwood")
    box(0.03, 0.04, 0.3, (0.195, 0, 0.15), "dwood")
    box(0.36, 0.04, 0.015, (0, 0, 0.2), "dwood")
    for i in range(9):
        x = -0.16 + i * 0.04
        cyl(0.003, 0.25, (x, 0, 0.15), "grey", verts=6)
        sphere(0.016, (x, 0, 0.24), "red", seg=10, scale=(1, 1, 0.7))
        for k in range(4):
            sphere(0.016, (x, 0, 0.04 + k * 0.026 + (0.03 if i % 3 == 0 and k == 3 else 0)), "yellow", seg=10, scale=(1, 1, 0.7))


@model("matematik", "Base-ten rod", "Rod puluh")
def base10_rod():
    for i in range(10):
        box(0.0195, 0.0195, 0.0195, (0, 0, 0.01 + i * 0.02), "green", bevel=0.001)


@model("matematik", "Base-ten flat", "Kepingan ratus")
def base10_flat():
    for i in range(10):
        for k in range(10):
            box(0.0195, 0.0195, 0.0195, (-0.09 + i * 0.02, -0.09 + k * 0.02, 0.01), "blue", bevel=0.001)


@model("matematik", "Balance scale", "Neraca")
def balance_scale():
    box(0.3, 0.12, 0.03, (0, 0, 0.015), "dwood")
    cyl(0.012, 0.35, (0, 0, 0.2), "dwood", verts=10)
    box(0.5, 0.02, 0.015, (0, 0, 0.375), "wood")
    for x in (-0.24, 0.24):
        cyl(0.002, 0.12, (x, 0, 0.31), "ink", verts=4)
        cyl(0.07, 0.015, (x, 0, 0.25), "gold", verts=24)


# ---------------- pjpk ----------------
@model("pjpk", "Football", "Bola sepak")
def football():
    sphere(0.11, (0, 0, 0.11), "white", seg=24)
    for v in ((0, 0, 1), (0.9, 0, 0.4), (-0.5, 0.75, 0.4), (-0.5, -0.75, 0.4), (0.5, 0.75, -0.4), (0.5, -0.75, -0.4), (-0.9, 0, -0.4), (0, 0, -1)):
        n = math.sqrt(sum(c * c for c in v))
        sphere(0.035, tuple(0.1 * c / n + (0.11 if j == 2 else 0) for j, c in enumerate(v)), "ink", seg=6, scale=(1, 1, 0.5))


@model("pjpk", "Sepak takraw ball", "Bola sepak takraw")
def takraw_ball():
    sphere(0.07, (0, 0, 0.07), "#E8C547", seg=12)
    for a in (0, 60, 120):
        torus(0.071, 0.004, (0, 0, 0.07), "#B8952A", rot=(math.radians(a), math.radians(a / 2), 0))


@model("pjpk", "Training cone", "Kon latihan")
def training_cone():
    box(0.24, 0.24, 0.02, (0, 0, 0.01), "orange", bevel=0.005)
    cone(0.1, 0.36, (0, 0, 0.2), "orange", verts=24)
    cyl(0.066, 0.05, (0, 0, 0.18), "white", r2=0.05)


@model("pjpk", "Basketball", "Bola keranjang")
def basketball():
    sphere(0.12, (0, 0, 0.12), "orange", seg=24)
    torus(0.121, 0.003, (0, 0, 0.12), "ink")
    torus(0.121, 0.003, (0, 0, 0.12), "ink", rot=(math.pi / 2, 0, 0))


# ---------------- sejarah / environment ----------------
@model("sejarah", "Malaysian flag on pole", "Jalur Gemilang bertiang")
def flag_pole():
    cyl(0.02, 2.4, (0, 0, 1.2), "lgrey", verts=10)
    sphere(0.04, (0, 0, 2.42), "gold", seg=10)
    w, h = 1.0, 0.5
    for i in range(14):
        box(w, 0.01, h / 14, (0.02 + w / 2, 0, 2.3 - h / 28 - i * h / 14), "dred" if i % 2 == 0 else "white", bevel=0)
    box(w / 2, 0.014, h * 8 / 14, (0.02 + w / 4, 0, 2.3 - h * 4 / 14), "#010066", bevel=0)
    sphere(0.06, (0.18, -0.008, 2.3 - h * 4 / 14), "#FFCC00", seg=10, scale=(1, 0.1, 1))
    sphere(0.045, (0.32, -0.008, 2.3 - h * 4 / 14), "#FFCC00", seg=10, scale=(1, 0.1, 1))


@model("sejarah", "Malay village house", "Rumah kampung")
def rumah_kampung():
    for x in (-1.6, 0, 1.6):
        for y in (-1.1, 1.1):
            box(0.15, 0.15, 1.2, (x, y, 0.6), "dwood")
    box(3.6, 2.6, 0.12, (0, 0, 1.25), "wood")
    box(3.4, 2.4, 1.6, (0, 0, 2.1), "wood")
    for x in (-1.0, 1.0):
        box(0.6, 0.05, 0.7, (x, -1.21, 2.2), "sky", bevel=0)
    box(0.7, 0.05, 1.3, (0, -1.21, 1.95), "dwood", bevel=0)
    bpy.ops.mesh.primitive_cone_add(vertices=4, radius1=2.9, radius2=0.0, depth=1.6, location=(0, 0, 3.7), rotation=(0, 0, math.pi / 4))
    o = bpy.context.object
    o.scale = (1.0, 0.66, 1)
    bpy.ops.object.transform_apply(scale=True)
    _finish(o, "#8D5A3B")
    for k in range(4):
        box(0.8, 0.25, 0.06, (0, -1.45 - k * 0.22, 1.1 - k * 0.27), "wood")


@model("environment", "Tree", "Pokok")
def tree():
    cyl(0.18, 1.6, (0, 0, 0.8), "wood", verts=8, r2=0.12, smooth=False)
    for x, y, z, r in ((0, 0, 2.1, 0.9), (0.6, 0.2, 1.7, 0.6), (-0.6, -0.1, 1.75, 0.65), (0.1, -0.5, 1.8, 0.55)):
        bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=2, radius=r, location=(x, y, z))
        _finish(bpy.context.object, "green")


@model("environment", "Coconut tree", "Pokok kelapa")
def coconut_tree():
    for i in range(8):
        cyl(0.13 - i * 0.008, 0.45, (i * 0.04, 0, 0.225 + i * 0.44), "wood", verts=8, r2=0.12 - i * 0.008, smooth=False, rot=(0, math.radians(5), 0))
    for a in range(0, 360, 60):
        r = math.radians(a)
        box(1.4, 0.3, 0.03, (0.3 + 0.65 * math.cos(r), 0.65 * math.sin(r), 3.55), "dgreen", bevel=0, rot=(0, math.radians(25), r))
    for a in (0, 120, 240):
        r = math.radians(a)
        sphere(0.12, (0.3 + 0.12 * math.cos(r), 0.12 * math.sin(r), 3.45), "dwood", seg=10)


@model("environment", "Rock", "Batu")
def rock():
    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=1, radius=0.4, location=(0, 0, 0.25))
    o = bpy.context.object
    o.scale = (1.3, 1, 0.7)
    for i, v in enumerate(o.data.vertices):
        v.co *= 0.85 + 0.3 * ((i * 37 % 11) / 11)
    bpy.ops.object.transform_apply(scale=True)
    _finish(o, "grey")


@model("environment", "Bush", "Semak")
def bush():
    for x, y, r in ((0, 0, 0.45), (0.45, 0.1, 0.35), (-0.45, -0.05, 0.38), (0.1, 0.35, 0.3)):
        bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=2, radius=r, location=(x, y, r * 0.8))
        _finish(bpy.context.object, "dgreen")


@model("environment", "School building", "Bangunan sekolah")
def school_building():
    box(12, 5, 6, (0, 0, 3), "cream")
    box(12.6, 5.6, 0.3, (0, 0, 3.0), "lgrey")
    bpy.ops.mesh.primitive_cone_add(vertices=4, radius1=9.0, radius2=0, depth=2.4, location=(0, 0, 7.2), rotation=(0, 0, math.pi / 4))
    o = bpy.context.object
    o.scale = (1, 0.45, 1)
    bpy.ops.object.transform_apply(scale=True)
    _finish(o, "red")
    for fl in (0, 1):
        for i in range(8):
            x = -5.1 + i * 1.45
            if fl == 0 and i in (3, 4):
                continue
            box(0.9, 0.08, 1.2, (x, -2.52, 1.6 + fl * 3), "sky", bevel=0)
    box(2.2, 0.1, 2.4, (0, -2.53, 1.2), "dwood", bevel=0)
    cyl(0.6, 0.1, (0, -2.55, 5.2), "white", rot=(math.pi / 2, 0, 0))


@model("environment", "Fence", "Pagar")
def fence():
    for x in (-0.9, -0.3, 0.3, 0.9):
        box(0.1, 0.1, 0.9, (x, 0, 0.45), "white")
        cone(0.075, 0.12, (x, 0, 0.96), "white", verts=4, rot=(0, 0, math.pi / 4))
    for z in (0.3, 0.65):
        box(2.0, 0.06, 0.1, (0, 0.06, z), "white")


# ---------------- rbt ----------------
@model("rbt", "Gear", "Gear")
def gear():
    cyl(0.1, 0.04, (0, 0, 0.02), "grey", verts=32)
    for i in range(12):
        a = i * math.pi / 6
        box(0.04, 0.035, 0.04, (0.115 * math.cos(a), 0.115 * math.sin(a), 0.02), "grey", rot=(0, 0, a), bevel=0.004)
    cyl(0.03, 0.045, (0, 0, 0.0225), "dgrey", verts=16)


@model("rbt", "Robot kit", "Kit robot")
def robot_kit():
    box(0.24, 0.18, 0.08, (0, 0, 0.07), "lgrey", bevel=0.01)
    for x in (-0.13, 0.13):
        cyl(0.05, 0.03, (x, 0, 0.05), "ink", rot=(0, math.pi / 2, 0))
    box(0.12, 0.08, 0.06, (0, 0.02, 0.14), "dgreen", bevel=0.005)
    for x in (-0.03, 0.03):
        cyl(0.018, 0.02, (x, -0.1, 0.09), "sky", rot=(math.pi / 2, 0, 0))
    cyl(0.003, 0.08, (0.05, 0.05, 0.2), "dgrey", verts=6)
    sphere(0.008, (0.05, 0.05, 0.245), "red", seg=8)


@model("rbt", "Toolbox", "Kotak peralatan")
def toolbox():
    box(0.45, 0.22, 0.2, (0, 0, 0.1), "red", bevel=0.01)
    box(0.46, 0.23, 0.02, (0, 0, 0.2), "dred", bevel=0.005)
    box(0.2, 0.03, 0.03, (0, 0, 0.27), "dgrey", bevel=0.008)
    box(0.03, 0.03, 0.06, (-0.085, 0, 0.235), "dgrey")
    box(0.03, 0.03, 0.06, (0.085, 0, 0.235), "dgrey")
    box(0.05, 0.01, 0.03, (0, -0.115, 0.17), "lgrey", bevel=0)


@model("rbt", "Hammer", "Tukul")
def hammer():
    box(0.03, 0.03, 0.3, (0, 0, 0.15), "wood", bevel=0.006)
    box(0.13, 0.04, 0.04, (0.02, 0, 0.31), "dgrey", bevel=0.006)


def main():
    argv = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
    names = argv or list(MODELS)
    index = []
    for name in names:
        folder, fn, en, bm = MODELS[name]
        reset()
        fn()
        info = export(name, folder)
        info.update(en=en, bm=bm)
        index.append(info)
        print("built", name, info["size_m"])
    if not argv:
        with open(os.path.join(OUT, "models_manifest.json"), "w", encoding="utf-8") as f:
            json.dump(index, f, ensure_ascii=False, indent=1)
    print(f"MODELS_OK {len(index)}")


main()
