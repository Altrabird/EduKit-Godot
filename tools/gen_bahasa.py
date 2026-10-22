"""Picture vocabulary for the language subjects. Every item carries BM + EN names in the
manifest so any language game can use any picture.
  bahasa_melayu   : local fruit, food, traditional games/culture, folk-tale animals
  bahasa_inggeris : animals, transport, home & clothing objects
256 view box -> 512 px."""
import math
import svg_lib as L
from svg_lib import C, INK, circle, ellipse, rect, path, poly, line, polyline, g, star_pts, ngon, shadow, shine, shine_ellipse, arc_d

W = "#FFFFFF"
PINK = "#FF9EBB"


def BM(name, body, en, bm, tags=(), defs=""):
    L.save("subjects/bahasa_melayu", name, L.doc(256, 256, body, defs=defs), en=en, bm=bm, tags=["vocab", *tags])


def BI(name, body, en, bm, tags=()):
    L.save("subjects/bahasa_inggeris", name, L.doc(256, 256, body), en=en, bm=bm, tags=["vocab", *tags])


def eyes(cx, cy, dx=26, r=10, look=0):
    return "".join(circle(cx + s * dx, cy, r, INK, stroke=None) + circle(cx + s * dx + 3 + look, cy - 4, r * 0.35, W, stroke=None) for s in (-1, 1))


def cheeks(cx, cy, dx=44):
    return "".join(ellipse(cx + s * dx, cy, 11, 7, PINK, stroke=None, extra='fill-opacity="0.8"') for s in (-1, 1))


def smile(cx, cy, w=14):
    return path(f"M{cx - w},{cy} Q{cx},{cy + w} {cx + w},{cy}", stroke=INK, sw=5)


def cat_mouth(cx, cy):
    return path(f"M{cx - 14},{cy + 4} Q{cx - 7},{cy + 12} {cx},{cy + 2} Q{cx + 7},{cy + 12} {cx + 14},{cy + 4}", stroke=INK, sw=5) + poly([(cx - 7, cy - 6), (cx + 7, cy - 6), (cx, cy + 2)], PINK, sw=3)


def body_blob(col, belly=None):
    b = ellipse(128, 206, 58, 36, col)
    if belly:
        b += ellipse(128, 212, 34, 22, belly, stroke=None)
    return shadow(128, 240, 70, 8) + b


def critter_head(col, ears="", extra="", face="", r=72, cy=112):
    return ears + circle(128, cy, r, col) + extra + face


def main():
    L.SW = 7
    # ======================= BAHASA MELAYU: buah-buahan =======================
    BM("durian", shadow(128, 236, 80, 8) + ellipse(128, 140, 92, 86, "#B5C14A")
       + "".join(poly([(128 + 80 * math.cos(math.radians(a)) - 9 * math.sin(math.radians(a)), 140 + 76 * math.sin(math.radians(a)) + 9 * math.cos(math.radians(a))),
                       (128 + 104 * math.cos(math.radians(a)), 140 + 98 * math.sin(math.radians(a))),
                       (128 + 80 * math.cos(math.radians(a)) + 9 * math.sin(math.radians(a)), 140 + 76 * math.sin(math.radians(a)) - 9 * math.cos(math.radians(a)))], "#9AA63A", sw=4)
                 for a in range(0, 360, 24))
       + "".join(poly([(x - 10, y + 8), (x, y - 12), (x + 10, y + 8)], "#9AA63A", sw=4) for x, y in ((96, 110), (140, 96), (170, 136), (110, 160), (150, 180), (80, 150), (128, 130)))
       + rect(120, 30, 16, 30, C["dwood"], rx=4), "Durian", "Durian", ["fruit", "local"])
    BM("rambutan", shadow(128, 236, 70, 8)
       + "".join(line(128 + 70 * math.cos(math.radians(a)), 140 + 70 * math.sin(math.radians(a)), 128 + 96 * math.cos(math.radians(a + 12)), 140 + 96 * math.sin(math.radians(a + 12)), stroke=C["dgreen"], sw=6)
                 for a in range(0, 360, 15))
       + circle(128, 140, 76, C["red"]) + "".join(path(f"M{128 + r * math.cos(math.radians(a)):.0f},{140 + r * math.sin(math.radians(a)):.0f} q6,-10 12,-2", stroke=L.shade(C["red"], -0.3), sw=4)
                                                for r, a in ((40, 20), (50, 140), (30, 250), (54, 300), (20, 80), (56, 200)))
       + shine_ellipse(100, 108, 12, 20, 40, 0.5) + rect(122, 44, 12, 28, C["dwood"], rx=4), "Rambutan", "Rambutan", ["fruit", "local"])
    BM("manggis", shadow(128, 236, 80, 8) + circle(128, 150, 82, "#5B2245") + shine_ellipse(92, 120, 14, 24, 40, 0.3)
       + "".join(ellipse(128 + 24 * math.cos(math.radians(a)), 74 + 10 * math.sin(math.radians(a)), 18, 10, C["dgreen"], sw=4, extra=f'transform="rotate({a} {128 + 24 * math.cos(math.radians(a)):.1f} {74 + 10 * math.sin(math.radians(a)):.1f})"')
                 for a in range(0, 360, 72)) + rect(122, 38, 12, 30, C["dwood"], rx=4), "Mangosteen", "Manggis", ["fruit", "local"])
    BM("pisang", shadow(128, 236, 90, 8) + "".join(g(path("M40,90 C60,200 170,230 226,150 C190,190 90,180 60,82Z", C["yellow"]) + path("M40,90 L56,78 L62,88", C["dwood"], sw=5), transform=f"rotate({a} 128 128)")
                                                for a in (-14, 0, 14)), "Banana", "Pisang", ["fruit", "local"])
    BM("betik", shadow(128, 236, 70, 8) + path("M128,26 C180,26 200,90 200,150 C200,210 170,236 128,236 C86,236 56,210 56,150 C56,90 76,26 128,26Z", C["orange"])
       + path("M128,60 C160,60 172,110 172,150 C172,190 154,212 128,212 C102,212 84,190 84,150 C84,110 96,60 128,60Z", "#FF7B54", sw=4)
       + "".join(circle(128 + dx, 150 + dy, 6, INK, stroke=None) for dx, dy in ((-10, -30), (8, -20), (-14, 0), (10, 4), (-6, 24), (12, 30), (0, -4))), "Papaya", "Betik", ["fruit", "local"])
    BM("nanas", shadow(128, 240, 70, 8) + "".join(path(f"M128,96 C{128 + dx * 0.4},{60} {128 + dx},{30} {128 + dx * 1.2},{14} C{128 + dx * 0.4},{40} 128,70 128,96Z", C["green"], sw=5) for dx in (-50, -20, 0, 20, 50))
       + ellipse(128, 166, 70, 76, C["gold"])
       + g("".join(line(40 + i * 24, 90, 150 + i * 24, 250, stroke=L.shade(C["gold"], -0.3), sw=4) + line(40 + i * 24, 250, 150 + i * 24, 90, stroke=L.shade(C["gold"], -0.3), sw=4) for i in range(-5, 6)),
           extra='clip-path="url(#fruit)"') + ellipse(128, 166, 70, 76, "none"),
       "Pineapple", "Nanas", ["fruit", "local"], defs='<clipPath id="fruit"><ellipse cx="128" cy="166" rx="70" ry="76"/></clipPath>')
    BM("kelapa", shadow(128, 236, 80, 8) + circle(128, 140, 90, "#7A4A2A") + path("M50,120 C80,90 176,90 206,120", stroke=L.shade("#7A4A2A", 0.3), sw=6)
       + circle(110, 112, 8, INK, stroke=None) + circle(146, 112, 8, INK, stroke=None) + circle(128, 136, 8, INK, stroke=None), "Coconut", "Kelapa", ["fruit", "local"])
    BM("tembikai", shadow(128, 228, 100, 8) + path("M16,100 A112,112 0 0 0 240,100Z", C["green"]) + path("M30,100 A98,98 0 0 0 226,100Z", W, stroke=None)
       + path("M38,100 A90,90 0 0 0 218,100Z", C["red"], stroke=None) + line(16, 100, 240, 100)
       + "".join(ellipse(x, y, 4, 7, INK, stroke=None) for x, y in ((80, 130), (110, 150), (140, 150), (170, 130), (96, 170), (156, 170), (128, 125))), "Watermelon", "Tembikai", ["fruit", "local"])
    BM("mangga", shadow(128, 236, 80, 8) + path("M60,90 C90,30 220,60 210,150 C200,220 120,240 80,200 C40,160 40,120 60,90Z", "#FFC300")
       + path("M60,90 C70,130 130,150 210,150 C200,220 120,240 80,200 C40,160 40,120 60,90Z", "#8BC34A", stroke=None, extra='fill-opacity="0.6"')
       + path("M60,90 C90,30 220,60 210,150 C200,220 120,240 80,200 C40,160 40,120 60,90Z") + shine_ellipse(120, 80, 20, 10, 10, 0.5), "Mango", "Mangga", ["fruit", "local"])
    BM("belimbing", shadow(128, 236, 90, 8) + path("M" + " ".join(f"{x:.1f},{y:.1f}" for x, y in L.star_pts(128, 132, 108, 58)) + "Z", "#E8D93A", extra='stroke-linejoin="round"')
       + poly(L.star_pts(128, 132, 80, 42), "#F5EA7A", sw=4) + "".join(ellipse(128 + 30 * math.cos(math.radians(a)), 132 + 30 * math.sin(math.radians(a)), 5, 9, C["dwood"], stroke=None,
                                                                         extra=f'transform="rotate({a + 90} {128 + 30 * math.cos(math.radians(a)):.1f} {132 + 30 * math.sin(math.radians(a)):.1f})"') for a in range(-90, 270, 72))
       + shine_ellipse(96, 86, 8, 16, 30, 0.5), "Star fruit", "Belimbing", ["fruit", "local"])
    BM("jambu_air", shadow(128, 236, 70, 8) + path("M96,40 L160,40 C200,80 210,160 190,200 C176,230 80,230 66,200 C46,160 56,80 96,40Z", "#F25C78")
       + ellipse(128, 44, 32, 10, L.shade("#F25C78", -0.3)) + shine_ellipse(96, 110, 10, 30, 10, 0.5), "Rose apple", "Jambu air", ["fruit", "local"])
    BM("epal", shadow(128, 236, 80, 8) + path("M128,74 C80,40 30,70 36,130 C42,200 96,236 128,214 C160,236 214,200 220,130 C226,70 176,40 128,74Z", C["red"])
       + path("M128,74 C128,50 136,36 146,26", stroke=C["dwood"], sw=8) + path("M136,52 C150,30 186,30 196,44 C176,60 150,62 136,52Z", C["green"], sw=5) + shine_ellipse(76, 110, 12, 24, 20, 0.5),
       "Apple", "Epal", ["fruit"])
    BM("oren", shadow(128, 236, 80, 8) + circle(128, 140, 88, C["orange"]) + "".join(circle(128 + dx, 140 + dy, 3, L.shade(C["orange"], -0.25), stroke=None) for dx, dy in ((-40, -20), (30, -40), (50, 30), (-20, 50), (0, 0), (-56, 30), (40, -4)))
       + ellipse(128, 54, 10, 6, C["dgreen"]) + path("M130,54 C150,30 180,36 186,44 C170,60 146,60 130,54Z", C["green"], sw=5) + shine_ellipse(90, 104, 12, 22, 40, 0.5), "Orange", "Oren", ["fruit"])
    BM("anggur", shadow(128, 240, 60, 8) + path("M128,40 L128,16", stroke=C["dwood"], sw=8)
       + "".join(circle(x, y, 22, C["purple"]) + circle(x - 6, y - 7, 5, W, stroke=None, extra='fill-opacity="0.6"') for x, y in ((92, 60), (128, 56), (164, 60), (108, 96), (148, 96), (84, 126), (128, 132), (172, 126), (108, 166), (148, 166), (128, 200)))
       + path("M130,40 C150,16 190,20 196,34 C176,50 150,50 130,40Z", C["green"], sw=5), "Grapes", "Anggur", ["fruit"])
    BM("strawberi", shadow(128, 236, 70, 8) + path("M128,230 C60,190 30,120 50,86 C70,56 110,66 128,74 C146,66 186,56 206,86 C226,120 196,190 128,230Z", C["red"])
       + "".join(ellipse(128 + dx, 130 + dy, 3, 5, C["yellow"], stroke=None) for dx, dy in ((-40, -20), (0, -30), (40, -20), (-30, 20), (10, 10), (40, 30), (-10, 50), (20, 60), (-50, 50)))
       + "".join(poly([(128, 76), (128 + 50 * math.cos(math.radians(a)), 70 + 20 * math.sin(math.radians(a))), (128 + 30 * math.cos(math.radians(a + 20)), 76 + 10 * math.sin(math.radians(a + 20)))], C["green"], sw=4) for a in (180, 220, 300, 340, 0)),
       "Strawberry", "Strawberi", ["fruit"])
    # ======================= BAHASA MELAYU: makanan =======================
    BM("nasi_lemak", shadow(128, 236, 110, 8) + path("M8,170 C40,120 216,120 248,170 C216,236 40,236 8,170Z", C["dgreen"]) + path("M30,170 C60,140 196,140 226,170 C196,214 60,214 30,170Z", C["green"], stroke=None)
       + path("M70,170 C70,110 150,100 160,150 C160,190 70,196 70,170Z", W) + ellipse(184, 150, 26, 18, W, sw=5) + circle(184, 150, 11, C["yellow"], stroke=None)
       + path("M150,186 C160,170 196,170 206,186 C196,200 160,200 150,186Z", C["red"], sw=5) + "".join(ellipse(60 + i * 12, 196 - (i % 2) * 6, 8, 4, "#C68B59", sw=3) for i in range(4))
       + rect(186, 110, 30, 10, "#7CB342", rx=4, sw=3) + rect(194, 124, 26, 10, "#7CB342", rx=4, sw=3), "Nasi lemak", "Nasi lemak", ["food", "local"])
    BM("roti_canai", shadow(128, 228, 110, 8) + ellipse(128, 160, 116, 52, C["lgrey"]) + path("M40,150 C50,110 200,100 214,150 C200,190 60,196 40,150Z", "#F3C77B")
       + path("M60,146 C90,126 150,120 190,140 M70,166 C110,150 160,150 196,164", stroke="#C88A3E", sw=5) + path("M24,120 C24,100 60,100 60,120Z", "#E0A030", sw=5), "Roti canai", "Roti canai", ["food", "local"])
    BM("satay", "".join(line(30 + i * 18, 220, 200 + i * 10, 40 + i * 8, stroke=C["wood"], sw=6)
                        + "".join(ellipse(110 + i * 18 + k * 26, 136 - k * 26 + i * 4, 22, 14, "#A0522D", sw=4, extra=f'transform="rotate(-45 {110 + i * 18 + k * 26} {136 - k * 26 + i * 4})"') for k in range(3)) for i in range(3))
       + ellipse(70, 214, 50, 20, "#C88A3E"), "Satay", "Sate", ["food", "local"])
    BM("ketupat", shadow(128, 236, 70, 8) + poly([(128, 40), (210, 128), (128, 216), (46, 128)], "#C5D86D")
       + "".join(line(46 + 20.5 * (i + 1), 128 - 22 * (i + 1), 128 + 20.5 * (i + 1), 216 - 22 * (i + 1), stroke=C["dgreen"], sw=4) for i in range(3))
       + "".join(line(46 + 20.5 * (i + 1), 128 + 22 * (i + 1), 128 + 20.5 * (i + 1), 40 + 22 * (i + 1), stroke=C["dgreen"], sw=4) for i in range(3))
       + path("M128,40 C120,20 100,14 90,20 M128,40 C140,16 170,14 176,26", stroke=C["dgreen"], sw=6), "Ketupat", "Ketupat", ["food", "local", "festival"])
    BM("teh_tarik", shadow(128, 236, 60, 8) + path("M78,70 L178,70 L166,226 L90,226Z", C["glass"]) + path("M82,110 L174,110 L166,226 L90,226Z", "#C88A5A", stroke=None)
       + path("M82,90 L174,90 L174,110 L82,110Z", "#F5E6CC", stroke=None) + path("M78,70 L178,70 L166,226 L90,226Z") + path("M120,30 C110,50 140,50 128,64", stroke=C["lgrey"], sw=6),
       "Pulled tea", "Teh tarik", ["food", "drink", "local"])
    BM("kuih_lapis", "".join(rect(60, 70 + i * 22, 136, 22, [C["red"], W, C["pink"], W, C["red"], W, C["pink"]][i], sw=4) for i in range(7)) + rect(60, 70, 136, 154, "none", rx=4) + shadow(128, 236, 80, 6),
       "Layer cake", "Kuih lapis", ["food", "local"])
    BM("telur", shadow(128, 228, 100, 8) + path("M20,140 C20,80 90,60 128,70 C190,60 240,90 236,140 C232,200 160,220 128,210 C70,220 20,200 20,140Z", W) + circle(124, 140, 42, C["yellow"]) + shine_ellipse(110, 124, 8, 12, 40, 0.7),
       "Egg", "Telur", ["food"])
    BM("roti", shadow(128, 236, 90, 8) + path("M40,226 L40,110 C10,100 20,40 70,40 L186,40 C236,40 246,100 216,110 L216,226Z", "#E0A050") + path("M60,214 L60,110 C40,100 46,60 76,60 L180,60 C210,60 216,100 196,110 L196,214Z", "#FFE9B8", stroke=None),
       "Bread", "Roti", ["food"])
    BM("susu", shadow(128, 236, 60, 8) + path("M74,90 L128,50 L182,90 L182,226 L74,226Z", W) + poly([(74, 90), (128, 50), (182, 90)], C["blue"]) + rect(110, 30, 36, 24, C["blue"], rx=4)
       + rect(74, 130, 108, 60, C["sky"], stroke=None) + rect(74, 90, 108, 136, "none"), "Milk", "Susu", ["food", "drink"])
    # ======================= BAHASA MELAYU: budaya & permainan tradisional =======================
    BM("wau", line(128, 12, 128, 244, stroke=C["dwood"], sw=5)
       + path("M128,40 C100,44 40,36 10,80 C44,100 96,96 128,104 C160,96 212,100 246,80 C216,36 156,44 128,40Z", C["red"])
       + path("M128,52 C108,58 66,58 44,78 C70,86 104,86 128,92 C152,86 186,86 212,78 C190,58 148,58 128,52Z", C["yellow"], sw=4)
       + path("M116,104 L140,104 L136,180 L120,180Z", C["blue"])
       + path("M30,146 C60,214 196,214 226,146 C190,168 160,172 128,170 C96,172 66,168 30,146Z", C["red"])
       + path("M64,176 C96,194 160,194 192,176", stroke=C["yellow"], sw=5)
       + path("M128,12 C116,20 116,36 128,40 C140,36 140,20 128,12Z", C["yellow"], sw=4)
       + "".join(circle(x, 76, 5, C["blue"], sw=2) for x in (80, 104, 152, 176)),
       "Wau bulan (Malay kite)", "Wau bulan", ["culture", "local", "toy"])
    BM("gasing", shadow(128, 236, 70, 8) + path("M30,120 C30,90 226,90 226,120 C226,160 160,200 128,230 C96,200 30,160 30,120Z", C["dwood"])
       + ellipse(128, 112, 98, 26, C["wood"]) + path("M30,120 C60,150 196,150 226,120", stroke=C["gold"], sw=8) + rect(118, 50, 20, 50, C["dwood"], rx=6) + path("M128,50 C160,20 210,40 230,20", stroke=C["cream"], sw=5),
       "Spinning top", "Gasing", ["culture", "local", "toy"])
    BM("congkak", shadow(128, 220, 120, 8) + path("M6,128 C6,96 30,84 50,84 L206,84 C226,84 250,96 250,128 C250,160 226,172 206,172 L50,172 C30,172 6,160 6,128Z", C["wood"])
       + ellipse(30, 128, 18, 30, C["dwood"], sw=5) + ellipse(226, 128, 18, 30, C["dwood"], sw=5)
       + "".join(circle(62 + i * 22, y, 9, C["dwood"], sw=3) + circle(62 + i * 22, y, 3, W, stroke=None) for i in range(7) for y in (108, 148)), "Congkak", "Congkak", ["culture", "local", "game", "math"])
    BM("rumah_kampung", shadow(128, 240, 120, 8) + "".join(rect(x, 180, 10, 56, C["dwood"], sw=4) for x in (40, 90, 160, 206))
       + rect(28, 110, 200, 74, C["wood"]) + poly([(10, 116), (128, 30), (246, 116)], "#8D5A3B") + poly([(96, 116), (128, 70), (160, 116)], C["cream"], sw=5)
       + rect(50, 128, 34, 34, C["sky"], sw=5) + rect(172, 128, 34, 34, C["sky"], sw=5) + rect(110, 128, 36, 56, C["dwood"], sw=5)
       + "".join(line(118 + k * 8, 186 + k * 14, 138 + k * 8, 186 + k * 14, sw=4) for k in range(4)), "Malay village house", "Rumah kampung", ["culture", "local", "home"])
    BM("perahu", path("M0,200 C40,190 60,210 100,200 C140,190 160,210 200,200 C230,192 250,206 256,204 L256,256 L0,256Z", C["blue"], stroke=None, extra='fill-opacity="0.5"')
       + path("M20,150 L236,150 C220,196 180,206 128,206 C76,206 36,196 20,150Z", C["red"]) + path("M30,150 L226,150", stroke=C["yellow"], sw=8)
       + line(128, 150, 128, 30, stroke=C["dwood"], sw=8) + poly([(134, 36), (210, 130), (134, 130)], C["cream"]), "Boat (perahu)", "Perahu", ["transport", "local"])
    # ======================= BAHASA MELAYU: watak cerita rakyat =======================
    BM("sang_kancil", shadow(128, 240, 60, 8) + "".join(line(x, 190, x, 238, stroke="#8D5A3B", sw=8) for x in (100, 116, 140, 156))
       + ellipse(128, 176, 44, 30, "#B07A4A") + ellipse(128, 186, 26, 14, C["cream"], stroke=None)
       + poly([(84, 56), (98, 30), (110, 74)], "#B07A4A") + poly([(172, 56), (158, 30), (146, 74)], "#B07A4A")
       + path("M128,140 C88,140 76,100 84,74 C96,50 160,50 172,74 C180,100 168,140 128,140Z", "#B07A4A")
       + ellipse(128, 120, 22, 16, C["cream"], stroke=None) + eyes(128, 92, 20, 10) + circle(128, 116, 6, INK, stroke=None) + smile(128, 126, 8),
       "Mouse deer (Sang Kancil)", "Sang Kancil", ["animal", "folktale", "local"])
    BM("buaya", shadow(128, 230, 120, 8) + path("M10,170 C30,140 70,130 110,136 L230,120 C246,122 248,136 236,142 L200,150 L236,160 C246,166 240,178 230,176 L110,186 C70,196 30,190 10,170Z", C["dgreen"])
       + "".join(poly([(x, 136 - (x - 110) * 0.13), (x + 6, 148 - (x - 110) * 0.13), (x + 12, 134 - (x - 110) * 0.13)], W, sw=2) for x in range(130, 220, 22))
       + "".join(poly([(30 + i * 22, 150), (40 + i * 22, 136), (50 + i * 22, 150)], C["green"], sw=4) for i in range(4))
       + circle(170, 116, 13, C["yellow"]) + circle(172, 116, 5, INK, stroke=None) + "".join(line(60 + i * 40, 188, 56 + i * 40, 214, stroke=C["dgreen"], sw=12) for i in range(3)),
       "Crocodile", "Buaya", ["animal", "folktale", "local"])
    BM("harimau", body_blob(C["orange"], W) + critter_head(C["orange"], ears=circle(70, 56, 22, C["orange"]) + circle(186, 56, 22, C["orange"]) + circle(70, 56, 10, PINK, stroke=None) + circle(186, 56, 10, PINK, stroke=None),
                                                          extra="".join(path(d, INK, stroke=None) for d in ("M128,40 L118,64 L138,64Z", "M60,100 L84,106 L60,114Z", "M196,100 L172,106 L196,114Z", "M64,136 L86,132 L70,146Z", "M192,136 L170,132 L186,146Z"))
                                                          + ellipse(128, 138, 40, 28, W, stroke=None), face=eyes(128, 102) + cat_mouth(128, 134) + cheeks(128, 130)),
       "Tiger", "Harimau", ["animal", "folktale", "local"])
    BM("gajah", body_blob(C["grey"]) + critter_head(C["grey"], ears=ellipse(48, 110, 44, 56, C["grey"]) + ellipse(208, 110, 44, 56, C["grey"]) + ellipse(48, 110, 26, 36, PINK, stroke=None) + ellipse(208, 110, 26, 36, PINK, stroke=None),
                                                   face=eyes(128, 96, 28) + path("M112,124 C112,170 116,200 96,206 C90,214 104,222 112,214 C134,200 146,170 144,124Z", C["grey"]) + cheeks(128, 120, 48)),
       "Elephant", "Gajah", ["animal", "folktale", "local"])
    BM("orang_utan", body_blob("#C1602B") + critter_head("#C1602B", ears=circle(58, 112, 20, "#C1602B"),
                                                         extra=circle(198, 112, 20, "#C1602B") + path("M128,58 C80,58 74,104 86,130 C96,160 160,160 170,130 C182,104 176,58 128,58Z", "#F2C29B")
                                                         + "".join(path(f"M{x},40 q8,-20 16,0", stroke="#C1602B", sw=6) for x in (100, 120, 140)),
                                                         face=eyes(128, 98, 20, 9) + ellipse(128, 128, 10, 6, INK, stroke=None) + smile(128, 138, 16)),
       "Orang utan", "Orang utan", ["animal", "local"])
    BM("kenyalang", shadow(128, 240, 70, 8) + path("M60,226 L80,160 L176,160 L196,226Z", C["black"]) + line(110, 226, 100, 246, stroke=C["dwood"], sw=6) + line(146, 226, 156, 246, stroke=C["dwood"], sw=6)
       + path("M70,180 C40,140 80,60 130,64 C150,64 160,80 160,100 C160,140 140,170 70,180Z", C["black"]) + path("M80,186 C90,176 170,176 180,186 L176,226 L84,226Z", W)
       + path("M150,80 C190,60 240,76 246,110 C220,104 190,108 160,114Z", C["yellow"]) + path("M146,68 C170,40 220,44 236,72 C214,70 180,72 150,84Z", C["red"])
       + circle(132, 92, 12, W) + circle(134, 92, 6, INK, stroke=None), "Rhinoceros hornbill", "Burung kenyalang", ["animal", "local", "bird"])
    BM("kura_kura", shadow(128, 230, 100, 8) + ellipse(220, 176, 26, 20, C["green"]) + circle(230, 170, 4, INK, stroke=None) + "".join(ellipse(x, 204, 16, 22, C["green"]) for x in (70, 180))
       + path("M30,196 C30,110 210,110 210,196Z", C["dgreen"]) + "".join(poly(ngon(cx, cy, 22, 6, rot=0), L.shade(C["dgreen"], 0.25), sw=4) for cx, cy in ((120, 150), (80, 170), (160, 170)))
       + line(30, 196, 210, 196), "Turtle", "Penyu", ["animal", "local", "sea"])
    # ======================= BAHASA INGGERIS: animals =======================
    BI("cat", body_blob("#FFB74D", W) + critter_head("#FFB74D", ears=poly([(64, 82), (70, 24), (114, 52)], "#FFB74D") + poly([(192, 82), (186, 24), (142, 52)], "#FFB74D")
                                                       + poly([(74, 66), (76, 40), (98, 54)], PINK, stroke=None) + poly([(182, 66), (180, 40), (158, 54)], PINK, stroke=None),
                                                       extra="".join(path(d, "#F57C00", stroke=None) for d in ("M128,40 L118,62 L138,62Z", "M108,42 L102,58 L114,56Z", "M148,42 L154,58 L142,56Z")),
                                                       face=eyes(128, 104) + cat_mouth(128, 132) + cheeks(128, 128) + "".join(line(128 + s * 50, 130 + k * 10, 128 + s * 86, 124 + k * 18, sw=3) for s in (-1, 1) for k in (0, 1))),
       "Cat", "Kucing", ["animal", "pet"])
    BI("dog", body_blob("#C68B59", C["cream"]) + critter_head("#C68B59", ears=ellipse(62, 100, 22, 44, C["dwood"], extra='transform="rotate(20 62 100)"') + ellipse(194, 100, 22, 44, C["dwood"], extra='transform="rotate(-20 194 100)"'),
                                                         extra=ellipse(128, 136, 36, 26, C["cream"], stroke=None) + circle(158, 86, 16, C["cream"], stroke=None),
                                                         face=eyes(128, 100) + ellipse(128, 124, 12, 8, INK, stroke=None) + smile(128, 140, 12) + path("M120,148 Q128,170 136,148Z", C["red"], sw=3)),
       "Dog", "Anjing", ["animal", "pet"])
    BI("rabbit", body_blob(W) + critter_head(W, ears=ellipse(96, 40, 18, 52, W) + ellipse(160, 40, 18, 52, W) + ellipse(96, 44, 8, 36, PINK, stroke=None) + ellipse(160, 44, 8, 36, PINK, stroke=None),
                                             face=eyes(128, 106) + poly([(120, 124), (136, 124), (128, 132)], PINK, sw=3) + path("M128,132 L128,140 M128,140 Q118,150 112,142 M128,140 Q138,150 144,142", stroke=INK, sw=4) + cheeks(128, 132)),
       "Rabbit", "Arnab", ["animal", "pet"])
    BI("cow", body_blob(W) + critter_head(W, ears=ellipse(54, 92, 26, 14, W) + ellipse(202, 92, 26, 14, W) + path("M84,56 C70,40 70,24 80,20", stroke=C["cream"], sw=12) + path("M172,56 C186,40 186,24 176,20", stroke=C["cream"], sw=12),
                                          extra=path("M90,60 C100,40 130,50 120,80 C110,90 86,80 90,60Z", INK, stroke=None) + ellipse(128, 146, 50, 32, PINK),
                                          face=eyes(128, 104, 30) + ellipse(110, 146, 7, 10, INK, stroke=None) + ellipse(146, 146, 7, 10, INK, stroke=None)),
       "Cow", "Lembu", ["animal", "farm"])
    BI("goat", body_blob(C["lgrey"]) + critter_head(C["lgrey"], ears=ellipse(56, 108, 28, 12, C["lgrey"]) + ellipse(200, 108, 28, 12, C["lgrey"]) + path("M96,52 C80,20 50,24 54,46", stroke=C["dgrey"], sw=12) + path("M160,52 C176,20 206,24 202,46", stroke=C["dgrey"], sw=12),
                                                     extra=path("M112,170 L128,214 L144,170Z", C["lgrey"]), face=eyes(128, 104, 26) + ellipse(128, 140, 14, 8, PINK, sw=3) + smile(128, 152, 10)),
       "Goat", "Kambing", ["animal", "farm"])
    BI("chicken", shadow(128, 240, 60, 8) + line(108, 214, 104, 240, stroke=C["orange"], sw=7) + line(148, 214, 152, 240, stroke=C["orange"], sw=7)
       + path("M60,150 C60,90 100,60 128,60 C170,60 200,100 200,150 C200,200 170,220 128,220 C86,220 60,200 60,150Z", W)
       + path("M100,66 C96,40 112,34 118,50 C120,30 138,30 136,52 C144,36 160,44 150,64Z", C["red"]) + poly([(160, 104), (196, 114), (160, 124)], C["yellow"], sw=5)
       + path("M152,126 C152,146 140,150 140,134Z", C["red"], sw=4) + circle(140, 98, 8, INK, stroke=None) + path("M70,150 C90,140 110,160 110,180 C90,186 70,170 70,150Z", C["lgrey"], sw=5),
       "Chicken", "Ayam", ["animal", "farm", "bird"])
    BI("duck", shadow(128, 240, 80, 8) + path("M30,170 C30,120 90,120 120,140 C110,100 120,60 156,60 C190,60 200,100 186,130 C230,130 230,200 160,214 L80,214 C50,214 30,196 30,170Z", C["yellow"])
       + path("M184,90 C210,84 236,92 238,102 C220,112 196,110 184,104Z", C["orange"]) + circle(166, 86, 8, INK, stroke=None) + path("M70,166 C90,150 130,160 140,180", stroke=L.shade(C["yellow"], -0.3), sw=6),
       "Duck", "Itik", ["animal", "farm", "bird"])
    BI("fish", path("M40,128 L4,92 L4,164Z", C["orange"]) + path("M30,128 C70,60 180,50 236,128 C180,206 70,196 30,128Z", C["orange"]) + path("M120,74 C140,50 170,56 176,76Z", C["orange"])
       + path("M150,80 C130,110 130,146 150,176", stroke=L.shade(C["orange"], -0.3), sw=5) + circle(196, 116, 12, W) + circle(198, 116, 6, INK, stroke=None) + path("M222,138 Q214,146 206,140", stroke=INK, sw=4),
       "Fish", "Ikan", ["animal", "sea"])
    BI("bird", shadow(128, 240, 60, 8) + line(110, 214, 106, 240, stroke=C["orange"], sw=6) + line(146, 214, 150, 240, stroke=C["orange"], sw=6)
       + circle(128, 140, 84, C["sky"]) + ellipse(128, 170, 50, 40, W, stroke=None) + path("M60,130 C30,150 50,190 90,180Z", C["blue"]) + poly([(128, 128), (156, 140), (128, 152)], C["orange"], sw=5)
       + eyes(128, 108, 24, 9) + path("M120,58 C110,36 130,30 128,56", C["blue"], sw=5), "Bird", "Burung", ["animal", "bird"])
    BI("monkey", body_blob("#8D5A3B", "#F2C29B") + critter_head("#8D5A3B", ears=circle(52, 112, 24, "#8D5A3B") + circle(204, 112, 24, "#8D5A3B") + circle(52, 112, 12, "#F2C29B", stroke=None) + circle(204, 112, 12, "#F2C29B", stroke=None),
                                                           extra=path("M128,86 C110,60 74,70 78,104 C70,150 110,168 128,168 C146,168 186,150 178,104 C182,70 146,60 128,86Z", "#F2C29B", stroke=None),
                                                           face=eyes(128, 104, 24) + circle(122, 128, 3, INK, stroke=None) + circle(134, 128, 3, INK, stroke=None) + smile(128, 140, 18)),
       "Monkey", "Monyet", ["animal", "jungle"])
    BI("owl", shadow(128, 240, 60, 8) + path("M48,200 C40,120 60,60 80,40 L100,70 L156,70 L176,40 C196,60 216,120 208,200 C200,236 56,236 48,200Z", "#8D6E63")
       + ellipse(128, 176, 50, 46, C["cream"], stroke=None) + circle(98, 104, 30, W) + circle(158, 104, 30, W) + circle(98, 106, 14, INK, stroke=None) + circle(158, 106, 14, INK, stroke=None)
       + circle(103, 100, 5, W, stroke=None) + circle(163, 100, 5, W, stroke=None) + poly([(118, 130), (138, 130), (128, 148)], C["orange"], sw=4)
       + "".join(path(f"M{x},{y} q8,8 16,0", stroke=L.shade("#8D6E63", -0.2), sw=4) for x, y in ((104, 168), (128, 168), (116, 186), (140, 186))), "Owl", "Burung hantu", ["animal", "bird"])
    BI("frog", shadow(128, 236, 90, 8) + ellipse(128, 170, 90, 58, C["green"]) + circle(80, 96, 34, C["green"]) + circle(176, 96, 34, C["green"])
       + circle(80, 96, 20, W, sw=5) + circle(176, 96, 20, W, sw=5) + circle(84, 98, 10, INK, stroke=None) + circle(172, 98, 10, INK, stroke=None)
       + path("M76,170 Q128,210 180,170", stroke=INK, sw=6) + cheeks(128, 168, 70) + ellipse(60, 222, 30, 12, C["green"]) + ellipse(196, 222, 30, 12, C["green"]), "Frog", "Katak", ["animal", "lifecycle", "frog"])
    BI("butterfly", "".join(g(path("M128,128 C90,40 20,40 26,100 C30,140 90,140 128,128Z", c1) + path("M128,128 C100,190 40,210 46,170 C50,140 100,130 128,128Z", c2) + circle(70, 92, 14, C["yellow"], sw=4),
                              transform=t) for t, c1, c2 in (("", C["purple"], C["pink"]), ("translate(256,0) scale(-1,1)", C["purple"], C["pink"])))
       + ellipse(128, 132, 10, 50, INK, stroke=None) + path("M124,86 C116,60 100,50 92,50 M132,86 C140,60 156,50 164,50", stroke=INK, sw=4), "Butterfly", "Rama-rama", ["animal", "insect", "lifecycle"])
    BI("caterpillar", "".join(circle(50 + i * 34, 160 - 18 * math.sin(i * 0.9), 28, C["green"] if i % 2 else C["lime"]) for i in range(5)) + circle(212, 120, 34, C["green"])
       + eyes(212, 112, 12, 7) + smile(212, 130, 10) + line(200, 88, 190, 62, sw=4) + line(224, 88, 234, 62, sw=4) + circle(190, 60, 5, C["red"], sw=3) + circle(234, 60, 5, C["red"], sw=3),
       "Caterpillar", "Beluncas", ["animal", "insect", "lifecycle"])
    BI("chrysalis", line(128, 10, 128, 40, stroke=C["dwood"], sw=8) + line(60, 12, 196, 12, stroke=C["dwood"], sw=10)
       + path("M128,40 C170,60 172,170 140,226 C134,236 122,236 116,226 C84,170 86,60 128,40Z", "#9CCC65") + "".join(path(f"M100,{y} Q128,{y + 10} 156,{y}", stroke=C["dgreen"], sw=4) for y in (90, 130, 170)),
       "Chrysalis (pupa)", "Kepompong", ["animal", "insect", "lifecycle"])
    BI("butterfly_eggs", ellipse(128, 150, 110, 70, C["green"]) + path("M30,150 L226,150", stroke=C["dgreen"], sw=5)
       + "".join(ellipse(x, y, 10, 13, C["cream"], sw=4) for x, y in ((100, 120), (124, 116), (148, 122), (112, 140), (138, 142))), "Butterfly eggs", "Telur rama-rama", ["animal", "insect", "lifecycle"])
    BI("bee", "".join(ellipse(x, 86, 30, 44, C["glass"], extra=f'transform="rotate({a} {x} 86)"') for x, a in ((100, -20), (156, 20)))
       + ellipse(128, 146, 74, 60, C["yellow"]) + "".join(path(f"M{x},{92 + 6} C{x - 10},130 {x - 10},170 {x},{200 - 6}", stroke=INK, sw=14) for x in (110, 150))
       + ellipse(128, 146, 74, 60, "none") + eyes(78, 136, 14, 7) + poly([(202, 140), (232, 146), (202, 152)], INK, sw=3), "Bee", "Lebah", ["animal", "insect"])
    BI("ant", "".join(line(100 + i * 30, 160, 84 + i * 30 + (i - 1) * 10, 214, sw=6) for i in range(3)) + "".join(line(100 + i * 30, 160, 116 + i * 30 + (i - 1) * 10, 214, sw=6) for i in range(3))
       + ellipse(60, 150, 44, 34, "#8B2E2E") + circle(130, 150, 26, "#8B2E2E") + circle(196, 130, 34, "#8B2E2E") + eyes(200, 124, 12, 6)
       + path("M190,98 C180,70 170,60 160,56 M206,98 C214,70 224,62 236,60", stroke=INK, sw=5), "Ant", "Semut", ["animal", "insect"])
    BI("snail", shadow(128, 230, 110, 8) + path("M20,216 C20,190 60,190 200,190 C230,190 236,140 220,110 L236,70 M220,110 L210,70", "#E8C39E") + path("M20,216 L200,216 C230,216 236,190 200,190", "#E8C39E")
       + circle(120, 140, 70, C["orange"]) + path("M120,140 m0,0 C120,124 144,124 144,144 C144,168 108,170 102,146 C96,116 136,100 158,122 C180,146 166,190 128,196", stroke=L.shade(C["orange"], -0.4), sw=6)
       + circle(236, 66, 7, INK, stroke=None) + circle(210, 66, 7, INK, stroke=None), "Snail", "Siput", ["animal"])
    # ======================= BAHASA INGGERIS: transport =======================
    wheel = lambda x, y, r=24: circle(x, y, r, INK) + circle(x, y, r * 0.45, C["lgrey"], stroke=None)
    BI("car", shadow(128, 226, 116, 8) + path("M10,190 L10,150 C10,130 30,124 50,122 L80,86 C88,76 100,72 112,72 L170,72 C184,72 194,80 200,92 L216,122 C236,124 248,134 248,152 L248,190Z", C["red"])
       + path("M92,92 L120,92 L120,122 L72,122Z", C["glass"], sw=5) + path("M134,92 L176,92 C184,92 190,98 194,106 L200,122 L134,122Z", C["glass"], sw=5)
       + wheel(66, 194) + wheel(196, 194) + rect(232, 150, 16, 12, C["yellow"], rx=3, sw=3), "Car", "Kereta", ["transport"])
    BI("bus", shadow(128, 232, 120, 8) + rect(8, 54, 240, 152, C["yellow"], rx=18) + "".join(rect(22 + i * 46, 74, 36, 44, C["glass"], rx=5, sw=5) for i in range(5))
       + rect(8, 140, 240, 14, C["dwood"], stroke=None, extra='fill-opacity="0.8"') + wheel(62, 206) + wheel(194, 206) + rect(222, 168, 22, 14, C["red"], rx=3, sw=3) + rect(8, 54, 240, 152, "none", rx=18),
       "School bus", "Bas sekolah", ["transport", "school"])
    BI("bicycle", wheel(60, 170, 48) + circle(60, 170, 40, C["lgrey"], sw=4) + wheel(196, 170, 48) + circle(196, 170, 40, C["lgrey"], sw=4)
       + polyline([(60, 170), (110, 100), (176, 100), (196, 170)], stroke=C["blue"], sw=10) + polyline([(110, 100), (128, 170), (176, 100)], stroke=C["blue"], sw=10)
       + line(128, 170, 60, 170, stroke=C["blue"], sw=10) + line(110, 100, 100, 74, sw=8) + rect(84, 64, 36, 12, INK, rx=5, stroke=None) + line(176, 100, 170, 64, sw=8) + line(160, 64, 186, 60, sw=8),
       "Bicycle", "Basikal", ["transport"])
    BI("motorcycle", wheel(56, 180, 40) + wheel(204, 180, 40) + path("M56,180 L96,120 L180,120 L204,180", stroke=C["dgrey"], sw=12)
       + path("M80,120 C90,90 170,90 186,120Z", C["blue"]) + rect(92, 96, 70, 16, INK, rx=8) + line(176, 100, 196, 64, sw=10) + line(186, 64, 214, 60, sw=8) + circle(216, 100, 12, C["yellow"], sw=4),
       "Motorcycle", "Motosikal", ["transport"])
    BI("aeroplane", path("M20,140 C20,120 40,112 60,112 L210,112 C236,112 250,128 250,140 C250,152 236,160 210,160 L60,160 C40,160 20,152 20,140Z", W)
       + poly([(120, 112), (90, 40), (114, 40), (160, 112)], C["blue"]) + poly([(120, 160), (90, 232), (114, 232), (160, 160)], C["blue"]) + poly([(40, 112), (20, 70), (40, 70), (70, 112)], C["red"])
       + "".join(circle(100 + i * 24, 136, 7, C["sky"], sw=3) for i in range(5)) + path("M220,124 C232,124 240,132 240,140 L214,140Z", C["sky"], sw=4), "Aeroplane", "Kapal terbang", ["transport"])
    BI("helicopter", line(30, 50, 226, 50, sw=10) + line(128, 50, 128, 80, sw=8) + path("M40,140 L130,130", stroke=C["red"], sw=14) + rect(14, 116, 20, 40, C["red"], rx=6)
       + path("M100,90 C100,80 120,76 150,76 C210,76 230,110 230,140 C230,170 200,180 150,180 C110,180 100,160 100,140Z", C["red"]) + path("M170,86 C200,90 218,110 220,134 L170,134Z", C["glass"], sw=5)
       + line(110, 196, 220, 196, sw=8) + line(130, 180, 126, 196, sw=6) + line(200, 180, 204, 196, sw=6), "Helicopter", "Helikopter", ["transport"])
    BI("train", shadow(128, 232, 120, 8) + rect(20, 70, 216, 140, C["blue"], rx=24) + rect(36, 86, 80, 56, C["glass"], rx=8, sw=5) + rect(140, 86, 80, 56, C["glass"], rx=8, sw=5)
       + rect(20, 160, 216, 14, W, stroke=None) + circle(60, 190, 10, C["yellow"], sw=4) + circle(196, 190, 10, C["yellow"], sw=4) + line(30, 230, 226, 230, sw=8) + rect(20, 70, 216, 140, "none", rx=24),
       "Train", "Kereta api", ["transport"])
    BI("ship", path("M0,210 C40,200 60,220 100,210 C140,200 160,220 200,210 C230,202 250,216 256,214 L256,256 L0,256Z", C["blue"], stroke=None, extra='fill-opacity="0.5"')
       + path("M14,150 L242,150 L214,212 L42,212Z", C["navy"]) + rect(60, 110, 136, 40, W) + "".join(circle(84 + i * 30, 130, 7, C["sky"], sw=3) for i in range(4))
       + rect(150, 60, 30, 50, C["red"]) + rect(150, 60, 30, 14, INK, stroke=None), "Ship", "Kapal", ["transport", "sea"])
    # ======================= BAHASA INGGERIS: home & clothing =======================
    BI("umbrella", path("M20,130 C20,40 236,40 236,130 C218,116 200,116 182,130 C164,116 146,116 128,130 C110,116 92,116 74,130 C56,116 38,116 20,130Z", C["red"])
       + path("M128,48 C110,70 100,100 100,126 M128,48 C146,70 156,100 156,126", stroke=INK, sw=4) + path("M128,130 L128,214 C128,236 96,236 96,214", stroke=INK, sw=10), "Umbrella", "Payung", ["object"])
    BI("shirt", path("M90,30 L40,50 L10,110 L50,126 L66,96 L66,230 L190,230 L190,96 L206,126 L246,110 L216,50 L166,30 C160,50 96,50 90,30Z", C["sky"])
       + path("M90,30 C100,64 156,64 166,30", stroke=INK, sw=5) + "".join(circle(128, y, 5, W, sw=3) for y in (90, 130, 170)), "Shirt", "Baju", ["clothes"])
    BI("shoes", "".join(path(f"M{x},140 L{x},90 L{x + 50},90 C{x + 60},120 {x + 110},120 {x + 110},150 L{x + 110},170 L{x},170Z", c) + rect(x, 166, 112, 12, W, rx=4)
                        for x, c in ((20, C["navy"]), (128, C["navy"]))), "Shoes", "Kasut", ["clothes"])
    BI("hat", ellipse(128, 180, 120, 34, C["yellow"]) + path("M60,180 C60,90 196,90 196,180Z", C["yellow"]) + path("M62,160 C100,150 156,150 194,160 L196,180 C156,170 100,170 60,180Z", C["red"], sw=5),
       "Hat", "Topi", ["clothes"])
    BI("socks", "".join(path(f"M{x},30 L{x + 60},30 L{x + 60},150 C{x + 60},200 {x + 30},220 {x - 10},220 C{x - 40},220 {x - 40},180 {x - 10},170 L{x},150Z", c) + rect(x, 30, 60, 24, W, sw=5)
                        for x, c in ((50, C["purple"]), (150, C["teal"]))), "Socks", "Stoking", ["clothes"])
    BI("cup", shadow(128, 232, 70, 8) + path("M180,100 C230,100 230,170 180,170", stroke=INK, sw=20) + path("M180,100 C230,100 230,170 180,170", stroke=C["blue"], sw=8)
       + path("M50,70 L190,70 L176,210 C174,222 166,228 154,228 L86,228 C74,228 66,222 64,210Z", C["blue"]) + ellipse(120, 70, 70, 14, C["dwood"]), "Cup", "Cawan", ["object", "kitchen"])
    BI("plate", ellipse(128, 140, 120, 60, W) + ellipse(128, 136, 80, 38, C["lgrey"], sw=4), "Plate", "Pinggan", ["object", "kitchen"])
    BI("spoon", g(ellipse(128, 70, 40, 56, C["lgrey"]) + rect(118, 120, 20, 120, C["lgrey"], rx=8) + shine_ellipse(116, 56, 8, 22, 0, 0.8), transform="rotate(30 128 128)"), "Spoon", "Sudu", ["object", "kitchen"])
    BI("bed", shadow(128, 232, 120, 8) + rect(10, 80, 24, 150, C["dwood"], rx=6) + rect(222, 130, 24, 100, C["dwood"], rx=6) + rect(30, 150, 196, 50, C["wood"])
       + rect(34, 120, 70, 36, W, rx=14) + path("M90,150 L226,150 L226,176 L90,176Z", C["blue"]) + rect(30, 150, 196, 50, "none"), "Bed", "Katil", ["object", "home"])
    BI("door", rect(54, 20, 148, 216, C["wood"], rx=6) + rect(72, 40, 112, 70, C["dwood"], rx=4, sw=5) + rect(72, 126, 112, 90, C["dwood"], rx=4, sw=5) + circle(176, 130, 10, C["gold"], sw=4),
       "Door", "Pintu", ["object", "home"])
    BI("window", rect(30, 30, 196, 196, C["sky"], rx=6) + line(128, 30, 128, 226) + line(30, 128, 226, 128) + rect(30, 30, 196, 196, "none", rx=6, sw=12, stroke=C["wood"])
       + rect(30, 30, 196, 196, "none", rx=6) + shine("M50,50 L90,50 L50,90Z", 0.6), "Window", "Tingkap", ["object", "home"])
    BI("ball", circle(128, 128, 96, C["red"]) + path("M32,128 C80,100 176,100 224,128", stroke=W, sw=10) + path("M128,32 C100,80 100,176 128,224", stroke=W, sw=10) + circle(128, 128, 96, "none")
       + shine_ellipse(90, 80, 12, 22, 40, 0.5), "Ball", "Bola", ["object", "toy"])
    BI("kite", line(128, 220, 60, 250, stroke=INK, sw=3) + poly([(128, 16), (210, 100), (128, 220), (46, 100)], C["yellow"]) + poly([(128, 16), (210, 100), (128, 100)], C["red"], sw=5)
       + poly([(128, 100), (46, 100), (128, 220)], C["red"], sw=5), "Kite", "Layang-layang", ["object", "toy"])
    BI("teddy_bear", body_blob(C["wood"], C["cream"]) + critter_head(C["wood"], ears=circle(70, 56, 26, C["wood"]) + circle(186, 56, 26, C["wood"]) + circle(70, 56, 12, C["cream"], stroke=None) + circle(186, 56, 12, C["cream"], stroke=None),
                                                         extra=ellipse(128, 136, 32, 24, C["cream"], stroke=None), face=eyes(128, 104) + ellipse(128, 128, 10, 7, INK, stroke=None) + smile(128, 138, 10)),
       "Teddy bear", "Anak patung beruang", ["object", "toy"])


if __name__ == "__main__":
    main()
    print(len(L._manifest), "vocab pictures")
