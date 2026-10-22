"""Characters: Malaysian pupils in school uniform, two teachers and two mascots, each in
7 expressions/poses. 256x384 view box -> 512x768 px, feet at the bottom centre so they
stand on the same baseline. kit/components/character.gd swaps these by expression name."""
import svg_lib as L
from svg_lib import C, INK, circle, ellipse, rect, path, poly, line, polyline, g, shadow, shine_ellipse

W = "#FFFFFF"
PINK = "#FF9EBB"
NAVY = "#1F3A6E"
HX, HY, HR = 128, 132, 80  # head centre / radius
EXPRESSIONS = ("neutral", "happy", "sad", "surprised", "thinking", "talk", "cheer")


def arm(pts, sleeve, skin, long=False, sw=24):
    """Thick limb: ink outline, sleeve colour, bare skin for short sleeves, hand at the end."""
    out = polyline(pts, stroke=INK, sw=sw + 8) + polyline(pts, stroke=skin, sw=sw)
    if long:
        out += polyline(pts[:-1] + [pts[-1]], stroke=sleeve, sw=sw)
    else:
        (x0, y0), (x1, y1) = pts[0], pts[1]
        out += polyline([(x0, y0), (x0 + (x1 - x0) * 0.45, y0 + (y1 - y0) * 0.45)], stroke=sleeve, sw=sw + 2)
    hx, hy = pts[-1]
    return out + circle(hx, hy, 14, skin, sw=5)


def arms_for(pose, sleeve, skin, long):
    L_sh, R_sh = (88, 224), (168, 224)
    if pose == "cheer":
        a = [[L_sh, (62, 180), (50, 140)], [R_sh, (194, 180), (206, 140)]]
    elif pose == "thinking":
        a = [[L_sh, (74, 280), (66, 300)], [R_sh, (190, 270), (156, 214)]]
    elif pose == "wave":
        a = [[L_sh, (74, 280), (66, 300)], [R_sh, (200, 196), (214, 150)]]
    else:
        a = [[L_sh, (72, 270), (64, 300)], [R_sh, (184, 270), (192, 300)]]
    return "".join(arm(p, sleeve, skin, long) for p in a)


def face(expr, brow=INK):
    ex, ey = 30, HY + 10
    out = "".join(ellipse(HX + s * 48, ey + 24, 12, 7, PINK, stroke=None, extra='fill-opacity="0.75"') for s in (-1, 1))
    if expr in ("happy", "cheer"):
        out += "".join(path(f"M{HX + s * ex - 12},{ey + 4} Q{HX + s * ex},{ey - 12} {HX + s * ex + 12},{ey + 4}", stroke=INK, sw=6) for s in (-1, 1))
        out += path(f"M{HX - 22},{ey + 30} Q{HX},{ey + 30} {HX + 22},{ey + 30} Q{HX + 20},{ey + 58} {HX},{ey + 58} Q{HX - 20},{ey + 58} {HX - 22},{ey + 30}Z", "#8B1E3F", sw=5)
        out += ellipse(HX, ey + 50, 10, 6, "#FF6B81", stroke=None)
    else:
        big = expr == "surprised"
        ry, rx = (16, 13) if big else (12, 9)
        look = (6, -5) if expr == "thinking" else (0, 0)
        for s in (-1, 1):
            out += ellipse(HX + s * ex, ey, rx, ry, INK, stroke=None)
            out += circle(HX + s * ex + 3 + look[0], ey - 5 + look[1], 4.5, W, stroke=None)
        if expr == "sad":
            out += "".join(line(HX + s * ex - s * 14, ey - 24, HX + s * ex + s * 10, ey - 30, stroke=brow, sw=6) for s in (-1, 1))
            out += path(f"M{HX - 14},{ey + 40} Q{HX},{ey + 28} {HX + 14},{ey + 40}", stroke=INK, sw=6)
            out += path(f"M{HX + ex + 6},{ey + 14} C{HX + ex},{ey + 26} {HX + ex + 4},{ey + 32} {HX + ex + 10},{ey + 30} C{HX + ex + 14},{ey + 26} {HX + ex + 10},{ey + 20} {HX + ex + 6},{ey + 14}Z", C["sky"], sw=3)
        elif expr == "surprised":
            out += "".join(path(f"M{HX + s * ex - 12},{ey - 30} Q{HX + s * ex},{ey - 40} {HX + s * ex + 12},{ey - 30}", stroke=brow, sw=6) for s in (-1, 1))
            out += ellipse(HX, ey + 40, 10, 13, "#8B1E3F", sw=5)
        elif expr == "thinking":
            out += line(HX - ex - 10, ey - 26, HX - ex + 10, ey - 24, stroke=brow, sw=6) + path(f"M{HX + ex - 12},{ey - 26} Q{HX + ex},{ey - 34} {HX + ex + 12},{ey - 28}", stroke=brow, sw=6)
            out += line(HX - 12, ey + 38, HX + 10, ey + 34, sw=6)
        elif expr == "talk":
            out += path(f"M{HX - 16},{ey + 30} Q{HX},{ey + 28} {HX + 16},{ey + 30} Q{HX + 14},{ey + 50} {HX},{ey + 50} Q{HX - 14},{ey + 50} {HX - 16},{ey + 30}Z", "#8B1E3F", sw=5)
        else:
            out += path(f"M{HX - 14},{ey + 32} Q{HX},{ey + 44} {HX + 14},{ey + 32}", stroke=INK, sw=6)
    return out


HAIR = {
    "short": lambda c: path(f"M{HX - HR - 4},{HY + 12} C{HX - HR - 8},{HY - HR - 34} {HX + HR + 8},{HY - HR - 34} {HX + HR + 4},{HY + 12} L{HX + HR - 6},{HY - 4} C{HX + 40},{HY - 36} {HX - 20},{HY - 60} {HX - HR + 8},{HY - 4}Z", c),
    "spiky": lambda c: poly([(HX - HR - 4, HY + 10), (HX - HR + 2, HY - 40), (HX - 60, HY - 96), (HX - 30, HY - 80), (HX - 12, HY - 112), (HX + 10, HY - 84), (HX + 40, HY - 106),
                             (HX + 52, HY - 72), (HX + 86, HY - 70), (HX + HR + 4, HY + 10), (HX + HR - 8, HY - 10), (HX + 40, HY - 42), (HX + 10, HY - 30), (HX - 20, HY - 46), (HX - HR + 8, HY - 8)], c),
    "curly": lambda c: "".join(circle(HX + dx, HY + dy, 26, c) for dx, dy in ((-74, -6), (-62, -46), (-34, -74), (0, -84), (34, -74), (62, -46), (74, -6)))
                       + circle(HX, HY - 54, 50, c, stroke=None),
    "side_part": lambda c: path(f"M{HX - HR - 4},{HY + 30} C{HX - HR - 14},{HY - HR - 30} {HX + HR + 14},{HY - HR - 30} {HX + HR + 4},{HY + 30} L{HX + HR - 8},{HY} C{HX + 50},{HY - 30} {HX + 10},{HY - 40} {HX - 6},{HY - 60} C{HX - 30},{HY - 30} {HX - 60},{HY - 20} {HX - HR + 8},{HY + 4}Z", c),
}
BACK_HAIR = {
    "buns": lambda c: circle(HX - 70, HY - 70, 30, c) + circle(HX + 70, HY - 70, 30, c),
    "ponytail": lambda c: path(f"M{HX + 50},{HY - 70} C{HX + 140},{HY - 60} {HX + 120},{HY + 90} {HX + 90},{HY + 130} C{HX + 110},{HY + 60} {HX + 100},{HY - 10} {HX + 40},{HY - 40}Z", c),
    "braid": lambda c: "".join(ellipse(HX + 70 + k * 2, HY + 40 + k * 32, 18, 22, c) for k in range(5)) + circle(HX + 80, HY + 196, 9, C["red"], sw=4),
    "long": lambda c: path(f"M{HX - HR - 10},{HY} C{HX - HR - 20},{HY + 90} {HX - 70},{HY + 130} {HX - 60},{HY + 140} L{HX + 60},{HY + 140} C{HX + 70},{HY + 130} {HX + HR + 20},{HY + 90} {HX + HR + 10},{HY}Z", c),
}


def outfit(kind, top, bottom, skin):
    """Returns (behind_arms, front) layers below the head."""
    legs = lambda col, y0=300, y1=356: rect(96, y0, 28, y1 - y0, col) + rect(132, y0, 28, y1 - y0, col)
    shoes = ellipse(106, 364, 22, 12, C["black"]) + ellipse(150, 364, 22, 12, C["black"])
    if kind == "shirt_pants":
        return legs(bottom, 290, 358) + shoes + path("M84,214 C84,206 96,200 110,200 L146,200 C160,200 172,206 172,214 L176,300 L80,300Z", top) \
            + poly([(110, 200), (128, 226), (146, 200)], top, sw=5) + rect(80, 290, 96, 16, bottom) + rect(140, 236, 20, 18, top, sw=4)
    if kind == "shirt_shorts":
        return legs(skin, 316, 352) + rect(98, 344, 24, 12, W, sw=4) + rect(134, 344, 24, 12, W, sw=4) + shoes \
            + path("M84,214 C84,206 96,200 110,200 L146,200 C160,200 172,206 172,214 L176,300 L80,300Z", top) + poly([(110, 200), (128, 226), (146, 200)], top, sw=5) \
            + path("M80,290 L176,290 L180,326 L132,326 L128,312 L124,326 L76,326Z", bottom)
    if kind == "kurung":
        return path("M82,300 L174,300 L186,362 L70,362Z", bottom) + shoes \
            + path("M84,214 C84,206 96,200 110,200 L146,200 C160,200 172,206 172,214 L188,318 L68,318Z", top) + path("M112,200 L128,214 L144,200", stroke=INK, sw=5)
    if kind == "pinafore":
        return legs(skin, 320, 352) + rect(98, 340, 24, 14, W, sw=4) + rect(134, 340, 24, 14, W, sw=4) + shoes \
            + path("M86,214 C86,206 98,200 112,200 L144,200 C158,200 170,206 170,214 L172,260 L84,260Z", W) \
            + path("M94,206 L162,206 L166,250 L186,330 L70,330 L90,250Z", bottom) + rect(84, 248, 88, 12, L.shade(bottom, -0.2), rx=4)
    if kind == "sport":
        return legs(bottom, 290, 358) + shoes + path("M84,214 C84,206 96,200 110,200 L146,200 C160,200 172,206 172,214 L176,300 L80,300Z", top) \
            + path("M112,200 Q128,216 144,200", stroke=INK, sw=5) + rect(80, 250, 96, 10, W, stroke=None) + rect(80, 290, 96, 16, bottom)
    if kind == "teacher_m":
        return legs(bottom, 290, 358) + shoes + path("M80,214 C80,206 94,198 110,198 L146,198 C162,198 176,206 176,214 L180,304 L76,304Z", top) \
            + poly([(110, 198), (128, 222), (146, 198)], W, sw=5) + poly([(122, 212), (134, 212), (138, 280), (128, 292), (118, 280)], C["red"], sw=5) + rect(76, 294, 104, 14, bottom)
    raise ValueError(kind)


def tudung(col, skin):
    back = path(f"M{HX - 96},{HY + 10} C{HX - 100},{HY - 110} {HX + 100},{HY - 110} {HX + 96},{HY + 10} C{HX + 100},{HY + 70} {HX + 70},{HY + 104} {HX + 62},{HY + 118} L{HX - 62},{HY + 118} C{HX - 70},{HY + 104} {HX - 100},{HY + 80} {HX - 96},{HY + 10}Z", col)
    face_hole = ellipse(HX, HY + 14, 64, 70, skin)
    trim = path(f"M{HX - 64},{HY + 4} C{HX - 64},{HY - 70} {HX + 64},{HY - 70} {HX + 64},{HY + 4}", stroke=L.shade(col, -0.15), sw=10)
    return back, face_hole + trim


def human(name, en, bm, skin, kind, top, bottom, hair=None, hair_col=C["black"], back=None, scarf=None, glasses=False, mustache=False, sleeves_long=False):
    for expr in EXPRESSIONS:
        b = shadow(128, 372, 64, 9)
        if scarf:
            t_back, t_front = tudung(scarf, skin)
            b += outfit(kind, top, bottom, skin) + t_back + arms_for(expr, top, skin, sleeves_long) + t_front
        else:
            if back:
                b += BACK_HAIR[back](hair_col)
            b += outfit(kind, top, bottom, skin) + arms_for(expr, top, skin, sleeves_long)
            b += rect(116, 190, 24, 20, skin, sw=5)
            b += circle(HX - HR + 2, HY + 14, 15, skin) + circle(HX + HR - 2, HY + 14, 15, skin)
            b += ellipse(HX, HY, HR, HR - 2, skin)
        b += face(expr, brow=hair_col if not scarf else INK)
        if not scarf and hair:
            b += HAIR[hair](hair_col)
        if glasses:
            b += "".join(circle(HX + s * 30, HY + 10, 20, "none", sw=5) for s in (-1, 1)) + line(HX - 10, HY + 8, HX + 10, HY + 8, sw=5)
        if mustache:
            b += path(f"M{HX - 22},{HY + 38} Q{HX - 10},{HY + 28} {HX},{HY + 36} Q{HX + 10},{HY + 28} {HX + 22},{HY + 38} Q{HX},{HY + 44} {HX - 22},{HY + 38}Z", hair_col, sw=3)
        if expr == "thinking":  # little thought dots
            b += circle(206, 70, 7, W, sw=4) + circle(222, 46, 10, W, sw=4) + circle(236, 18, 13, W, sw=4)
        if expr == "cheer":
            b += "".join(path(f"M{x},{y} l4,-10 l4,10 l10,4 l-10,4 l-4,10 l-4,-10 l-10,-4Z", C["yellow"], sw=3) for x, y in ((24, 100), (222, 96), (40, 40)))
        L.save("characters", f"{name}_{expr}", L.doc(256, 384, b), en=f"{en} ({expr})", bm=f"{bm} ({expr})", tags=["character", name, expr])


def hornbill(expr):
    b = shadow(128, 372, 70, 9) + "".join(path(f"M{x},330 L{x - 12},366 M{x},330 L{x},368 M{x},330 L{x + 12},366", stroke=C["orange"], sw=8) for x in (100, 156))
    b += ellipse(128, 250, 84, 96, C["black"]) + ellipse(128, 276, 52, 62, W, stroke=None)
    if expr == "cheer":
        wings = [path("M56,220 C20,180 10,120 30,96 C50,140 70,170 80,200Z", C["black"]), path("M200,220 C236,180 246,120 226,96 C206,140 186,170 176,200Z", C["black"])]
    elif expr == "thinking":
        wings = [path("M50,220 C30,260 40,300 60,310 C66,280 70,250 70,220Z", C["black"]), path("M196,220 C220,230 210,180 168,176 C176,196 180,206 176,220Z", C["black"])]
    else:
        wings = [path("M50,220 C30,260 40,300 60,310 C66,280 70,250 70,220Z", C["black"]), path("M206,220 C226,260 216,300 196,310 C190,280 186,250 186,220Z", C["black"])]
    b += "".join(wings)
    b += circle(128, 132, 76, C["black"]) + path("M128,60 C150,40 170,50 176,60 C160,70 150,70 128,60Z", C["black"])
    open_beak = expr in ("happy", "cheer", "talk", "surprised")
    b += path("M112,118 C150,96 220,98 246,138 C214,136 170,136 120,146Z", C["yellow"])
    b += path("M118,146 C170,140 214,142 240,150 C214,170 160,176 116,162Z" if not open_beak else "M118,150 C170,160 214,176 236,196 C200,196 150,186 114,170Z", L.shade(C["yellow"], -0.1))
    b += path("M110,112 C130,72 200,70 226,110 C196,104 160,104 120,120Z", C["red"])
    # eyes (white ring)
    if expr in ("happy", "cheer"):
        b += circle(98, 120, 18, W) + path("M86,124 Q98,108 110,124", stroke=INK, sw=6)
    else:
        r = 22 if expr == "surprised" else 18
        b += circle(98, 122, r, W) + circle(98 + (6 if expr == "thinking" else 0), 122 - (6 if expr == "thinking" else 0), 9, INK, stroke=None) + circle(101, 118, 3, W, stroke=None)
        if expr == "sad":
            b += line(80, 96, 112, 104, sw=6) + path("M84,142 C80,154 84,160 90,158 C94,154 92,148 84,142Z", C["sky"], sw=3)
    b += ellipse(92, 152, 10, 6, PINK, stroke=None, extra='fill-opacity="0.8"')
    if expr == "thinking":
        b += circle(206, 40, 7, W, sw=4) + circle(224, 18, 10, W, sw=4)
    L.save("characters", f"kenyalang_{expr}", L.doc(256, 384, b), en=f"Kenny the Hornbill ({expr})", bm=f"Kenyalang ({expr})", tags=["character", "mascot", "kenyalang", expr])


def robot(expr):
    teal = "#5EEAD4"
    b = shadow(128, 372, 64, 9) + rect(92, 300, 28, 60, C["grey"], rx=8) + rect(136, 300, 28, 60, C["grey"], rx=8) + ellipse(106, 362, 22, 10, C["dgrey"]) + ellipse(150, 362, 22, 10, C["dgrey"])
    b += rect(70, 206, 116, 104, C["lgrey"], rx=24) + circle(128, 256, 22, C["sky"]) + circle(128, 256, 10, C["blue"], sw=4)
    arms = {"cheer": ([(76, 226), (48, 180), (44, 140)], [(180, 226), (208, 180), (212, 140)]),
            "thinking": ([(76, 226), (60, 270), (56, 300)], [(180, 226), (200, 260), (160, 200)])}.get(expr, ([(76, 226), (56, 270), (52, 300)], [(180, 226), (200, 270), (204, 300)]))
    for pts in arms:
        b += polyline(pts, stroke=INK, sw=26) + polyline(pts, stroke=C["grey"], sw=18) + circle(*pts[-1], 14, C["yellow"], sw=5)
    b += line(128, 46, 128, 24, sw=6) + circle(128, 20, 11, C["red"] if expr != "sad" else C["grey"], sw=5)
    b += rect(40, 46, 176, 150, W, rx=36) + rect(58, 66, 140, 106, C["navy"], rx=20, sw=5)
    b += rect(30, 100, 14, 40, C["grey"], rx=5) + rect(212, 100, 14, 40, C["grey"], rx=5)
    E = lambda d: path(d, stroke=teal, sw=8)
    if expr in ("happy", "cheer"):
        b += E("M80,116 Q92,100 104,116") + E("M152,116 Q164,100 176,116") + path("M100,136 Q128,162 156,136Z", teal, stroke=None)
    elif expr == "sad":
        b += E("M80,108 L104,114") + E("M176,108 L152,114") + circle(92, 122, 6, teal, stroke=None) + circle(164, 122, 6, teal, stroke=None) + E("M106,152 Q128,138 150,152")
    elif expr == "surprised":
        b += circle(92, 116, 14, "none", stroke=teal, sw=7) + circle(164, 116, 14, "none", stroke=teal, sw=7) + circle(128, 150, 9, "none", stroke=teal, sw=6)
    elif expr == "thinking":
        b += rect(84, 110, 20, 8, teal, rx=4, stroke=None) + circle(170, 108, 8, teal, stroke=None) + E("M108,150 L148,146") + circle(222, 32, 8, W, sw=4)
    elif expr == "talk":
        b += circle(92, 116, 9, teal, stroke=None) + circle(164, 116, 9, teal, stroke=None) + rect(108, 138, 40, 18, teal, rx=9, stroke=None)
    else:
        b += circle(92, 116, 9, teal, stroke=None) + circle(164, 116, 9, teal, stroke=None) + E("M110,146 Q128,156 146,146")
    b += shine_ellipse(76, 78, 8, 14, 30, 0.35)
    L.save("characters", f"robo_{expr}", L.doc(256, 384, b), en=f"Robo the tutor robot ({expr})", bm=f"Robo ({expr})", tags=["character", "mascot", "robo", expr])


def main():
    L.SW = 7
    S = L.SKINS
    human("aiman", "Aiman (pupil)", "Aiman (murid)", S[1], "shirt_pants", W, NAVY, hair="short")
    human("aisyah", "Aisyah (pupil)", "Aisyah (murid)", S[1], "kurung", W, NAVY, scarf=W, sleeves_long=True)
    human("meiling", "Mei Ling (pupil)", "Mei Ling (murid)", S[0], "pinafore", W, NAVY, hair="side_part", back="buns")
    human("weijie", "Wei Jie (pupil)", "Wei Jie (murid)", S[0], "shirt_shorts", W, NAVY, hair="spiky", glasses=True)
    human("kavitha", "Kavitha (pupil)", "Kavitha (murid)", S[3], "pinafore", W, "#2A4D8F", hair="side_part", back="braid")
    human("arjun", "Arjun (pupil)", "Arjun (murid)", S[3], "shirt_shorts", W, NAVY, hair="curly")
    human("jaiden", "Jaiden (pupil, sports attire)", "Jaiden (murid, pakaian sukan)", S[2], "sport", C["red"], NAVY, hair="short", hair_col="#3B2A20")
    human("nurul", "Cikgu Nurul (teacher)", "Cikgu Nurul (guru)", S[1], "kurung", C["teal"], "#7A3E9D", scarf=C["purple"], sleeves_long=True)
    human("rahman", "Cikgu Rahman (teacher)", "Cikgu Rahman (guru)", S[2], "teacher_m", C["sky"], C["black"], hair="side_part", glasses=True, mustache=True, sleeves_long=True)
    for e in EXPRESSIONS:
        hornbill(e)
        robot(e)


if __name__ == "__main__":
    main()
    print(len(L._manifest), "character frames")
