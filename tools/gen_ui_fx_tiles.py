"""UI skins (9-slice friendly), white particle sprites for tinting, and a 64 px tile atlas.
Atlas layout is mirrored in kit/tiles/build_tileset.gd (SOLID / ONE_WAY / HAZARD lists)."""
import math
import svg_lib as L
from svg_lib import C, INK, circle, ellipse, rect, path, poly, line, polyline, g, star_pts, ngon, shadow, shine, shine_ellipse, rgrad, lgrad

W = "#FFFFFF"


def U(name, w, h, body, en, bm, defs="", tags=(), scale=2):
    L.save("ui", name, L.doc(w, h, body, defs=defs, scale=scale), en=en, bm=bm, tags=["ui", *tags])


def F(name, body, en, defs=""):
    L.save("fx", name, L.doc(64, 64, body, defs=defs), en=en, bm="", tags=["fx", "particle"])


def main():
    L.SW = 6
    # ---------------- panels (keep corners inside 32 px so 9-slice margins of 32 work) ----------------
    U("panel_paper", 192, 192, rect(6, 10, 180, 176, "#000000", rx=24, stroke=None, extra='fill-opacity="0.18"') + rect(6, 4, 180, 176, C["paper"], rx=24), "Paper panel", "Panel kertas", tags=["panel", "9slice"])
    U("panel_card", 192, 192, rect(6, 12, 180, 174, L.shade(C["blue"], -0.3), rx=24) + rect(6, 4, 180, 174, W, rx=24) + rect(6, 4, 180, 40, C["blue"], rx=24) + rect(6, 30, 180, 14, C["blue"], stroke=None)
      + line(9, 44, 183, 44, sw=6), "Card panel with header", "Panel kad", tags=["panel", "9slice"])
    U("panel_chalkboard", 192, 192, rect(4, 4, 184, 184, C["dwood"], rx=18) + rect(20, 20, 152, 152, C["chalk"], rx=6, sw=5), "Chalkboard panel", "Panel papan hitam", tags=["panel", "9slice"])
    U("panel_wood", 192, 192, rect(4, 8, 184, 180, C["dwood"], rx=20) + rect(4, 4, 184, 176, C["wood"], rx=20) + "".join(line(14, y, 178, y, stroke=C["dwood"], sw=3, extra='stroke-opacity="0.4"') for y in (60, 120))
      + "".join(circle(x, y, 6, C["grey"], sw=3) for x in (24, 168) for y in (24, 160)), "Wooden sign panel", "Panel papan kayu", tags=["panel", "9slice"])
    U("panel_glass", 192, 192, rect(4, 4, 184, 184, W, rx=28, stroke=W, sw=4, extra='fill-opacity="0.18"'), "Frosted glass panel", "Panel kaca", tags=["panel", "9slice"])
    U("sticky_note_yellow", 192, 192, path("M10,14 L182,10 L178,172 C140,168 120,182 96,186 L14,186Z", "#FFE66D") + rect(70, 0, 52, 22, W, rx=2, stroke=None, extra='fill-opacity="0.6" transform="rotate(-4 96 11)"'), "Sticky note (yellow)", "Nota lekat")
    U("sticky_note_pink", 192, 192, path("M10,14 L182,10 L178,172 C140,168 120,182 96,186 L14,186Z", "#FFB3C7") + rect(70, 0, 52, 22, W, rx=2, stroke=None, extra='fill-opacity="0.6" transform="rotate(3 96 11)"'), "Sticky note (pink)", "Nota lekat")
    U("sticky_note_blue", 192, 192, path("M10,14 L182,10 L178,172 C140,168 120,182 96,186 L14,186Z", "#A8DAFF") + rect(70, 0, 52, 22, W, rx=2, stroke=None, extra='fill-opacity="0.6" transform="rotate(-2 96 11)"'), "Sticky note (blue)", "Nota lekat")
    # ---------------- banners & bubbles ----------------
    U("ribbon_banner", 768, 192, poly([(10, 70), (110, 70), (110, 170), (10, 170), (50, 120)], L.shade(C["red"], -0.25)) + poly([(758, 70), (658, 70), (658, 170), (758, 170), (718, 120)], L.shade(C["red"], -0.25))
      + poly([(110, 150), (150, 170), (150, 150)], L.shade(C["red"], -0.5)) + poly([(658, 150), (618, 170), (618, 150)], L.shade(C["red"], -0.5))
      + path("M90,40 C250,20 518,20 678,40 L678,150 C518,130 250,130 90,150Z", C["red"]) + path("M110,58 C260,40 508,40 658,58", stroke=W, sw=4, extra='stroke-opacity="0.5" stroke-dasharray="10 10"'),
      "Ribbon banner", "Reben sepanduk", tags=["title"])
    U("speech_bubble", 320, 240, path("M30,20 L290,20 C306,20 316,30 316,46 L316,150 C316,166 306,176 290,176 L120,176 L60,226 L76,176 L30,176 C14,176 4,166 4,150 L4,46 C4,30 14,20 30,20Z", W),
      "Speech bubble", "Belon kata", tags=["dialogue"])
    U("thought_bubble", 320, 240, path("M60,150 C10,150 10,90 50,80 C40,30 110,10 140,40 C170,0 250,10 250,60 C300,60 316,120 280,140 C290,180 220,190 200,170 C170,200 90,190 60,150Z", W)
      + circle(60, 196, 16, W) + circle(30, 226, 9, W), "Thought bubble", "Belon fikir", tags=["dialogue"])
    U("arrow_pointer", 128, 128, path("M44,20 C44,10 60,10 60,20 L60,62 C60,52 76,52 76,62 L76,66 C76,56 92,56 92,66 L92,72 C92,62 108,62 108,72 L108,98 C108,114 96,124 80,124 L64,124 C52,124 44,118 38,108 L18,76 C12,66 24,56 34,64 L44,74Z", W)
      + line(60, 62, 60, 86, sw=4) + line(76, 66, 76, 86, sw=4) + line(92, 72, 92, 86, sw=4), "Tutorial pointer hand", "Penunjuk tangan", tags=["tutorial"])
    # ---------------- quiz answer cards (Kahoot-style colour + shape so colour-blind players can match) ----------------
    for n, col, shp in (("a", C["red"], poly([(48, 140), (72, 96), (96, 140)], W, stroke=None)), ("b", C["blue"], poly([(72, 92), (100, 120), (72, 148), (44, 120)], W, stroke=None)),
                        ("c", C["gold"], circle(72, 120, 26, W, stroke=None)), ("d", C["green"], rect(48, 96, 48, 48, W, rx=4, stroke=None))):
        U(f"answer_card_{n}", 512, 224, rect(6, 16, 500, 202, L.shade(col, -0.3), rx=28) + rect(6, 6, 500, 202, col, rx=28) + shp, f"Answer card {n.upper()}", f"Kad jawapan {n.upper()}", tags=["quiz", "9slice"])
    # ---------------- text tiles (blank; letters drawn by kit/components/text_tile.gd) ----------------
    for n, col in (("red", C["red"]), ("orange", C["orange"]), ("yellow", C["yellow"]), ("green", C["green"]), ("blue", C["blue"]), ("purple", C["purple"]), ("white", W), ("wood", "#E8C38E")):
        U(f"tile_{n}", 128, 128, rect(6, 12, 116, 112, L.shade(col, -0.3), rx=20) + rect(6, 4, 116, 112, col, rx=20) + rect(16, 12, 96, 24, W, rx=12, stroke=None, extra='fill-opacity="0.3"'),
          f"Blank tile ({n})", f"Jubin kosong ({n})", tags=["tile", "text"])
    U("tile_slot", 128, 128, rect(6, 6, 116, 116, "#000000", rx=20, stroke=INK, sw=5, extra='fill-opacity="0.12" stroke-dasharray="12 10"'), "Empty tile slot", "Slot jubin", tags=["tile", "dragdrop"])
    # ---------------- stars, badges, level map ----------------
    for k in range(4):
        U(f"stars_{k}", 384, 160, "".join(poly(star_pts(72 + i * 120, 92 - (14 if i == 1 else 0), 56 if i == 1 else 46, 24 if i == 1 else 20), C["yellow"] if i < k else C["lgrey"]) for i in range(3)),
          f"{k} of 3 stars", f"{k} daripada 3 bintang", tags=["rating"])
    for n, col, en in (("bronze", "#CD7F32", "Bronze"), ("silver", "#C0C0C0", "Silver"), ("gold", C["gold"], "Gold")):
        U(f"badge_{n}", 192, 256, poly([(60, 140), (40, 250), (76, 226), (96, 250), (96, 150)], C["red"]) + poly([(132, 140), (152, 250), (116, 226), (96, 250), (96, 150)], C["blue"])
          + circle(96, 100, 84, L.shade(col, -0.25)) + circle(96, 96, 84, col) + circle(96, 96, 64, L.shade(col, 0.3), sw=5) + poly(star_pts(96, 100, 40, 17), W, sw=5),
          f"{en} badge", f"Lencana {n}", tags=["reward"])
    U("level_node_locked", 128, 128, circle(64, 70, 54, L.shade(C["grey"], -0.3)) + circle(64, 62, 54, C["grey"]) + rect(46, 58, 36, 28, C["dgrey"], rx=5, sw=4) + path("M52,58 L52,50 A12,12 0 0 1 76,50 L76,58", stroke=INK, sw=5),
      "Level node (locked)", "Nod tahap (berkunci)", tags=["map"])
    U("level_node_open", 128, 128, circle(64, 70, 54, L.shade(C["blue"], -0.3)) + circle(64, 62, 54, C["blue"]) + circle(64, 62, 40, "none", sw=4, stroke=W, extra='stroke-opacity="0.5"'),
      "Level node (open)", "Nod tahap (dibuka)", tags=["map"])
    U("level_node_done", 128, 128, circle(64, 70, 54, L.shade(C["green"], -0.3)) + circle(64, 62, 54, C["green"]) + polyline([(42, 62), (58, 78), (88, 46)], stroke=W, sw=10), "Level node (complete)", "Nod tahap (selesai)", tags=["map"])
    U("map_path_dot", 32, 32, circle(16, 16, 9, W, sw=4), "Map path dot", "Titik laluan", tags=["map"])
    U("certificate_frame", 1024, 724, rect(8, 8, 1008, 708, C["cream"], rx=8) + rect(36, 36, 952, 652, "none", sw=8, stroke=C["gold"]) + rect(52, 52, 920, 620, "none", sw=3, stroke=C["gold"])
      + "".join(poly(star_pts(x, y, 30, 12, 8), C["gold"], sw=4) for x, y in ((80, 80), (944, 80), (80, 644), (944, 644)))
      + circle(512, 600, 60, C["red"]) + poly(star_pts(512, 600, 40, 18, 12), C["yellow"], sw=4) + poly([(470, 640), (450, 700), (490, 680)], C["red"]) + poly([(554, 640), (574, 700), (534, 680)], C["red"]),
      "Certificate frame (blank)", "Bingkai sijil", tags=["reward"], scale=1)
    U("polaroid", 256, 300, rect(8, 8, 240, 284, W, rx=6) + rect(28, 28, 200, 200, C["lgrey"], sw=4), "Photo frame", "Bingkai foto", tags=["frame"])
    U("clipboard", 256, 320, rect(16, 30, 224, 284, C["wood"], rx=14) + rect(36, 56, 184, 240, W, sw=4) + rect(86, 14, 84, 40, C["grey"], rx=10) + "".join(line(56, y, 200, y, stroke=C["lgrey"], sw=4) for y in range(100, 280, 30)),
      "Clipboard", "Papan klip", tags=["frame"])
    U("timer_ring_bg", 256, 256, circle(128, 128, 110, W, sw=8) + circle(128, 128, 84, "none", sw=4, stroke=C["lgrey"]), "Timer ring background", "Latar pemasa", tags=["timer"])
    # ---------------- FX (white; tint with modulate / particle colour ramps) ----------------
    F("fx_circle_soft", circle(32, 32, 32, "url(#r)", stroke=None), "Soft glow", defs=rgrad("r", [(0, W, 1), (0.5, W, 0.5), (1, W, 0)]))
    F("fx_sparkle", path("M32,2 C34,24 40,30 62,32 C40,34 34,40 32,62 C30,40 24,34 2,32 C24,30 30,24 32,2Z", W, stroke=None), "Sparkle")
    F("fx_star", poly(star_pts(32, 34, 30, 13), W, stroke=None), "Star particle")
    F("fx_heart", path("M32,58 C10,44 2,30 10,18 C18,6 28,10 32,18 C36,10 46,6 54,18 C62,30 54,44 32,58Z", W, stroke=None), "Heart particle")
    F("fx_confetti_rect", rect(20, 8, 24, 48, W, rx=3, stroke=None), "Confetti strip")
    F("fx_confetti_circle", circle(32, 32, 16, W, stroke=None), "Confetti dot")
    F("fx_confetti_triangle", poly([(32, 10), (56, 52), (8, 52)], W, stroke=None), "Confetti triangle")
    F("fx_ring", circle(32, 32, 26, "none", stroke=W, sw=6), "Ring burst")
    F("fx_smoke", "".join(circle(x, y, r, W, stroke=None, extra='fill-opacity="0.85"') for x, y, r in ((24, 36, 18), (40, 30, 20), (32, 20, 14), (44, 42, 14))), "Smoke puff")
    F("fx_drop", path("M32,4 C40,20 50,30 50,42 C50,54 42,60 32,60 C22,60 14,54 14,42 C14,30 24,20 32,4Z", W, stroke=None), "Drop")
    F("fx_note", ellipse(22, 48, 12, 9, W, stroke=None) + rect(30, 8, 6, 42, W, stroke=None) + path("M36,8 C46,14 52,20 48,32", stroke=W, sw=6), "Music note particle")
    F("fx_plus", rect(26, 8, 12, 48, W, rx=6, stroke=None) + rect(8, 26, 48, 12, W, rx=6, stroke=None), "Plus particle")
    # ---------------- 64 px tile atlas (8 x 8) ----------------
    T = 64
    tiles = {}

    def tile(col, row, body):
        tiles[(col, row)] = g(body, transform=f"translate({col * T},{row * T})")

    GR, DIRT, DD = "#6BCB77", "#C68B59", "#A86F43"
    grass_top = lambda l, r: rect(0, 0, T, T, DIRT, stroke=None) + rect(0, 0, T, 18, GR, stroke=None) + path("M0,18 Q8,26 16,18 Q24,26 32,18 Q40,26 48,18 Q56,26 64,18", GR, stroke=None) \
        + "".join(circle(x, y, 3, DD, stroke=None) for x, y in ((14, 40), (44, 50), (30, 56))) + line(0, 2, T, 2, stroke=INK, sw=4) \
        + (line(2, 0, 2, T, stroke=INK, sw=4) if l else "") + (line(T - 2, 0, T - 2, T, stroke=INK, sw=4) if r else "")
    tile(0, 0, grass_top(True, False)); tile(1, 0, grass_top(False, False)); tile(2, 0, grass_top(False, True)); tile(3, 0, grass_top(True, True))
    plat = lambda l, r: rect(0 if not l else 4, 4, T - (4 if l else 0) - (4 if r else 0), 26, C["wood"], rx=8 if (l or r) else 0, sw=4) + line(0, 17, T, 17, stroke=C["dwood"], sw=3)
    tile(4, 0, plat(True, False)); tile(5, 0, plat(False, False)); tile(6, 0, plat(False, True)); tile(7, 0, plat(True, True))
    dirt = lambda l, r, b: rect(0, 0, T, T, DIRT, stroke=None) + "".join(circle(x, y, 3, DD, stroke=None) for x, y in ((14, 14), (44, 24), (24, 44), (52, 52))) \
        + (line(2, 0, 2, T, stroke=INK, sw=4) if l else "") + (line(T - 2, 0, T - 2, T, stroke=INK, sw=4) if r else "") + (line(0, T - 2, T, T - 2, stroke=INK, sw=4) if b else "")
    tile(0, 1, dirt(True, False, False)); tile(1, 1, dirt(False, False, False)); tile(2, 1, dirt(False, True, False)); tile(3, 1, dirt(True, True, False))
    tile(0, 2, dirt(True, False, True)); tile(1, 2, dirt(False, False, True)); tile(2, 2, dirt(False, True, True)); tile(3, 2, dirt(True, True, True))
    brick = lambda col: rect(2, 2, 60, 60, col, sw=4) + line(2, 22, 62, 22, sw=3) + line(2, 42, 62, 42, sw=3) + line(32, 2, 32, 22, sw=3) + line(16, 22, 16, 42, sw=3) + line(48, 22, 48, 42, sw=3) + line(32, 42, 32, 62, sw=3)
    tile(4, 1, brick("#E07A5F")); tile(5, 1, brick("#F2CC8F"))
    tile(6, 1, rect(2, 2, 60, 60, C["grey"], rx=6, sw=4) + path("M14,20 L30,26 M40,44 L52,40", stroke=C["dgrey"], sw=3))
    tile(7, 1, rect(2, 2, 60, 60, C["chalk"], rx=4, sw=4) + path("M14,30 Q24,20 34,30 Q44,40 52,28", stroke=W, sw=3, extra='stroke-opacity="0.6"'))
    tile(4, 2, rect(3, 3, 58, 58, C["wood"], rx=4, sw=4) + line(3, 3, 61, 61, stroke=C["dwood"], sw=5) + line(61, 3, 3, 61, stroke=C["dwood"], sw=5) + rect(3, 3, 58, 58, "none", rx=4, sw=4))
    tile(5, 2, "".join(rect(4 + (k % 2) * 4, 4 + k * 15, 56 - (k % 2) * 6, 14, c, rx=3, sw=3) for k, c in enumerate((C["red"], C["blue"], C["green"], C["yellow"]))))
    tile(6, 2, rect(3, 3, 58, 58, C["yellow"], rx=8, sw=4) + path("M22,22 C22,10 42,10 42,22 C42,30 32,30 32,38", stroke=INK, sw=6) + circle(32, 48, 4, INK, stroke=None) + "".join(circle(x, y, 2.5, C["gold"], stroke=None) for x, y in ((9, 9), (55, 9), (9, 55), (55, 55))))
    tile(7, 2, rect(3, 3, 58, 58, C["dwood"], rx=8, sw=4) + "".join(circle(x, y, 2.5, C["wood"], stroke=None) for x, y in ((9, 9), (55, 9), (9, 55), (55, 55))))
    tile(0, 3, rect(0, 0, T, T, "#F4E1C1", stroke=None) + rect(0, 0, 32, 32, "#E9CFA3", stroke=None) + rect(32, 32, 32, 32, "#E9CFA3", stroke=None))
    tile(1, 3, rect(0, 0, T, T, "#DDE8EA", stroke=None) + rect(1, 1, 62, 62, "none", sw=2, stroke="#B9CCD0"))
    tile(2, 3, rect(0, 0, T, T, "#C9A27A", stroke=None) + line(0, 21, T, 21, stroke="#B88F66", sw=3) + line(0, 42, T, 42, stroke="#B88F66", sw=3) + line(40, 0, 40, 21, stroke="#B88F66", sw=3) + line(16, 21, 16, 42, stroke="#B88F66", sw=3))
    tile(3, 3, rect(0, 0, T, T, "#4FA3E0", stroke=None, extra='fill-opacity="0.8"') + path("M0,10 Q16,0 32,10 Q48,20 64,10 L64,0 L0,0Z", "#8ECAE6", stroke=None) + line(0, 10, T, 10, stroke=W, sw=3, extra='stroke-opacity="0.7"'))
    tile(4, 3, rect(0, 0, T, T, "#3A86C8", stroke=None, extra='fill-opacity="0.8"') + circle(20, 30, 4, W, stroke=None, extra='fill-opacity="0.4"'))
    tile(5, 3, rect(8, 0, 10, T, C["wood"], sw=3) + rect(46, 0, 10, T, C["wood"], sw=3) + rect(8, 12, 48, 8, C["wood"], sw=3) + rect(8, 44, 48, 8, C["wood"], sw=3))
    tile(6, 3, "".join(g(rect(x - 6, 30, 12, 34, C["yellow"], sw=3) + poly([(x - 6, 30), (x + 6, 30), (x, 10)], C["cream"], sw=3) + poly([(x - 2, 17), (x + 2, 17), (x, 10)], INK, sw=1)) for x in (12, 32, 52)))
    tile(7, 3, rect(0, 40, T, 24, "#7A5230", stroke=None) + "".join(circle(x, 40, 9, "#8D6240", stroke=None) for x in (8, 26, 44, 60)))
    tile(0, 4, line(10, 4, 10, 64, sw=6) + path("M14,6 L56,14 L14,26Z", C["red"], sw=4) + circle(10, 6, 5, C["gold"], sw=3))
    tile(1, 4, line(10, 0, 10, 64, sw=6) + rect(2, 52, 16, 12, C["grey"], sw=3))
    tile(2, 4, rect(28, 30, 8, 34, C["dwood"], sw=3) + rect(6, 8, 52, 28, C["wood"], rx=4, sw=4) + line(14, 22, 44, 22, stroke=C["dwood"], sw=3))
    tile(3, 4, rect(10, 0, 44, T, C["dwood"], sw=4) + circle(44, 30, 4, C["gold"], sw=2))
    tile(4, 4, path("M10,64 L10,24 C10,4 54,4 54,24 L54,64", C["dwood"], sw=4) + rect(18, 22, 28, 18, C["sky"], rx=3, sw=3))
    tile(5, 4, circle(32, 32, 20, C["yellow"], sw=4) + circle(32, 32, 12, "none", sw=3, stroke=C["gold"]))
    tile(6, 4, poly(star_pts(32, 34, 26, 11), C["yellow"], sw=4))
    tile(7, 4, circle(20, 32, 12, C["gold"], sw=4) + rect(30, 28, 28, 8, C["gold"], sw=3) + rect(48, 34, 6, 10, C["gold"], sw=2))
    tile(0, 5, path("M4,64 C0,40 20,30 32,40 C44,30 64,40 60,64Z", C["dgreen"], sw=4))
    tile(1, 5, line(32, 64, 32, 34, stroke=C["dgreen"], sw=4) + "".join(circle(32 + 9 * math.cos(math.radians(a)), 28 + 9 * math.sin(math.radians(a)), 7, C["pink"], sw=2) for a in range(0, 360, 72)) + circle(32, 28, 5, C["yellow"], sw=2))
    tile(2, 5, "".join(path(f"M{x},64 Q{x - 4},48 {x - 8},40 Q{x + 2},50 {x + 4},64Z", GR, sw=2) for x in (16, 30, 44)))
    tile(3, 5, path("M6,64 C2,44 20,36 34,40 C50,34 64,48 58,64Z", C["grey"], sw=4))
    tile(4, 5, rect(4, 20, 8, 44, C["wood"], sw=3) + rect(52, 20, 8, 44, C["wood"], sw=3) + rect(0, 28, T, 8, C["wood"], sw=3) + rect(0, 46, T, 8, C["wood"], sw=3))
    tile(5, 5, rect(26, 40, 12, 24, C["cream"], sw=3) + path("M8,44 C8,16 56,16 56,44Z", C["red"], sw=4) + circle(24, 30, 4, W, stroke=None) + circle(40, 26, 3, W, stroke=None))
    tile(6, 5, rect(0, 0, T, T, "#F2D39B", stroke=None) + "".join(circle(x, y, 2, "#D9B66A", stroke=None) for x, y in ((10, 12), (40, 20), (24, 44), (54, 50))))
    tile(7, 5, rect(0, 0, T, T, "#F2D39B", stroke=None) + path("M0,12 Q16,4 32,12 Q48,20 64,12 L64,0 L0,0Z", "#8ECAE6", stroke=None))
    atlas = "".join(tiles.values())
    L.save("tiles", "tiles_platformer", L.doc(T * 8, T * 6, atlas, scale=1), en="Platformer tile atlas (64 px)", bm="Atlas jubin platform", tags=["tiles", "atlas"])


if __name__ == "__main__":
    main()
    print(len(L._manifest), "ui/fx/tiles")
