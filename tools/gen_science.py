"""Science props: lab glassware, space, weather, plants and life cycles. 256 view box -> 512 px."""
import math
import svg_lib as L
from svg_lib import C, INK, circle, ellipse, rect, path, poly, line, polyline, g, star_pts, shadow, shine, shine_ellipse, arc_d, rgrad

W = "#FFFFFF"


def S(name, body, en, bm, tags=(), defs=""):
    L.save("subjects/sains", name, L.doc(256, 256, body, defs=defs), en=en, bm=bm, tags=["science", *tags])


def liquid_shine(x, y, h):
    return rect(x, y, 10, h, W, rx=5, stroke=None, extra='fill-opacity="0.55"')


def bubbles(pts):
    return "".join(circle(x, y, r, W, stroke=None, extra='fill-opacity="0.75"') for x, y, r in pts)


def planet(name, en, bm, col, r, bands=(), ring=None, spots=()):
    body = shadow(128, 236, r * 0.8, 10)
    if ring:
        body += ellipse(128, 128, r * 1.75, r * 0.45, "none", stroke=INK, sw=16) + ellipse(128, 128, r * 1.75, r * 0.45, "none", stroke=ring, sw=9)
    body += circle(128, 128, r, col)
    inner = ""
    for y, h, c in bands:
        inner += rect(0, 128 + y, 256, h, c, stroke=None)
    for x, y, sr, c in spots:
        inner += circle(128 + x, 128 + y, sr, c, stroke=None)
    inner += circle(128 + r * 0.35, 128 + r * 0.35, r * 1.05, "#000000", stroke=None, extra='fill-opacity="0.13"')
    body += g(inner, extra='clip-path="url(#clip)"')
    body += circle(128, 128, r, "none")
    if ring:  # front half of the ring passes over the planet
        body += path(f"M{128 - r * 1.75},128 A{r * 1.75},{r * 0.45} 0 0 0 {128 + r * 1.75},128", stroke=INK, sw=16)
        body += path(f"M{128 - r * 1.75},128 A{r * 1.75},{r * 0.45} 0 0 0 {128 + r * 1.75},128", stroke=ring, sw=9)
    body += shine_ellipse(128 - r * 0.45, 128 - r * 0.45, r * 0.18, r * 0.3, 40, 0.5)
    S(name, body, en, bm, ["space", "planet"], defs=f'<clipPath id="clip"><circle cx="128" cy="128" r="{r}"/></clipPath>')


def main():
    L.SW = 7
    # ---------------- glassware ----------------
    S("beaker", shadow(128, 232, 70, 10)
      + path("M58,40 L198,40 L190,60 L190,214 C190,222 184,228 176,228 L80,228 C72,228 66,222 66,214 L66,60Z", C["glass"])
      + path("M66,120 L190,120 L190,214 C190,222 184,228 176,228 L80,228 C72,228 66,222 66,214Z", C["blue"], stroke=None)
      + bubbles([(100, 180, 8), (140, 150, 6), (160, 196, 10)])
      + "".join(line(150, 80 + i * 26, 176, 80 + i * 26, sw=5) for i in range(5))
      + path("M58,40 L198,40 L190,60 L190,214 C190,222 184,228 176,228 L80,228 C72,228 66,222 66,214 L66,60Z") + liquid_shine(80, 70, 140),
      "Beaker", "Bikar", ["lab"])
    S("flask_conical", shadow(128, 234, 86, 10)
      + path("M104,30 L152,30 L152,96 L214,206 C220,218 212,228 200,228 L56,228 C44,228 36,218 42,206 L104,96Z", C["glass"])
      + path("M80,150 L176,150 L214,206 C220,218 212,228 200,228 L56,228 C44,228 36,218 42,206Z", C["green"], stroke=None)
      + bubbles([(110, 196, 9), (150, 180, 6), (130, 214, 5)])
      + path("M104,30 L152,30 L152,96 L214,206 C220,218 212,228 200,228 L56,228 C44,228 36,218 42,206 L104,96Z")
      + rect(96, 18, 64, 18, C["grey"], rx=6) + path("M112,100 L120,100 L80,200 L68,200Z", W, stroke=None, extra='fill-opacity="0.5"'),
      "Conical flask", "Kelalang kon", ["lab"])
    S("flask_round", shadow(128, 236, 70, 10)
      + path("M108,24 L148,24 L148,98 A76,76 0 1 1 108,98Z", C["glass"])
      + path("M54,170 L202,170 A76,76 0 0 1 54,170Z", C["purple"], stroke=None)
      + path("M108,24 L148,24 L148,98 A76,76 0 1 1 108,98Z") + rect(100, 14, 56, 16, C["grey"], rx=6)
      + bubbles([(110, 196, 9), (150, 186, 7)]) + shine_ellipse(84, 138, 10, 26, 30, 0.5),
      "Round flask", "Kelalang dasar bulat", ["lab"])
    for i, (col, nm) in enumerate(((C["red"], "red"), (C["blue"], "blue"), (C["green"], "green"))):
        S(f"test_tube_{nm}", shadow(128, 236, 30, 6)
          + path("M108,26 L148,26 L148,206 A20,20 0 0 1 108,206Z", C["glass"])
          + path("M108,130 L148,130 L148,206 A20,20 0 0 1 108,206Z", col, stroke=None)
          + path("M108,26 L148,26 L148,206 A20,20 0 0 1 108,206Z") + rect(100, 18, 56, 14, C["grey"], rx=5) + liquid_shine(116, 40, 160),
          f"Test tube ({nm})", "Tabung uji", ["lab"])
    S("test_tube_rack", shadow(128, 228, 110, 10)
      + "".join(path(f"M{x - 15},40 L{x + 15},40 L{x + 15},176 A15,15 0 0 1 {x - 15},176Z", C["glass"])
                + path(f"M{x - 15},{110 + j * 12} L{x + 15},{110 + j * 12} L{x + 15},176 A15,15 0 0 1 {x - 15},176Z", col, stroke=None)
                + path(f"M{x - 15},40 L{x + 15},40 L{x + 15},176 A15,15 0 0 1 {x - 15},176Z")
                for j, (x, col) in enumerate(((68, C["red"]), (128, C["yellow"]), (188, C["teal"]))))
      + rect(28, 100, 200, 22, C["wood"], rx=6) + rect(28, 196, 200, 22, C["wood"], rx=6) + rect(36, 100, 14, 118, C["dwood"]) + rect(206, 100, 14, 118, C["dwood"]),
      "Test tube rack", "Rak tabung uji", ["lab"])
    S("microscope", shadow(128, 234, 90, 10)
      + rect(50, 210, 160, 22, C["navy"], rx=8) + path("M150,210 C190,170 190,110 150,80", stroke=INK, sw=34) + path("M150,210 C190,170 190,110 150,80", stroke=C["navy"], sw=24)
      + rect(70, 150, 110, 14, C["dgrey"], rx=4) + rect(96, 142, 58, 8, C["glass"], rx=2, sw=4)
      + g(rect(96, 30, 36, 100, C["lgrey"], rx=8) + rect(102, 14, 24, 22, C["dgrey"], rx=4) + rect(104, 128, 20, 16, C["dgrey"], rx=3), transform="rotate(-18 114 80)")
      + circle(176, 120, 14, C["grey"]) + circle(176, 120, 5, INK, stroke=None),
      "Microscope", "Mikroskop", ["lab"])
    S("magnifier", shadow(128, 234, 80, 8)
      + line(160, 160, 220, 220, stroke=INK, sw=34) + line(160, 160, 220, 220, stroke=C["dwood"], sw=22)
      + circle(110, 110, 70, C["glass"], sw=22, stroke=C["gold"]) + circle(110, 110, 70, "none", sw=5) + circle(110, 110, 59, "none", sw=4) + circle(110, 110, 81, "none", sw=5)
      + shine_ellipse(84, 84, 14, 26, 40, 0.8), "Magnifying glass", "Kanta pembesar", ["lab"])
    S("magnet", shadow(128, 234, 80, 8)
      + path("M48,60 L48,130 A80,80 0 0 0 208,130 L208,60 L162,60 L162,130 A34,34 0 0 1 94,130 L94,60Z", C["red"])
      + rect(48, 36, 46, 34, C["lgrey"], rx=4) + rect(162, 36, 46, 34, C["lgrey"], rx=4)
      + shine("M60,80 L68,80 L68,132 C68,150 74,166 84,178 L78,184 C66,170 60,152 60,132Z", 0.5), "Magnet", "Magnet", ["physics"])
    S("light_bulb", shadow(128, 240, 44, 8)
      + "".join(line(128 + 92 * math.cos(math.radians(a)), 96 + 92 * math.sin(math.radians(a)), 128 + 112 * math.cos(math.radians(a)), 96 + 112 * math.sin(math.radians(a)), stroke=C["gold"], sw=8)
                for a in (-160, -125, -90, -55, -20))
      + path("M92,150 C60,124 62,30 128,28 C194,30 196,124 164,150 L160,176 L96,176Z", C["yellow"])
      + path("M110,176 L110,130 L122,118 L134,130 L146,118 L146,176", stroke=C["gold"], sw=5)
      + rect(94, 176, 68, 16, C["grey"], rx=5) + rect(98, 192, 60, 16, C["grey"], rx=5) + path("M108,208 L148,208 L138,222 L118,222Z", C["dgrey"])
      + shine_ellipse(100, 70, 12, 26, 30, 0.7), "Light bulb", "Mentol", ["physics", "electric"])
    S("battery", shadow(128, 226, 90, 8)
      + rect(30, 80, 180, 100, C["dgrey"], rx=14) + rect(210, 108, 18, 44, C["grey"], rx=4)
      + rect(30, 80, 70, 100, C["gold"], rx=14) + rect(80, 80, 20, 100, C["gold"], stroke=None) + line(100, 80, 100, 180)
      + path("M52,130 L78,130 M65,117 L65,143", stroke=INK, sw=8) + line(160, 130, 186, 130, sw=8) + rect(30, 80, 180, 100, "none", rx=14),
      "Battery", "Bateri", ["physics", "electric"])
    S("thermometer", shadow(128, 240, 40, 8)
      + path("M106,190 L106,40 A22,22 0 0 1 150,40 L150,190 A36,36 0 1 1 106,190Z", W)
      + path("M118,196 L118,110 L138,110 L138,196Z", C["red"], stroke=None) + circle(128, 214, 24, C["red"], sw=5)
      + "".join(line(150, 50 + i * 20, 166 if i % 2 == 0 else 160, 50 + i * 20, sw=4) for i in range(8)),
      "Thermometer", "Termometer", ["physics", "weather"])
    S("dna", "".join(line(128 + 52 * math.sin(t / 10), 24 + t * 3.0, 128 - 52 * math.sin(t / 10), 24 + t * 3.0, stroke=[C["yellow"], C["teal"], C["pink"], C["green"]][(t // 6) % 4], sw=8)
                     for t in range(3, 70, 6))
      + polyline([(128 + 52 * math.sin(t / 10), 24 + t * 3.0) for t in range(0, 71)], stroke=C["blue"], sw=14)
      + polyline([(128 - 52 * math.sin(t / 10), 24 + t * 3.0) for t in range(0, 71)], stroke=C["red"], sw=14),
      "DNA", "DNA", ["biology"])
    S("molecule", line(128, 128, 60, 70, sw=12) + line(128, 128, 200, 76, sw=12) + line(128, 128, 120, 210, sw=12)
      + circle(60, 70, 32, W) + circle(200, 76, 32, W) + circle(120, 210, 32, W) + circle(128, 128, 50, C["red"])
      + shine_ellipse(110, 106, 10, 16, 40, 0.6) + shine_ellipse(50, 58, 6, 10, 40, 0.8), "Molecule (H2O)", "Molekul air", ["chemistry"])
    S("atom", "".join(ellipse(128, 128, 110, 40, "none", stroke=INK, sw=14, extra=f'transform="rotate({a} 128 128)"')
                      + ellipse(128, 128, 110, 40, "none", stroke=C["sky"], sw=6, extra=f'transform="rotate({a} 128 128)"') for a in (0, 60, 120))
      + circle(118, 122, 16, C["red"]) + circle(138, 122, 16, C["blue"]) + circle(128, 140, 16, C["red"])
      + circle(238, 128, 11, C["yellow"], sw=5) + circle(73, 33, 11, C["yellow"], sw=5) + circle(73, 223, 11, C["yellow"], sw=5),
      "Atom", "Atom", ["chemistry"])
    S("tooth", shadow(128, 236, 50, 8)
      + path("M64,60 C64,20 108,26 128,40 C148,26 192,20 192,60 C192,96 178,120 172,160 C166,210 156,226 146,226 C132,226 136,170 128,170 C120,170 124,226 110,226 C100,226 90,210 84,160 C78,120 64,96 64,60Z", W)
      + shine_ellipse(94, 66, 10, 20, 20, 1) + path("M100,96 C110,108 120,108 128,100", stroke=C["lgrey"], sw=5), "Tooth", "Gigi", ["health"])
    # ---------------- space ----------------
    sun_rays = "".join(poly([(128 + 116 * math.cos(math.radians(a)), 128 + 116 * math.sin(math.radians(a))),
                             (128 + 80 * math.cos(math.radians(a - 10)), 128 + 80 * math.sin(math.radians(a - 10))),
                             (128 + 80 * math.cos(math.radians(a + 10)), 128 + 80 * math.sin(math.radians(a + 10)))], C["orange"], sw=5) for a in range(0, 360, 30))
    S("sun", sun_rays + circle(128, 128, 76, C["yellow"]) + shine_ellipse(100, 98, 14, 22, 40, 0.6), "Sun", "Matahari", ["space", "weather"])
    S("moon", path("M150,24 A104,104 0 1 0 232,168 A82,82 0 1 1 150,24Z", C["lgrey"])
      + circle(96, 150, 14, C["grey"], sw=4) + circle(130, 200, 9, C["grey"], sw=4) + circle(70, 104, 8, C["grey"], sw=4), "Moon", "Bulan", ["space"])
    planet("planet_mercury", "Mercury", "Utarid", "#B7A99A", 54, spots=[(-14, -10, 8, "#9C8D7E"), (18, 16, 6, "#9C8D7E")])
    planet("planet_venus", "Venus", "Zuhrah", "#F2C879", 70, bands=[(-30, 12, "#E3AE5A"), (10, 10, "#E3AE5A")])
    planet("planet_earth", "Earth", "Bumi", C["blue"], 90, spots=[(-30, -30, 28, C["green"]), (34, 20, 24, C["green"]), (10, -50, 12, C["green"]), (-20, 44, 14, C["green"])])
    planet("planet_mars", "Mars", "Marikh", "#E2725B", 64, spots=[(-16, -12, 12, "#C1543F"), (20, 20, 9, "#C1543F")])
    planet("planet_jupiter", "Jupiter", "Musytari", "#E8C39E", 104, bands=[(-60, 14, "#C98E5B"), (-24, 18, "#B5734A"), (16, 14, "#C98E5B"), (50, 12, "#D9A877")], spots=[(36, 30, 14, "#C1543F")])
    planet("planet_saturn", "Saturn", "Zuhal", "#F1D592", 66, bands=[(-26, 10, "#D9B66A"), (12, 10, "#D9B66A")], ring="#C9A86A")
    planet("planet_uranus", "Uranus", "Uranus", "#9BE0E6", 72, bands=[(-6, 10, "#7CCCD3")])
    planet("planet_neptune", "Neptune", "Neptun", "#4C7BE8", 70, bands=[(-20, 10, "#3A62C4"), (20, 8, "#3A62C4")], spots=[(-20, 8, 10, "#2D4FA6")])
    S("rocket", shadow(128, 240, 40, 8)
      + path("M96,190 L72,226 L100,214Z", C["red"]) + path("M160,190 L184,226 L156,214Z", C["red"])
      + path("M108,200 C108,230 128,246 128,246 C128,246 148,230 148,200Z", C["orange"])
      + path("M128,14 C176,50 176,150 160,206 L96,206 C80,150 80,50 128,14Z", W)
      + path("M128,14 C146,28 156,46 162,64 L94,64 C100,46 110,28 128,14Z", C["red"])
      + circle(128, 112, 22, C["sky"], sw=8) + shine_ellipse(120, 104, 5, 9, 30, 0.8)
      + path("M108,150 L84,170 L84,206 L104,206Z", C["red"]) + path("M148,150 L172,170 L172,206 L152,206Z", C["red"]), "Rocket", "Roket", ["space"])
    S("telescope", shadow(128, 236, 80, 8)
      + line(128, 150, 70, 228, sw=10) + line(128, 150, 186, 228, sw=10) + line(128, 150, 128, 228, sw=10)
      + g(rect(50, 96, 150, 44, C["blue"], rx=10) + rect(186, 88, 30, 60, C["navy"], rx=8) + rect(30, 106, 24, 24, C["navy"], rx=4)
          + rect(110, 92, 14, 52, C["yellow"], sw=5), transform="rotate(-24 128 118)") + circle(128, 150, 12, C["grey"]),
      "Telescope", "Teleskop", ["space"])
    S("star_space", poly(star_pts(128, 132, 110, 46), C["yellow"]) + shine("M128,30 L144,90 L112,90Z", 0.5)
      + circle(100, 130, 9, INK, stroke=None) + circle(156, 130, 9, INK, stroke=None) + path("M110,158 Q128,174 146,158", stroke=INK, sw=6),
      "Star", "Bintang", ["space"])
    S("comet", path("M180,80 C120,100 40,180 20,236 C80,200 150,150 196,120Z", C["sky"], stroke=None, extra='fill-opacity="0.7"')
      + path("M180,80 C140,110 80,170 60,210 C100,180 160,140 196,120Z", W, stroke=None, extra='fill-opacity="0.8"')
      + circle(194, 98, 34, C["sky"]) + shine_ellipse(184, 86, 8, 12, 40, 0.8), "Comet", "Komet", ["space"])
    S("ufo", shadow(128, 236, 60, 8) + path("M100,180 L60,236 L196,236 L156,180Z", C["yellow"], stroke=None, extra='fill-opacity="0.35"')
      + path("M80,110 A48,48 0 0 1 176,110Z", C["glass"]) + ellipse(128, 130, 110, 34, C["lgrey"]) + ellipse(128, 120, 70, 14, C["grey"], sw=5)
      + "".join(circle(x, 140, 9, C["yellow"], sw=4) for x in (56, 92, 128, 164, 200)), "UFO", "UFO", ["space", "fun"])
    # ---------------- weather ----------------
    cloud_d = "M60,170 C24,170 22,118 58,112 C58,70 112,58 128,88 C142,52 206,62 198,112 C236,112 236,170 196,170Z"
    S("cloud", shadow(128, 236, 80, 8) + path(cloud_d, W), "Cloud", "Awan", ["weather"])
    S("cloud_rain", path(cloud_d, C["lgrey"], extra='transform="translate(0,-30)"')
      + "".join(path(f"M{x},{y} C{x - 10},{y + 16} {x - 10},{y + 26} {x},{y + 26} C{x + 10},{y + 26} {x + 10},{y + 16} {x},{y}Z", C["blue"], sw=4)
                for x, y in ((80, 160), (120, 190), (160, 160), (200, 190))), "Rain", "Hujan", ["weather"])
    S("cloud_storm", path(cloud_d, C["dgrey"], extra='transform="translate(0,-40)"')
      + poly([(138, 126), (100, 186), (128, 186), (110, 246), (166, 166), (136, 166), (156, 126)], C["yellow"]), "Storm", "Ribut petir", ["weather"])
    S("rainbow", "".join(path(arc_d(128, 200, r, 180, 360), stroke=INK, sw=20) + path(arc_d(128, 200, r, 180, 360), stroke=c, sw=13)
                         for r, c in zip(range(110, 40, -14), (C["red"], C["orange"], C["yellow"], C["green"], C["blue"], C["purple"])))
      + path("M4,206 C-2,180 30,166 46,180 C60,160 92,176 82,206Z", W) + path("M252,206 C258,180 226,166 210,180 C196,160 164,176 174,206Z", W),
      "Rainbow", "Pelangi", ["weather"])
    S("snowflake", "".join(g(line(128, 128, 128, 22, stroke=C["sky"], sw=14) + line(128, 60, 104, 40, stroke=C["sky"], sw=10) + line(128, 60, 152, 40, stroke=C["sky"], sw=10),
                             transform=f"rotate({a} 128 128)") for a in range(0, 360, 60)) + circle(128, 128, 18, W, stroke=C["sky"], sw=8),
      "Snowflake", "Kepingan salji", ["weather"])
    S("water_drop", shadow(128, 236, 50, 8) + path("M128,20 C160,80 196,120 196,162 C196,202 166,230 128,230 C90,230 60,202 60,162 C60,120 96,80 128,20Z", C["blue"])
      + shine_ellipse(98, 160, 12, 24, 20, 0.6), "Water drop", "Titisan air", ["weather", "water"])
    S("fire", shadow(128, 236, 60, 8) + path("M128,16 C150,60 210,90 196,160 C188,206 160,230 128,230 C96,230 68,206 60,160 C52,116 90,96 92,56 C110,76 112,96 112,96 C122,70 128,40 128,16Z", C["orange"])
      + path("M128,100 C142,130 172,150 162,190 C156,214 142,226 128,226 C114,226 100,214 94,190 C88,166 112,150 128,100Z", C["yellow"], sw=5), "Fire", "Api", ["chemistry"])
    S("wind", "".join(path(d, stroke=INK, sw=16) + path(d, stroke=C["sky"], sw=8) for d in (
        "M20,90 L150,90 C190,90 190,40 160,40 C140,40 136,60 146,66", "M20,130 L200,130 C240,130 240,184 206,184 C186,184 180,164 192,156", "M40,170 L120,170 C150,170 150,210 128,210")),
      "Wind", "Angin", ["weather"])
    # ---------------- plants & life cycles ----------------
    pot = rect(80, 176, 96, 16, C["dwood"], rx=4) + path("M88,190 L168,190 L160,236 L96,236Z", C["wood"])
    soil = ellipse(128, 182, 44, 8, C["dwood"], stroke=None)
    S("plant_seed", shadow(128, 236, 40, 6) + ellipse(128, 200, 70, 26, C["dwood"]) + ellipse(128, 186, 30, 20, C["wood"]) + path("M110,184 Q128,170 146,184", stroke=C["dwood"], sw=5),
      "Seed", "Biji benih", ["plant", "lifecycle"])
    S("plant_sprout", pot + path("M128,178 C128,150 128,140 128,130", stroke=C["dgreen"], sw=10)
      + path("M128,136 C104,140 86,120 92,100 C114,100 128,116 128,136Z", C["green"]) + path("M128,136 C150,140 168,118 162,98 C140,98 128,116 128,136Z", C["green"]),
      "Sprout", "Anak benih", ["plant", "lifecycle"])
    S("plant_young", pot + path("M128,178 L128,70", stroke=C["dgreen"], sw=10)
      + "".join(path(f"M128,{y} C{128 + s * 30},{y + 6} {128 + s * 60},{y - 14} {128 + s * 56},{y - 36} C{128 + s * 30},{y - 36} {128 + s * 8},{y - 20} 128,{y}Z", C["green"])
                for y, s in ((150, -1), (130, 1), (106, -1), (86, 1))) + ellipse(128, 64, 14, 22, C["lime"]), "Young plant", "Pokok muda", ["plant", "lifecycle"])
    S("plant_flower", pot + path("M128,178 L128,92", stroke=C["dgreen"], sw=10)
      + path("M128,160 C100,166 78,146 82,124 C106,124 128,140 128,160Z", C["green"]) + path("M128,140 C156,146 176,124 172,104 C148,104 128,120 128,140Z", C["green"])
      + "".join(ellipse(128 + 30 * math.cos(math.radians(a)), 70 + 30 * math.sin(math.radians(a)), 22, 16, C["pink"], extra=f'transform="rotate({a} {128 + 30 * math.cos(math.radians(a)):.1f} {70 + 30 * math.sin(math.radians(a)):.1f})"')
                for a in range(0, 360, 60)) + circle(128, 70, 20, C["yellow"]), "Flowering plant", "Pokok berbunga", ["plant", "lifecycle"])
    S("plant_fruit", pot + path("M128,178 L128,80", stroke=C["dwood"], sw=12)
      + path("M128,40 C70,30 40,90 70,120 C60,150 110,160 128,140 C146,160 196,150 186,120 C216,90 186,30 128,40Z", C["green"])
      + "".join(circle(x, y, 13, C["red"], sw=5) for x, y in ((92, 96), (150, 76), (164, 118), (118, 124))), "Fruiting plant", "Pokok berbuah", ["plant", "lifecycle"])
    S("leaf", path("M40,216 C40,110 110,36 220,36 C220,150 150,216 40,216Z", C["green"]) + path("M40,216 C90,160 150,100 200,56", stroke=C["dgreen"], sw=7)
      + "".join(line(x, y, x + dx, y + dy, stroke=C["dgreen"], sw=5) for x, y, dx, dy in ((90, 162, 0, -50), (90, 162, 46, 6), (130, 120, 2, -46), (130, 120, 44, 4), (166, 84, 4, -30), (166, 84, 30, 4))),
      "Leaf", "Daun", ["plant"])
    S("tree", shadow(128, 238, 70, 10) + path("M112,236 L118,140 L138,140 L144,236Z", C["wood"])
      + path("M128,20 C70,20 40,70 60,104 C24,124 50,180 96,166 C110,186 146,186 160,166 C206,180 232,124 196,104 C216,70 186,20 128,20Z", C["green"])
      + shine_ellipse(96, 66, 16, 26, 30, 0.25), "Tree", "Pokok", ["plant"])
    S("cactus", pot + path("M110,180 L110,60 A18,18 0 0 1 146,60 L146,180Z", C["green"]) + path("M110,130 L88,130 A14,14 0 0 1 74,116 L74,90 A12,12 0 0 1 98,90 L98,108 L110,108", C["green"])
      + path("M146,116 L166,116 A14,14 0 0 0 180,102 L180,80 A12,12 0 0 0 156,80 L156,96 L146,96", C["green"]) + circle(128, 40, 10, C["pink"], sw=4), "Cactus", "Kaktus", ["plant"])
    S("mushroom", shadow(128, 236, 50, 8) + path("M104,140 C104,190 96,230 128,230 C160,230 152,190 152,140Z", C["cream"])
      + path("M30,150 C30,60 226,60 226,150 C226,160 30,160 30,150Z", C["red"]) + circle(90, 108, 14, W, sw=4) + circle(150, 92, 12, W, sw=4) + circle(184, 128, 10, W, sw=4),
      "Mushroom", "Cendawan", ["plant", "fungi"])
    # frog life cycle
    S("frog_eggs", "".join(circle(x, y, 26, C["glass"], sw=5) + circle(x, y, 9, INK, stroke=None) for x, y in ((80, 100), (130, 80), (176, 110), (110, 146), (160, 160), (70, 170), (200, 170))),
      "Frog eggs (frogspawn)", "Telur katak", ["animal", "lifecycle", "frog"])
    S("tadpole", path("M120,128 C160,100 200,150 240,120 C210,170 170,140 130,150Z", C["dgreen"]) + ellipse(100, 128, 50, 40, C["dgreen"])
      + circle(84, 116, 9, W, sw=4) + circle(86, 116, 4, INK, stroke=None), "Tadpole", "Berudu", ["animal", "lifecycle", "frog"])
    S("froglet", path("M150,140 C190,140 200,170 240,160", stroke=INK, sw=22) + path("M150,140 C190,140 200,170 240,160", stroke=C["green"], sw=12)
      + ellipse(120, 150, 64, 44, C["green"]) + circle(90, 108, 18, C["green"]) + circle(140, 108, 18, C["green"]) + circle(90, 106, 8, INK, stroke=None) + circle(140, 106, 8, INK, stroke=None)
      + path("M90,186 L70,214 L96,214", stroke=INK, sw=6) + path("M150,186 L170,214 L144,214", stroke=INK, sw=6), "Froglet", "Anak katak", ["animal", "lifecycle", "frog"])
    # ---------------- earth science ----------------
    S("volcano", poly([(10, 236), (96, 70), (160, 70), (246, 236)], C["brown"]) + path("M96,70 L160,70 L150,100 C136,90 120,110 106,96Z", C["red"])
      + path("M110,70 C90,40 120,20 128,40 C140,10 176,30 150,70Z", C["lgrey"]) + path("M118,96 C116,120 128,130 120,160", stroke=C["orange"], sw=10),
      "Volcano", "Gunung berapi", ["earth"])
    S("mountain", poly([(4, 230), (90, 60), (176, 230)], C["dgrey"]) + poly([(90, 230), (170, 100), (252, 230)], C["grey"])
      + poly([(90, 60), (110, 100), (98, 92), (84, 104), (72, 96)], W, sw=5) + poly([(170, 100), (186, 126), (170, 120), (156, 126)], W, sw=5), "Mountain", "Gunung", ["earth"])
    S("rock", shadow(128, 228, 90, 10) + path("M30,210 C20,160 60,110 110,104 C140,80 200,90 220,140 C240,180 220,214 190,216Z", C["grey"])
      + path("M80,150 L110,140 M150,120 L170,150", stroke=C["dgrey"], sw=6), "Rock", "Batu", ["earth"])
    S("compass_rose", circle(128, 128, 100, C["cream"]) + circle(128, 128, 82, "none", sw=4)
      + poly([(128, 26), (146, 128), (110, 128)], C["red"]) + poly([(128, 230), (146, 128), (110, 128)], C["lgrey"])
      + poly([(26, 128), (128, 112), (128, 144)], C["lgrey"]) + poly([(230, 128), (128, 112), (128, 144)], C["lgrey"]) + circle(128, 128, 10, C["gold"]),
      "Compass", "Kompas", ["earth", "geography"])


if __name__ == "__main__":
    main()
    print(len(L._manifest), "science props")
