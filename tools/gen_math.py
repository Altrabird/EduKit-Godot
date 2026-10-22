"""Matematik: 2D/3D shapes, operators, base-ten blocks, dice, sempoa, money blanks,
measuring tools, clock parts and data charts. 256 view box -> 512 px.
Numbers/values are added at runtime by kit components, never baked in."""
import math
import svg_lib as L
from svg_lib import C, INK, circle, ellipse, rect, path, poly, line, polyline, g, star_pts, ngon, shadow, shine, shine_ellipse, arc_d

W = "#FFFFFF"
CAT = "subjects/matematik"


def S(name, body, en, bm, tags=(), w=256, h=256, defs=""):
    L.save(CAT, name, L.doc(w, h, body, defs=defs), en=en, bm=bm, tags=["math", *tags])


def iso_box(x, y, w, d, h, col, sw=None):
    """Isometric cuboid; (x, y) is the front-bottom corner. w along +x/-y, d along -x/-y."""
    cx, cy = math.cos(math.radians(30)), math.sin(math.radians(30))
    p0 = (x, y)
    pr = (x + w * cx, y - w * cy)
    pl = (x - d * cx, y - d * cy)
    pb = (pr[0] - d * cx, pr[1] - d * cy)
    up = lambda p: (p[0], p[1] - h)
    return (poly([pl, p0, up(p0), up(pl)], L.shade(col, -0.2), sw=sw)
            + poly([p0, pr, up(pr), up(p0)], L.shade(col, -0.05), sw=sw)
            + poly([up(p0), up(pr), up(pb), up(pl)], L.shade(col, 0.25), sw=sw))


def main():
    L.SW = 7
    # ---------------- 2D shapes ----------------
    shapes2d = {
        "shape_circle": (circle(128, 124, 92, C["red"]), "Circle", "Bulatan"),
        "shape_square": (rect(40, 36, 176, 176, C["blue"], rx=6), "Square", "Segi empat sama"),
        "shape_rectangle": (rect(16, 66, 224, 120, C["green"], rx=6), "Rectangle", "Segi empat tepat"),
        "shape_triangle": (poly([(128, 28), (232, 210), (24, 210)], C["yellow"]), "Triangle", "Segi tiga"),
        "shape_pentagon": (poly(ngon(128, 132, 100, 5), C["purple"]), "Pentagon", "Pentagon"),
        "shape_hexagon": (poly(ngon(128, 124, 100, 6, rot=0), C["orange"]), "Hexagon", "Heksagon"),
        "shape_octagon": (poly(ngon(128, 124, 100, 8, rot=22.5), C["teal"]), "Octagon", "Oktagon"),
        "shape_oval": (ellipse(128, 124, 110, 70, C["pink"]), "Oval", "Bujur"),
        "shape_rhombus": (poly([(128, 20), (220, 124), (128, 228), (36, 124)], C["sky"]), "Rhombus", "Rombus"),
        "shape_trapezium": (poly([(76, 60), (180, 60), (236, 196), (20, 196)], C["lime"]), "Trapezium", "Trapezium"),
        "shape_semicircle": (path("M24,170 A104,104 0 0 1 232,170Z", C["gold"]), "Semicircle", "Semibulatan"),
        "shape_parallelogram": (poly([(70, 70), (236, 70), (186, 190), (20, 190)], C["red"]), "Parallelogram", "Segi empat selari"),
        "shape_star": (poly(star_pts(128, 134, 110, 46), C["yellow"]), "Star", "Bintang"),
        "shape_heart": (path("M128,226 C50,170 14,118 44,70 C70,30 112,44 128,74 C144,44 186,30 212,70 C242,118 206,170 128,226Z", C["red"]), "Heart", "Hati"),
    }
    for n, (b, en, bm) in shapes2d.items():
        S(n, b, en, bm, ["shape", "2d"])
    # ---------------- 3D shapes ----------------
    S("solid_cube", shadow(128, 226, 90, 10) + iso_box(128, 216, 100, 100, 100, C["blue"]), "Cube", "Kubus", ["shape", "3d"])
    S("solid_cuboid", shadow(128, 226, 110, 10) + iso_box(110, 210, 130, 70, 80, C["green"]), "Cuboid", "Kuboid", ["shape", "3d"])
    S("solid_cylinder", shadow(128, 226, 80, 10) + path("M58,60 L58,196 A70,24 0 0 0 198,196 L198,60", C["red"])
      + ellipse(128, 60, 70, 24, L.shade(C["red"], 0.3)) + shine("M76,90 L90,92 L90,200 L76,194Z", 0.35), "Cylinder", "Silinder", ["shape", "3d"])
    S("solid_cone", shadow(128, 226, 80, 10) + path("M128,24 L200,196 A72,24 0 0 1 56,196Z", C["orange"])
      + path("M56,196 A72,24 0 0 0 200,196", stroke=INK, sw=4, extra='stroke-dasharray="8 8"') + shine("M124,40 L100,190 L84,186Z", 0.35), "Cone", "Kon", ["shape", "3d"])
    S("solid_sphere", shadow(128, 228, 80, 10) + circle(128, 124, 96, C["purple"]) + path("M32,124 A96,30 0 0 0 224,124", stroke=INK, sw=4, extra='stroke-opacity="0.4"')
      + shine_ellipse(92, 84, 20, 32, 40, 0.45), "Sphere", "Sfera", ["shape", "3d"])
    S("solid_pyramid", shadow(128, 226, 100, 10) + poly([(128, 26), (40, 190), (140, 218)], L.shade(C["yellow"], -0.05))
      + poly([(128, 26), (140, 218), (224, 180)], L.shade(C["yellow"], -0.25)) + path("M40,190 L128,170 L224,180", stroke=INK, sw=4, extra='stroke-dasharray="8 8"')
      + line(128, 26, 128, 170, sw=4, extra='stroke-dasharray="8 8"'), "Pyramid", "Piramid", ["shape", "3d"])
    S("solid_hemisphere", shadow(128, 216, 90, 10) + path("M28,140 A100,100 0 0 0 228,140Z", C["teal"]) + ellipse(128, 140, 100, 30, L.shade(C["teal"], 0.3)), "Hemisphere", "Hemisfera", ["shape", "3d"])
    S("solid_prism", shadow(128, 226, 100, 10) + poly([(60, 210), (100, 120), (140, 210)], L.shade(C["pink"], 0.2))
      + poly([(140, 210), (100, 120), (196, 80), (236, 170)], L.shade(C["pink"], -0.15)) + poly([(60, 210), (140, 210), (236, 170), (156, 170)], C["pink"], extra='fill-opacity="0"'),
      "Triangular prism", "Prisma segi tiga", ["shape", "3d"])
    # ---------------- operators (tiles) ----------------
    ops = {"op_plus": ([rect(112, 64, 32, 128, W, rx=8, stroke=None), rect(64, 112, 128, 32, W, rx=8, stroke=None)], C["green"], "Plus", "Tambah"),
           "op_minus": ([rect(64, 112, 128, 32, W, rx=8, stroke=None)], C["red"], "Minus", "Tolak"),
           "op_times": ([g(rect(112, 64, 32, 128, W, rx=8, stroke=None), rect(64, 112, 128, 32, W, rx=8, stroke=None), transform="rotate(45 128 128)")], C["blue"], "Multiply", "Darab"),
           "op_divide": ([rect(64, 112, 128, 32, W, rx=8, stroke=None), circle(128, 76, 18, W, stroke=None), circle(128, 180, 18, W, stroke=None)], C["orange"], "Divide", "Bahagi"),
           "op_equals": ([rect(64, 90, 128, 28, W, rx=8, stroke=None), rect(64, 138, 128, 28, W, rx=8, stroke=None)], C["purple"], "Equals", "Sama dengan"),
           "op_less": ([polyline([(168, 72), (88, 128), (168, 184)], stroke=W, sw=30)], C["teal"], "Less than", "Kurang daripada"),
           "op_greater": ([polyline([(88, 72), (168, 128), (88, 184)], stroke=W, sw=30)], C["teal"], "Greater than", "Lebih daripada"),
           "op_percent": ([line(80, 180, 176, 76, stroke=W, sw=24), circle(86, 86, 20, "none", stroke=W, sw=16), circle(170, 170, 20, "none", stroke=W, sw=16)], C["pink"], "Percent", "Peratus"),
           "op_decimal": ([circle(128, 180, 22, W, stroke=None)], C["navy"], "Decimal point", "Titik perpuluhan")}
    for n, (inner, col, en, bm) in ops.items():
        S(n, rect(16, 22, 224, 224, L.shade(col, -0.3), rx=36) + rect(16, 12, 224, 224, col, rx=36) + "".join(inner), en, bm, ["operator", "tile"])
    # ---------------- base-ten blocks (Dienes) ----------------
    S("base10_unit", shadow(128, 200, 50, 8) + iso_box(128, 190, 60, 60, 60, C["yellow"]), "Unit cube (1)", "Kubus sa", ["base10"])
    S("base10_rod", shadow(128, 230, 110, 10) + "".join(iso_box(28 + i * 19.8, 226 - i * 11.4, 22.8, 22.8, 22.8, C["green"], sw=3) for i in range(10)),
      "Ten rod (10)", "Rod puluh", ["base10"])
    S("base10_flat", shadow(128, 230, 120, 10) + "".join(iso_box(128 + c * 19.0 - r * 19.0, 236 - c * 11 - r * 11, 22, 22, 18, C["blue"], sw=2) for r in range(9, -1, -1) for c in range(9, -1, -1)),
      "Hundred flat (100)", "Kepingan ratus", ["base10"])
    S("base10_block", shadow(128, 236, 110, 10) + iso_box(128, 232, 104, 104, 120, C["red"])
      + "".join(line(128 + i * 9, 232 - i * 5.2, 128 + i * 9, 112 - i * 5.2, sw=2, stroke=INK, extra='stroke-opacity="0.35"') for i in range(1, 10)),
      "Thousand block (1000)", "Blok ribu", ["base10"])
    # ---------------- dice ----------------
    pip = {1: [(0, 0)], 2: [(-1, -1), (1, 1)], 3: [(-1, -1), (0, 0), (1, 1)], 4: [(-1, -1), (1, -1), (-1, 1), (1, 1)],
           5: [(-1, -1), (1, -1), (0, 0), (-1, 1), (1, 1)], 6: [(-1, -1), (1, -1), (-1, 0), (1, 0), (-1, 1), (1, 1)]}
    for n, pts in pip.items():
        S(f"dice_{n}", shadow(128, 232, 90, 8) + rect(30, 34, 196, 196, L.shade(C["lgrey"], -0.1), rx=36) + rect(30, 26, 196, 196, W, rx=36)
          + "".join(circle(128 + x * 54, 124 + y * 54, 20, C["red"] if n == 1 else INK, stroke=None) for x, y in pts), f"Dice {n}", f"Dadu {n}", ["dice", "probability"])
    # ---------------- sempoa (soroban) ----------------
    beads = ""
    for col in range(7):
        x = 46 + col * 27.5
        beads += line(x, 40, x, 220, stroke=C["dwood"], sw=5)
        beads += ellipse(x, 62, 12, 9, C["red"], sw=4)
        for k in range(4):
            beads += ellipse(x, 134 + k * 20 + (0 if k else 0), 12, 9, C["yellow"], sw=4)
    S("sempoa", shadow(128, 240, 120, 8) + rect(16, 28, 224, 204, C["wood"], rx=10) + rect(30, 40, 196, 180, C["cream"], rx=4, sw=4) + beads + rect(30, 92, 196, 12, C["dwood"], sw=4),
      "Abacus (sempoa)", "Sempoa", ["counting"])
    # ---------------- money blanks (value text is drawn by kit/components/money.gd) ----------------
    for n, col, r in (("coin_5sen", "#C9CED6", 62), ("coin_10sen", "#C9CED6", 72), ("coin_20sen", "#D9C9A3", 84), ("coin_50sen", "#D9C9A3", 96)):
        S(n, shadow(128, 228, r * 0.8, 8) + circle(128, 128, r, L.shade(col, -0.15)) + circle(128, 124, r, col) + circle(128, 124, r - 12, "none", sw=4, stroke=L.shade(col, -0.35))
          + "".join(circle(128 + (r - 6) * math.cos(math.radians(a)), 124 + (r - 6) * math.sin(math.radians(a)), 1.8, L.shade(col, -0.4), stroke=None) for a in range(0, 360, 12))
          + shine_ellipse(128 - r * 0.45, 124 - r * 0.45, r * 0.12, r * 0.25, 40, 0.6), f"{n[5:]} coin (blank)", f"Syiling {n[5:]}", ["money", "coin"])
    for n, col in (("note_rm1", "#4C7BE8"), ("note_rm5", "#3FAE6A"), ("note_rm10", "#E5484D"), ("note_rm20", "#F29D38"), ("note_rm50", "#2BA6A0"), ("note_rm100", "#8E5BD0")):
        body = (rect(8, 70, 368, 176, L.shade(col, -0.25), rx=14) + rect(8, 62, 368, 176, col, rx=14)
                + rect(22, 76, 340, 148, "none", rx=8, sw=4, stroke=L.shade(col, 0.5))
                + circle(296, 150, 52, L.shade(col, 0.35), sw=4) + poly(star_pts(296, 150, 30, 12, 14), L.shade(col, 0.6), sw=3)
                + "".join(path(f"M40,{100 + i * 18} Q120,{80 + i * 18} 200,{100 + i * 18}", stroke=L.shade(col, 0.3), sw=3) for i in range(6))
                + rect(36, 186, 90, 26, L.shade(col, 0.6), rx=6, sw=3))
        S(n, body, f"RM{n[7:]} note (blank)", f"Wang kertas RM{n[7:]}", ["money", "note"], w=384, h=256)
    # ---------------- measurement ----------------
    S("protractor", path("M18,196 A110,110 0 0 1 238,196Z", C["glass"], extra='fill-opacity="0.9"') + path("M88,196 A40,40 0 0 1 168,196", stroke=INK, sw=5)
      + "".join(line(128 + 110 * math.cos(math.radians(a)), 196 - 110 * math.sin(math.radians(a)),
                     128 + (92 if a % 30 == 0 else 100) * math.cos(math.radians(a)), 196 - (92 if a % 30 == 0 else 100) * math.sin(math.radians(a)), sw=3) for a in range(10, 180, 10))
      + circle(128, 196, 6, C["red"], sw=3), "Protractor", "Protraktor", ["measure", "angle"])
    S("set_square", poly([(30, 226), (30, 30), (226, 226)], C["glass"]) + poly([(62, 190), (62, 110), (142, 190)], W) + "".join(line(30, 50 + i * 18, 42, 50 + i * 18, sw=3) for i in range(10)),
      "Set square", "Sesiku", ["measure", "angle"])
    S("compasses", line(128, 40, 70, 220, stroke=C["dgrey"], sw=14) + line(128, 40, 186, 220, stroke=C["dgrey"], sw=14) + poly([(180, 206), (192, 206), (186, 238)], C["yellow"], sw=4)
      + line(70, 220, 66, 240, sw=4) + circle(128, 40, 16, C["red"]) + rect(120, 6, 16, 24, C["red"], rx=4), "Compasses", "Jangka lukis", ["measure"])
    S("ruler_long", rect(8, 96, 368, 64, C["yellow"], rx=6) + "".join(line(24 + i * 11.2, 96, 24 + i * 11.2, 96 + (28 if i % 10 == 0 else 20 if i % 5 == 0 else 12), sw=3) for i in range(31)),
      "Ruler (30 cm)", "Pembaris", ["measure", "length"], w=384, h=256)
    S("tape_measure", circle(110, 128, 84, C["yellow"]) + circle(110, 128, 30, C["lgrey"]) + rect(150, 168, 100, 36, C["yellow"], sw=5)
      + "".join(line(160 + i * 12, 168, 160 + i * 12, 180, sw=3) for i in range(8)) + rect(240, 160, 12, 52, C["dgrey"], rx=3), "Tape measure", "Pita ukur", ["measure", "length"])
    S("weighing_scale", shadow(128, 236, 90, 8) + rect(40, 64, 176, 168, C["red"], rx=24) + circle(128, 150, 62, W) + path(arc_d(128, 150, 50, 200, 340), stroke=INK, sw=4)
      + line(128, 150, 160, 112, stroke=C["red"], sw=6) + circle(128, 150, 7, INK, stroke=None) + rect(30, 40, 196, 26, C["lgrey"], rx=8), "Weighing scale", "Penimbang", ["measure", "mass"])
    S("balance_scale", shadow(128, 240, 70, 8) + rect(116, 60, 24, 170, C["dwood"]) + rect(70, 222, 116, 18, C["dwood"], rx=6) + rect(20, 52, 216, 14, C["wood"], rx=6)
      + line(40, 66, 20, 140, sw=4) + line(40, 66, 60, 140, sw=4) + line(216, 66, 196, 140, sw=4) + line(216, 66, 236, 140, sw=4)
      + path("M8,140 L72,140 C66,166 14,166 8,140Z", C["gold"]) + path("M184,140 L248,140 C242,166 190,166 184,140Z", C["gold"]) + circle(128, 56, 14, C["gold"]),
      "Balance scale", "Neraca", ["measure", "mass"])
    S("measuring_jug", shadow(128, 236, 80, 8) + path("M180,80 C226,80 226,170 180,170", stroke=INK, sw=18) + path("M180,80 C226,80 226,170 180,170", stroke=C["glass"], sw=8)
      + path("M50,36 L190,36 L180,224 L60,224Z", C["glass"]) + path("M55,120 L185,120 L180,224 L60,224Z", C["sky"], stroke=None) + path("M50,36 L190,36 L180,224 L60,224Z")
      + "".join(line(64, 70 + i * 30, 90, 70 + i * 30, sw=4) for i in range(5)), "Measuring jug", "Jag penyukat", ["measure", "volume"])
    # clock parts for kit/components/analog_clock.gd (hands rotate about the canvas centre)
    S("clock_face", circle(128, 128, 120, C["blue"]) + circle(128, 128, 106, W, sw=5)
      + "".join(line(128 + 92 * math.cos(math.radians(a)), 128 + 92 * math.sin(math.radians(a)),
                     128 + (100 if a % 30 else 80) * math.cos(math.radians(a)), 128 + (100 if a % 30 else 80) * math.sin(math.radians(a)), sw=6 if a % 30 == 0 else 3) for a in range(0, 360, 6)),
      "Clock face", "Muka jam", ["time", "clock"])
    S("clock_hand_hour", path("M120,136 L122,72 L128,60 L134,72 L136,136Z", C["navy"], sw=4), "Hour hand", "Jarum jam", ["time", "clock"])
    S("clock_hand_minute", path("M123,140 L124,40 L128,26 L132,40 L133,140Z", C["red"], sw=4) + circle(128, 128, 10, C["yellow"], sw=4), "Minute hand", "Jarum minit", ["time", "clock"])
    # ---------------- data handling ----------------
    S("chart_bar", rect(20, 20, 216, 216, W, rx=12) + line(44, 40, 44, 212, sw=5) + line(44, 212, 220, 212, sw=5)
      + rect(60, 140, 30, 72, C["blue"], sw=4) + rect(102, 90, 30, 122, C["red"], sw=4) + rect(144, 120, 30, 92, C["yellow"], sw=4) + rect(186, 60, 30, 152, C["green"], sw=4),
      "Bar chart", "Carta palang", ["data"])
    S("chart_pie", circle(128, 128, 104, C["blue"]) + path("M128,128 L128,24 A104,104 0 0 1 232,128Z", C["yellow"]) + path("M128,128 L232,128 A104,104 0 0 1 76,218Z", C["red"])
      + path("M128,128 L76,218 A104,104 0 0 1 28,100Z", C["green"]), "Pie chart", "Carta pai", ["data"])
    S("pictograph", rect(14, 24, 228, 208, W, rx=12) + "".join(circle(70 + c * 34, 60 + r * 52, 13, [C["red"], C["yellow"], C["green"], C["blue"]][r], sw=4)
                                                                for r in range(4) for c in range((5, 3, 4, 2)[r]))
      + "".join(rect(28, 48 + r * 52, 20, 24, L.shade([C["red"], C["yellow"], C["green"], C["blue"]][r], 0.4), rx=4, sw=3) for r in range(4)),
      "Pictograph", "Piktograf", ["data"])
    S("counter_red", circle(128, 132, 80, L.shade(C["red"], -0.3)) + circle(128, 124, 80, C["red"]) + circle(128, 124, 56, "none", sw=4, stroke=L.shade(C["red"], -0.3)), "Counter (red)", "Pembilang merah", ["counting"])
    S("counter_yellow", circle(128, 132, 80, L.shade(C["yellow"], -0.3)) + circle(128, 124, 80, C["yellow"]) + circle(128, 124, 56, "none", sw=4, stroke=L.shade(C["yellow"], -0.3)), "Counter (yellow)", "Pembilang kuning", ["counting"])
    for col in ("red", "blue", "green", "yellow"):
        S(f"link_cube_{col}", iso_box(128, 210, 90, 90, 90, C[col]) + rect(110, 50, 36, 22, L.shade(C[col], 0.2), rx=4, sw=4), f"Linking cube ({col})", "Kiub bercantum", ["counting"])


if __name__ == "__main__":
    main()
    print(len(L._manifest), "math assets")
