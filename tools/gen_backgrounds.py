"""1920x1080 scene backgrounds, 3-layer parallax set for side-scrollers, and tileable
paper/board patterns. Kept low-contrast near the centre so UI reads on top."""
import math, random
import svg_lib as L
from svg_lib import C, INK, circle, ellipse, rect, path, poly, line, polyline, g, star_pts, lgrad, rgrad

W = "#FFFFFF"
BW, BH = 1920, 1080


def B(name, body, en, bm, defs="", tags=()):
    L.save("backgrounds", name, L.doc(BW, BH, body, scale=1, defs=defs), en=en, bm=bm, tags=["background", *tags])


def sky(gid, top, bottom):
    return lgrad(gid, [(0, top), (1, bottom)])


def cloud(x, y, s=1.0, col=W, op=1.0):
    d = f"M{x - 90 * s},{y} C{x - 130 * s},{y} {x - 130 * s},{y - 60 * s} {x - 80 * s},{y - 60 * s} C{x - 70 * s},{y - 110 * s} {x + 10 * s},{y - 110 * s} {x + 20 * s},{y - 70 * s} C{x + 60 * s},{y - 100 * s} {x + 130 * s},{y - 70 * s} {x + 100 * s},{y} Z"
    return path(d, col, stroke=None, extra=f'fill-opacity="{op}"')


def tree_round(x, y, s=1.0, col=C["green"], trunk=C["wood"]):
    return (rect(x - 14 * s, y - 120 * s, 28 * s, 120 * s, trunk, sw=5)
            + circle(x, y - 170 * s, 80 * s, col, sw=5) + circle(x - 60 * s, y - 130 * s, 55 * s, col, sw=5) + circle(x + 60 * s, y - 130 * s, 55 * s, col, sw=5)
            + circle(x - 20 * s, y - 196 * s, 30 * s, W, stroke=None, extra='fill-opacity="0.15"'))


def coconut_tree(x, y, s=1.0, lean=40):
    top = (x + lean * s, y - 420 * s)
    b = path(f"M{x - 16 * s},{y} Q{x + lean * 0.2 * s},{y - 220 * s} {top[0] - 8 * s},{top[1]} L{top[0] + 8 * s},{top[1]} Q{x + lean * 0.4 * s},{y - 220 * s} {x + 16 * s},{y}Z", C["wood"], sw=5)
    for a in (-170, -140, -100, -60, -20, 10):
        r = math.radians(a)
        ex, ey = top[0] + 190 * s * math.cos(r), top[1] + 120 * s * math.sin(r) + 70 * s
        mx, my = top[0] + 100 * s * math.cos(r), top[1] - 50 * s + 60 * s * math.sin(r)
        b += path(f"M{top[0]},{top[1]} Q{mx},{my - 30 * s} {ex},{ey} Q{mx},{my + 10 * s} {top[0]},{top[1] + 10 * s}Z", C["dgreen"], sw=5)
    return b + "".join(circle(top[0] + dx * s, top[1] + 18 * s, 16 * s, C["dwood"], sw=4) for dx in (-16, 6, 22))


def desk_back(x, y, s=1.0):
    return rect(x, y, 260 * s, 26 * s, C["wood"], rx=6, sw=6) + rect(x + 10 * s, y + 26 * s, 240 * s, 70 * s, C["dwood"], sw=6) + rect(x + 20 * s, y + 96 * s, 16 * s, 70 * s, C["grey"], sw=5) + rect(x + 224 * s, y + 96 * s, 16 * s, 70 * s, C["grey"], sw=5)


def window(x, y, w, h, sky_id="sky"):
    return (rect(x, y, w, h, f"url(#{sky_id})", sw=8) + cloud(x + w * 0.35, y + h * 0.4, 0.5) + rect(x + w / 2 - 6, y, 12, h, C["paper"], sw=4)
            + rect(x, y + h / 2 - 6, w, 12, C["paper"], sw=4) + rect(x - 12, y - 12, w + 24, h + 24, "none", rx=8, sw=16, stroke=C["paper"]) + rect(x - 16, y - 16, w + 32, h + 32, "none", rx=10, sw=6))


def main():
    L.SW = 6
    rnd = random.Random(7)
    # ---------------- classroom ----------------
    body = rect(0, 0, BW, 760, "#FBE7C6", stroke=None) + rect(0, 560, BW, 200, "#F3D3A0", stroke=None) + line(0, 560, BW, 560, stroke=C["wood"], sw=14)
    body += window(80, 150, 300, 300) + window(1540, 150, 300, 300)
    body += rect(460, 100, 1000, 480, C["dwood"], rx=16, sw=8) + rect(486, 126, 948, 428, C["chalk"], rx=6, sw=6)
    body += path("M560,220 C620,200 700,240 760,210", stroke=W, sw=5, extra='stroke-opacity="0.35"') + path("M1220,460 L1360,460 M1290,420 L1290,500", stroke=W, sw=5, extra='stroke-opacity="0.3"')
    body += rect(520, 556, 880, 22, C["wood"], rx=6, sw=6) + rect(560, 546, 60, 12, W, rx=4, sw=3) + rect(640, 546, 40, 12, C["yellow"], rx=4, sw=3)
    body += circle(960, 60, 40, W, sw=6) + line(960, 60, 960, 34, sw=5) + line(960, 60, 980, 66, sw=5)
    body += "".join(rect(x, 600, 50, 70, c, rx=4, sw=4) for x, c in ((60, C["red"]), (114, C["blue"]), (168, C["green"]), (222, C["yellow"])))
    body += rect(30, 670, 280, 20, C["wood"], sw=5) + rect(1630, 590, 240, 170, C["wood"], sw=6) + circle(1750, 560, 40, C["blue"], sw=5)
    body += rect(0, 760, BW, 320, "#C9A27A", stroke=None) + "".join(line(0, y, BW, y, stroke="#B88F66", sw=4) for y in range(800, 1080, 70))
    body += "".join(line(x, 760, x - 200, 1080, stroke="#B88F66", sw=3) for x in range(0, 2200, 240))
    body += "".join(desk_back(x, 800, 1.2) for x in (120, 560, 1060, 1500))
    B("classroom", body, "Classroom", "Bilik darjah", defs=sky("sky", "#7EC8F2", "#CDEBFA"), tags=["school", "indoor"])
    # ---------------- science lab ----------------
    body = rect(0, 0, BW, BH, "#E3F2F1", stroke=None) + "".join(rect(x, 0, 120, 640, "#D3ECEA", stroke=None) for x in range(0, BW, 240))
    body += rect(0, 640, BW, 440, "#A9C6C9", stroke=None) + "".join(rect(x, 640, 120, 440, "#9DBCC0", stroke=None) for x in range(0, BW, 240))
    for sx in (120, 1240):
        body += rect(sx, 120, 560, 30, C["wood"], sw=6) + rect(sx, 300, 560, 30, C["wood"], sw=6)
        for i, (col, kind) in enumerate(((C["red"], 0), (C["green"], 1), (C["blue"], 0), (C["purple"], 1), (C["yellow"], 0), (C["teal"], 1))):
            x = sx + 40 + i * 88
            if kind:
                body += path(f"M{x + 10},40 L{x + 40},40 L{x + 40},70 L{x + 64},120 L{x - 14},120 L{x + 10},70Z", C["glass"], sw=5) + path(f"M{x - 4},96 L{x + 54},96 L{x + 64},120 L{x - 14},120Z", col, stroke=None)
            else:
                body += rect(x, 50, 50, 70, C["glass"], rx=6, sw=5) + rect(x, 84, 50, 36, col, stroke=None) + rect(x, 50, 50, 70, "none", rx=6, sw=5)
            body += rect(x, 230, 56, 70, [C["dwood"], C["sky"], C["cream"]][i % 3], rx=6, sw=5)
    body += rect(800, 90, 320, 420, W, rx=12, sw=6) + "".join(rect(830, 120 + k * 70, 260, 40, [C["red"], C["yellow"], C["green"], C["blue"], C["purple"]][k], rx=6, sw=4) for k in range(5))
    body += rect(0, 700, BW, 60, C["dgrey"], stroke=None) + rect(0, 700, BW, 16, C["grey"], stroke=None) + rect(0, 760, BW, 320, "#5E6B73", stroke=None)
    body += "".join(rect(x, 790, 220, 230, "#4C5860", rx=8, sw=5) + circle(x + 200, 905, 10, C["lgrey"], sw=3) for x in range(60, BW, 260))
    body += rect(1500, 580, 60, 120, C["lgrey"], rx=8, sw=5) + circle(1530, 560, 30, C["glass"], sw=5) + path("M300,700 L300,600 Q300,560 340,560 L360,560", stroke=C["grey"], sw=12)
    B("science_lab", body, "Science lab", "Makmal sains", tags=["school", "indoor", "sains"])
    # ---------------- library ----------------
    body = rect(0, 0, BW, BH, "#F6E7D2", stroke=None) + rect(0, 820, BW, 260, "#B58A63", stroke=None)
    book_cols = [C["red"], C["blue"], C["green"], C["yellow"], C["purple"], C["orange"], C["teal"], C["pink"], C["navy"]]
    for sx in (40, 700, 1360):
        body += rect(sx, 60, 520, 780, C["dwood"], rx=8, sw=8)
        for shelf in range(5):
            y = 100 + shelf * 150
            body += rect(sx + 20, y, 480, 130, "#5C3A22", stroke=None) + rect(sx + 14, y + 128, 492, 16, C["wood"], sw=5)
            x = sx + 26
            while x < sx + 480:
                w = rnd.randint(22, 40)
                h = rnd.randint(90, 124)
                if x + w > sx + 494:
                    break
                body += rect(x, y + 128 - h, w, h, rnd.choice(book_cols), rx=3, sw=4) + rect(x + 4, y + 128 - h + 14, w - 8, 6, W, stroke=None, extra='fill-opacity="0.5"')
                x += w + 2
    body += rect(560, 900, 800, 40, C["wood"], rx=8, sw=6) + rect(600, 940, 30, 140, C["dwood"], sw=5) + rect(1290, 940, 30, 140, C["dwood"], sw=5)
    body += path("M760,900 L760,860 L860,850 L960,860 L1060,850 L1160,860 L1160,900", C["paper"], sw=5) + line(960, 860, 960, 900, sw=4)
    B("library", body, "Library", "Perpustakaan", tags=["school", "indoor"])
    # ---------------- school field ----------------
    body = rect(0, 0, BW, BH, "url(#sky)", stroke=None) + cloud(300, 180, 1.2) + cloud(1100, 130, 0.9) + cloud(1650, 220, 1.1)
    body += path("M0,560 C300,470 600,520 900,480 C1200,440 1500,500 1920,450 L1920,700 L0,700Z", "#9BD48A", stroke=None)
    body += rect(560, 320, 800, 280, C["cream"], sw=8) + poly([(530, 330), (960, 200), (1390, 330)], C["red"], sw=8) + rect(880, 470, 160, 130, C["dwood"], sw=6)
    body += "".join(rect(600 + i * 110, 380, 70, 60, C["sky"], sw=5) for i in range(7) if i != 3) + "".join(rect(600 + i * 110, 480, 70, 60, C["sky"], sw=5) for i in (0, 1, 5, 6))
    body += line(960, 200, 960, 110, sw=6) + path("M960,110 L1060,126 L960,142Z", C["blue"], sw=5) + circle(960, 270, 36, W, sw=5)
    body += "".join(tree_round(x, 620, s) for x, s in ((120, 1.1), (380, 0.9), (1520, 1.0), (1790, 1.2)))
    body += rect(0, 600, BW, 480, "#7CC46A", stroke=None) + "".join(rect(0, y, BW, 30, "#86CC74", stroke=None) for y in range(640, 1080, 90))
    body += path("M-100,1080 C200,760 1720,760 2020,1080", stroke=W, sw=10) + path("M60,1080 C320,840 1600,840 1860,1080", stroke=W, sw=10)
    body += "".join(rect(x, 620, 10, 40, W, stroke=None) for x in range(40, BW, 120))
    B("school_field", body, "School field", "Padang sekolah", defs=sky("sky", "#4FB3F2", "#CFEFFF"), tags=["school", "outdoor"])
    # ---------------- assembly hall / quiz stage ----------------
    body = rect(0, 0, BW, BH, "#3A2350", stroke=None) + "".join(path(f"M{x},0 L{x + 140},0 L{x + 200},760 L{x - 60},760Z", "#46295F", stroke=None) for x in range(-60, BW, 320))
    body += path("M0,0 L300,0 C260,300 300,600 220,760 L0,760Z", C["dred"], sw=8) + path(f"M{BW},0 L{BW - 300},0 C{BW - 260},300 {BW - 300},600 {BW - 220},760 L{BW},760Z", C["dred"], sw=8)
    body += path(f"M0,0 L{BW},0 L{BW},90 C1500,150 420,150 0,90Z", C["dred"], sw=8) + "".join(circle(x, 110 + 20 * math.sin(x / 160), 10, C["yellow"], sw=4) for x in range(80, BW, 120))
    body += rect(0, 760, BW, 80, "#8B5A2B", sw=8) + rect(0, 840, BW, 240, "#2A1838", stroke=None)
    body += "".join(path(f"M{x},0 L{x - 240},760 L{x + 240},760Z", "#FFF5C2", stroke=None, extra='fill-opacity="0.08"') for x in (480, 960, 1440))
    body += ellipse(960, 760, 420, 40, "#FFF5C2", stroke=None, extra='fill-opacity="0.18"')
    body += "".join(ellipse(x, 1000 + (i % 2) * 30, 70, 60, "#1C1028", stroke=None) for i, x in enumerate(range(40, BW, 130)))
    B("stage_hall", body, "School hall stage", "Pentas dewan sekolah", tags=["school", "indoor", "quiz", "ceremony"])
    # ---------------- outer space ----------------
    body = rect(0, 0, BW, BH, "url(#space)", stroke=None)
    body += "".join(circle(rnd.randint(0, BW), rnd.randint(0, BH), rnd.choice((1.5, 2, 3)), W, stroke=None, extra=f'fill-opacity="{rnd.uniform(0.4, 1):.2f}"') for _ in range(260))
    body += "".join(poly(star_pts(x, y, 14, 4, 4), W, stroke=None) for x, y in ((300, 200), (1500, 160), (1200, 700), (420, 860)))
    body += ellipse(1320, 420, 600, 160, "#9B5DE5", stroke=None, extra='fill-opacity="0.12" transform="rotate(-20 1320 420)"')
    body += circle(1650, 260, 130, "#F1D592", sw=8) + ellipse(1650, 260, 230, 50, "none", stroke="#C9A86A", sw=16, extra='transform="rotate(-15 1650 260)"')
    body += circle(260, 820, 220, C["blue"], sw=8) + path("M140,700 C220,660 300,720 260,780 C220,840 120,820 100,760Z", C["green"], sw=6) + path("M300,880 C380,840 440,900 400,960 C360,1000 300,960 300,880Z", C["green"], sw=6)
    body += circle(560, 300, 50, C["lgrey"], sw=6) + circle(545, 290, 10, C["grey"], stroke=None)
    B("space", body, "Outer space", "Angkasa lepas", defs=sky("space", "#0B1026", "#2B1B54"), tags=["sains", "space"])
    # ---------------- under the sea ----------------
    body = rect(0, 0, BW, BH, "url(#sea)", stroke=None) + "".join(path(f"M{x},0 L{x + 120},0 L{x + 400},900 L{x + 200},900Z", W, stroke=None, extra='fill-opacity="0.06"') for x in range(0, BW, 380))
    body += path("M0,900 C300,850 600,930 960,890 C1300,850 1600,920 1920,880 L1920,1080 L0,1080Z", "#F2D39B", sw=6)
    for x, col in ((160, C["pink"]), (420, C["orange"]), (1500, C["purple"]), (1760, C["red"])):
        body += "".join(path(f"M{x + dx},{900} Q{x + dx - 40},{780} {x + dx + 10},{700 - abs(dx) * 2}", stroke=col, sw=26) for dx in (-40, 0, 40))
    body += "".join(path(f"M{x},{920} C{x - 30},{820} {x + 30},{760} {x},{640}", stroke=C["dgreen"], sw=18) for x in (700, 760, 1200, 1260))
    body += "".join(circle(rnd.randint(0, BW), rnd.randint(0, 800), rnd.randint(6, 18), W, sw=3, extra='fill-opacity="0.25"') for _ in range(40))
    body += "".join(g(path("M0,0 C40,-40 120,-40 150,0 C120,40 40,40 0,0Z", c, sw=5) + path("M0,0 L-40,-30 L-40,30Z", c, sw=5) + circle(110, -6, 7, INK, stroke=None), transform=f"translate({x},{y}) scale({s})")
                    for x, y, s, c in ((400, 300, 0.9, C["yellow"]), (1300, 420, 1.2, C["orange"]), (900, 200, 0.7, C["sky"])))
    B("underwater", body, "Under the sea", "Dasar laut", defs=sky("sea", "#2EC4B6", "#0B4F8A"), tags=["sains", "sea"])
    # ---------------- rainforest ----------------
    body = rect(0, 0, BW, BH, "url(#forest)", stroke=None)
    body += "".join(tree_round(x, 860, s, col=c) for x, s, c in ((80, 1.6, "#2D6A4F"), (420, 1.8, "#1B4332"), (760, 1.5, "#2D6A4F"), (1100, 1.9, "#1B4332"), (1440, 1.6, "#2D6A4F"), (1800, 1.8, "#1B4332")))
    body += "".join(path(f"M{x},0 C{x + 20},200 {x - 20},400 {x + 10},560", stroke="#40916C", sw=8) for x in (300, 640, 990, 1330, 1680))
    body += rect(0, 860, BW, 220, "#2D6A4F", stroke=None) + path("M0,920 C400,880 800,960 1200,910 C1500,880 1700,930 1920,900 L1920,1080 L0,1080Z", "#52B788", stroke=None)
    body += "".join(path(f"M{x},1000 C{x - 60},900 {x - 120},880 {x - 160},900 M{x},1000 C{x + 60},900 {x + 120},880 {x + 160},900 M{x},1000 C{x},880 {x + 10},840 {x},820", stroke="#1B4332", sw=14) for x in (200, 900, 1600))
    body += "".join(circle(x, y, 10, C["red"], sw=4) for x, y in ((520, 960), (1360, 990), (1700, 950)))
    B("rainforest", body, "Rainforest", "Hutan hujan tropika", defs=sky("forest", "#95D5B2", "#2D6A4F"), tags=["sains", "outdoor", "local"])
    # ---------------- kampung ----------------
    body = rect(0, 0, BW, BH, "url(#sky)", stroke=None) + circle(1620, 200, 90, C["yellow"], sw=6) + cloud(400, 200, 1) + cloud(1100, 160, 0.8)
    body += path("M0,640 C400,580 800,620 1200,590 C1500,570 1700,600 1920,580 L1920,1080 L0,1080Z", "#8BC34A", stroke=None)
    for x, s in ((600, 1.4), (1260, 1.1)):
        body += g("".join(rect(xx, 420, 16, 160, C["dwood"], sw=5) for xx in (40, 120, 240, 330))
                  + rect(20, 300, 360, 130, C["wood"], sw=6) + poly([(-10, 310), (200, 160), (410, 310)], "#8D5A3B", sw=6) + poly([(150, 310), (200, 230), (250, 310)], C["cream"], sw=5)
                  + rect(60, 330, 60, 60, C["sky"], sw=5) + rect(280, 330, 60, 60, C["sky"], sw=5) + rect(170, 330, 60, 100, C["dwood"], sw=5), transform=f"translate({x - 200 * s},{640 - 580 * s}) scale({s})")
    body += coconut_tree(200, 760, 1.0, 60) + coconut_tree(1600, 720, 0.9, -50) + coconut_tree(1820, 760, 1.1, 40)
    body += rect(0, 880, BW, 200, "#7CB342", stroke=None) + path("M0,960 C500,930 1400,990 1920,950", stroke="#D7B98E", sw=60) + path("M0,960 C500,930 1400,990 1920,950", stroke="#E6CBA0", sw=40)
    B("kampung", body, "Malay village", "Kampung", defs=sky("sky", "#5BC0F8", "#E0F4FF"), tags=["local", "outdoor"])
    # ---------------- night sky (for astronomy / calm screens) ----------------
    body = rect(0, 0, BW, BH, "url(#night)", stroke=None) + "".join(circle(rnd.randint(0, BW), rnd.randint(0, 700), rnd.choice((1.5, 2.5)), W, stroke=None) for _ in range(160))
    body += path("M1500,120 A110,110 0 1 0 1640,300 A90,90 0 1 1 1500,120Z", "#FFF3B0", sw=6)
    body += path("M0,820 C300,740 500,800 800,760 C1100,720 1400,800 1920,740 L1920,1080 L0,1080Z", "#1B2A41", stroke=None)
    body += "".join(rect(x, 760 - h, 90, h, "#22334D", stroke=None) + "".join(rect(x + 15 + (k % 2) * 40, 760 - h + 20 + (k // 2) * 50, 20, 26, "#FFD166", stroke=None, extra='fill-opacity="0.8"') for k in range(int(h / 50) * 2 - 2))
                    for x, h in ((200, 200), (320, 300), (1200, 260), (1340, 180), (1460, 340)))
    B("night_sky", body, "Night sky", "Langit malam", defs=sky("night", "#0B1026", "#3A3F7A"), tags=["sains", "space", "outdoor"])
    # ---------------- parallax: platformer hills (sky / far / near) ----------------
    L.save("backgrounds", "parallax_sky", L.doc(BW, BH, rect(0, 0, BW, BH, "url(#s)", stroke=None) + cloud(300, 220, 1.1, op=0.9) + cloud(1000, 160, 0.8, op=0.9) + cloud(1600, 260, 1.2, op=0.9),
                                                    scale=1, defs=sky("s", "#62B6F7", "#D8F1FF")), en="Parallax: sky", bm="Paralaks: langit", tags=["background", "parallax"])
    far = "".join(path(f"M{x - 420},880 C{x - 250},{560 - h} {x + 250},{560 - h} {x + 420},880Z", "#8FCB9B", stroke=None) for x, h in ((200, 40), (800, 120), (1400, 60), (1950, 100)))
    L.save("backgrounds", "parallax_far", L.doc(BW, BH, far + rect(0, 860, BW, 220, "#8FCB9B", stroke=None), scale=1), en="Parallax: far hills", bm="Paralaks: bukit jauh", tags=["background", "parallax"])
    near = "".join(tree_round(x, 900, s, col=c) for x, s, c in ((140, 1.0, "#4CAF50"), (520, 1.3, "#43A047"), (980, 0.9, "#4CAF50"), (1380, 1.2, "#43A047"), (1800, 1.0, "#4CAF50")))
    L.save("backgrounds", "parallax_near", L.doc(BW, BH, near + rect(0, 900, BW, 180, "#6BBF59", stroke=None), scale=1), en="Parallax: near trees", bm="Paralaks: pokok dekat", tags=["background", "parallax"])
    # ---------------- tileable patterns (512x512) ----------------
    pat = lambda n, body, en, bm: L.save("backgrounds", n, L.doc(512, 512, body, scale=1), en=en, bm=bm, tags=["pattern", "tileable"])
    pat("pattern_notebook", rect(0, 0, 512, 512, C["paper"], stroke=None) + "".join(line(0, y, 512, y, stroke="#A8D0F0", sw=2) for y in range(32, 512, 32)) + line(64, 0, 64, 512, stroke="#F28B9B", sw=3),
        "Notebook paper", "Kertas buku latihan")
    pat("pattern_graph", rect(0, 0, 512, 512, W, stroke=None) + "".join(line(0, v, 512, v, stroke="#CDE3F5", sw=1.5) + line(v, 0, v, 512, stroke="#CDE3F5", sw=1.5) for v in range(0, 512, 16))
        + "".join(line(0, v, 512, v, stroke="#8FC1E8", sw=2.5) + line(v, 0, v, 512, stroke="#8FC1E8", sw=2.5) for v in range(0, 512, 128)), "Graph paper", "Kertas graf")
    pat("pattern_chalkboard", rect(0, 0, 512, 512, C["chalk"], stroke=None) + "".join(path(f"M{rnd.randint(0, 512)},{rnd.randint(0, 512)} q{rnd.randint(-60, 60)},{rnd.randint(-20, 20)} {rnd.randint(40, 120)},{rnd.randint(-10, 10)}", stroke=W, sw=3, extra='stroke-opacity="0.05"') for _ in range(40)),
        "Chalkboard", "Papan hitam")
    pat("pattern_dots", rect(0, 0, 512, 512, "#FFF8E7", stroke=None) + "".join(circle(x + (16 if (y // 32) % 2 else 0), y, 4, "#FFD9A0", stroke=None) for y in range(16, 512, 32) for x in range(16, 512, 32)),
        "Polka dots", "Corak bintik")
    pat("pattern_batik", rect(0, 0, 512, 512, "#1D3557", stroke=None) + "".join(g(path("M0,-40 C30,-20 30,20 0,40 C-30,20 -30,-20 0,-40Z", C["gold"], sw=3) + circle(0, 0, 10, C["red"], sw=3), transform=f"translate({x},{y})")
                                                                         for x in range(0, 513, 128) for y in range(0, 513, 128))
        + "".join(g(poly(star_pts(0, 0, 24, 9, 4), C["teal"], sw=3), transform=f"translate({x},{y})") for x in range(64, 513, 128) for y in range(64, 513, 128)), "Batik pattern", "Corak batik")


if __name__ == "__main__":
    main()
    print(len(L._manifest), "backgrounds")
