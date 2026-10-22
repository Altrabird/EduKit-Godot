"""UI icons: 128x128 view box, exported at 256 px. Text-free so they work in any language."""
import math
import svg_lib as L
from svg_lib import C, INK, circle, ellipse, rect, path, poly, line, polyline, g, star_pts, ngon, shine, shine_ellipse, arc_d

L.SW = 6
W = "#FFFFFF"


def badge(fill, *inner):
    """Round coloured disc with a lighter top half — the house button-icon shape."""
    return (circle(64, 66, 54, L.shade(fill, -0.25), stroke=None)
            + circle(64, 62, 54, fill)
            + path("M18,56 A46,46 0 0 1 110,56 Q64,44 18,56Z", W, stroke=None, extra='fill-opacity="0.25"')
            + "".join(inner))


def arrow_right(c):
    return poly([(40, 54), (66, 54), (66, 38), (92, 62), (66, 86), (66, 70), (40, 70)], W, stroke=None)


def gear_pts(cx, cy, ro, ri, teeth):
    pts = []
    for i in range(teeth * 4):
        a = math.radians(i * 360 / (teeth * 4) - 90 + 360 / (teeth * 8))
        r = ro if (i % 4) in (1, 2) else ri
        pts.append((cx + r * math.cos(a), cy + r * math.sin(a)))
    return pts


HEART = "M64,110 C22,82 8,56 26,34 C42,16 58,24 64,38 C70,24 86,16 102,34 C120,56 106,82 64,110Z"

ICONS = {
    "home": (lambda: rect(80, 26, 14, 26, C["red"]) + rect(28, 58, 72, 52, C["cream"], rx=4)
             + poly([(14, 66), (64, 20), (114, 66)], C["red"]) + rect(54, 78, 20, 32, C["blue"], rx=4)
             + rect(34, 70, 14, 14, C["sky"], rx=2) + rect(80, 70, 14, 14, C["sky"], rx=2), "Home", "Rumah"),
    "play": (lambda: badge(C["green"], poly([(52, 38), (52, 86), (92, 62)], W, sw=4, stroke=W)), "Play", "Main"),
    "pause": (lambda: badge(C["orange"], rect(44, 40, 14, 44, W, rx=4, stroke=None), rect(70, 40, 14, 44, W, rx=4, stroke=None)), "Pause", "Jeda"),
    "stop": (lambda: badge(C["red"], rect(44, 42, 40, 40, W, rx=6, stroke=None)), "Stop", "Henti"),
    "restart": (lambda: badge(C["blue"], path(arc_d(64, 62, 24, -40, 250), stroke=W, sw=10),
                              poly([(78, 30), (96, 44), (74, 52)], W, stroke=W, sw=3)), "Restart", "Ulang"),
    "next": (lambda: badge(C["teal"], arrow_right(W)), "Next", "Seterusnya"),
    "back": (lambda: badge(C["teal"], g(arrow_right(W), transform="translate(128,0) scale(-1,1)")), "Back", "Kembali"),
    "up": (lambda: badge(C["teal"], g(arrow_right(W), transform="rotate(-90 64 62)")), "Up", "Atas"),
    "down": (lambda: badge(C["teal"], g(arrow_right(W), transform="rotate(90 64 62)")), "Down", "Bawah"),
    "settings": (lambda: poly(gear_pts(64, 64, 54, 42, 8), C["grey"]) + circle(64, 64, 30, C["lgrey"]) + circle(64, 64, 14, C["dgrey"]), "Settings", "Tetapan"),
    "sound_on": (lambda: poly([(20, 50), (40, 50), (64, 28), (64, 100), (40, 78), (20, 78)], C["yellow"])
                 + path(arc_d(64, 64, 22, -50, 50), stroke=INK, sw=7) + path(arc_d(64, 64, 40, -50, 50), stroke=INK, sw=7), "Sound on", "Bunyi"),
    "sound_off": (lambda: poly([(20, 50), (40, 50), (64, 28), (64, 100), (40, 78), (20, 78)], C["grey"])
                  + line(80, 48, 108, 80, sw=8) + line(108, 48, 80, 80, sw=8), "Sound off", "Senyap"),
    "music": (lambda: path("M44,94 L44,34 L100,22 L100,82", stroke=INK, sw=8) + poly([(44, 34), (100, 22), (100, 36), (44, 48)], INK, stroke=None)
              + ellipse(34, 94, 16, 12, C["purple"]) + ellipse(90, 84, 16, 12, C["purple"]), "Music", "Muzik"),
    "star": (lambda: poly(star_pts(64, 68, 56, 26), C["yellow"]) + shine("M64,24 L72,48 L56,48Z", 0.6), "Star", "Bintang"),
    "star_empty": (lambda: poly(star_pts(64, 68, 56, 26), C["lgrey"]), "Empty star", "Bintang kosong"),
    "heart": (lambda: path(HEART, C["red"]) + shine_ellipse(42, 44, 10, 7, -40, 0.6), "Heart", "Hati"),
    "heart_empty": (lambda: path(HEART, C["lgrey"]), "Empty heart", "Hati kosong"),
    "check": (lambda: badge(C["green"], polyline([(40, 64), (56, 82), (90, 44)], stroke=W, sw=12)), "Correct", "Betul"),
    "cross": (lambda: badge(C["red"], line(44, 42, 84, 82, stroke=W, sw=12), line(84, 42, 44, 82, stroke=W, sw=12)), "Wrong", "Salah"),
    "lock": (lambda: path("M40,60 L40,44 A24,24 0 0 1 88,44 L88,60", stroke=C["dgrey"], sw=12)
             + rect(26, 58, 76, 56, C["gold"], rx=10) + circle(64, 80, 8, INK, stroke=None) + rect(60, 82, 8, 18, INK, rx=3, stroke=None), "Locked", "Berkunci"),
    "unlock": (lambda: path("M40,58 L40,36 A24,24 0 0 1 88,36", stroke=C["dgrey"], sw=12)
               + rect(26, 58, 76, 56, C["green"], rx=10) + circle(64, 80, 8, INK, stroke=None) + rect(60, 82, 8, 18, INK, rx=3, stroke=None), "Unlocked", "Dibuka"),
    "hint": (lambda: "".join(line(64 + 50 * math.cos(math.radians(a)), 52 + 50 * math.sin(math.radians(a)),
                                  64 + 60 * math.cos(math.radians(a)), 52 + 60 * math.sin(math.radians(a)), stroke=C["gold"], sw=6)
                             for a in (-150, -120, -90, -60, -30))
             + path("M44,80 C30,66 32,30 64,28 C96,30 98,66 84,80 L82,92 L46,92Z", C["yellow"])
             + rect(46, 92, 36, 10, C["grey"], rx=3) + rect(50, 102, 28, 10, C["grey"], rx=3)
             + shine_ellipse(52, 46, 7, 12, 30, 0.7), "Hint", "Petunjuk"),
    "trophy": (lambda: path("M34,36 C14,36 14,66 44,70", stroke=C["gold"], sw=8) + path("M94,36 C114,36 114,66 84,70", stroke=C["gold"], sw=8)
               + path("M32,24 L96,24 L92,56 C88,76 74,82 64,82 C54,82 40,76 36,56Z", C["yellow"])
               + rect(56, 80, 16, 14, C["gold"]) + rect(38, 94, 52, 18, C["dwood"], rx=4) + rect(50, 99, 28, 8, C["yellow"], rx=2, stroke=None)
               + shine("M42,30 L52,30 L50,58 C48,64 44,60 44,56Z", 0.5), "Trophy", "Piala"),
    "medal": (lambda: poly([(40, 10), (60, 10), (74, 56), (54, 56)], C["blue"]) + poly([(68, 10), (88, 10), (74, 56), (54, 56)], C["red"])
              + circle(64, 82, 34, C["gold"]) + circle(64, 82, 24, C["yellow"]) + poly(star_pts(64, 84, 16, 7), C["gold"], sw=3), "Medal", "Pingat"),
    "coin": (lambda: circle(64, 68, 50, C["gold"]) + circle(64, 64, 50, C["yellow"]) + circle(64, 64, 36, C["gold"], sw=4)
             + poly(star_pts(64, 66, 22, 10), C["yellow"], sw=4) + shine_ellipse(40, 40, 8, 16, 40, 0.6), "Coin", "Syiling"),
    "gem": (lambda: poly([(36, 30), (92, 30), (114, 54), (64, 110), (14, 54)], C["teal"])
            + poly([(36, 30), (50, 54), (14, 54)], L.shade(C["teal"], 0.4), sw=3) + poly([(92, 30), (78, 54), (114, 54)], L.shade(C["teal"], -0.2), sw=3)
            + poly([(50, 54), (78, 54), (64, 110)], L.shade(C["teal"], 0.2), sw=3) + line(50, 54, 64, 30, sw=3) + line(78, 54, 64, 30, sw=3), "Gem", "Permata"),
    "clock": (lambda: circle(64, 64, 52, C["blue"]) + circle(64, 64, 42, W, sw=4)
              + "".join(line(64 + 34 * math.cos(math.radians(a)), 64 + 34 * math.sin(math.radians(a)),
                             64 + 40 * math.cos(math.radians(a)), 64 + 40 * math.sin(math.radians(a)), sw=4) for a in range(0, 360, 30))
              + line(64, 64, 64, 36, sw=6) + line(64, 64, 84, 72, sw=6) + circle(64, 64, 5, C["red"], sw=3), "Clock", "Jam"),
    "hourglass": (lambda: rect(28, 14, 72, 12, C["dwood"], rx=4) + rect(28, 102, 72, 12, C["dwood"], rx=4)
                  + path("M38,26 L90,26 C90,50 70,56 70,64 C70,72 90,78 90,102 L38,102 C38,78 58,72 58,64 C58,56 38,50 38,26Z", C["glass"])
                  + path("M48,40 L80,40 C76,52 66,56 64,60 C62,56 52,52 48,40Z", C["yellow"], stroke=None)
                  + path("M44,100 C48,86 60,80 64,78 C68,80 80,86 84,100Z", C["yellow"], stroke=None) + line(64, 64, 64, 90, stroke=C["gold"], sw=3), "Timer", "Pemasa"),
    "stopwatch": (lambda: rect(56, 8, 16, 14, C["dgrey"], rx=3) + line(96, 30, 104, 22, sw=8) + circle(64, 70, 46, C["red"]) + circle(64, 70, 36, W, sw=4)
                  + path(f"M64,70 L64,34 {arc_d(64, 70, 36, -90, 30)[arc_d(64, 70, 36, -90, 30).index('A'):]} Z", C["yellow"], stroke=None, extra='fill-opacity="0.8"')
                  + line(64, 70, 64, 42, sw=5) + circle(64, 70, 5, INK, stroke=None), "Stopwatch", "Jam randik"),
    "book": (lambda: rect(24, 18, 80, 96, C["blue"], rx=6) + rect(34, 18, 70, 88, L.shade(C["blue"], 0.15), rx=4, sw=4)
             + rect(44, 34, 46, 18, W, rx=3, sw=3) + path("M34,106 L100,106 L100,114 L34,114", C["paper"], sw=4), "Book", "Buku"),
    "pencil": (lambda: g(rect(52, 10, 24, 80, C["yellow"]) + rect(52, 10, 24, 14, C["pink"]) + rect(52, 22, 24, 6, C["grey"], sw=3)
                         + poly([(52, 90), (76, 90), (64, 116)], C["cream"]) + poly([(60, 108), (68, 108), (64, 116)], INK, sw=2)
                         + line(64, 30, 64, 88, stroke=C["gold"], sw=3), transform="rotate(40 64 64)"), "Pencil", "Pensel"),
    "ruler": (lambda: g(rect(20, 46, 88, 36, C["yellow"], rx=4) + "".join(line(28 + i * 9, 46, 28 + i * 9, 46 + (16 if i % 2 == 0 else 9), sw=3) for i in range(9)),
                        transform="rotate(-35 64 64)"), "Ruler", "Pembaris"),
    "calculator": (lambda: rect(26, 12, 76, 104, C["dgrey"], rx=10) + rect(36, 22, 56, 22, C["lime"], rx=4, sw=4)
                   + "".join(rect(36 + c * 20, 54 + r * 18, 14, 12, [W, W, C["orange"]][c] if r < 3 else C["green"] if c == 2 else W, rx=3, sw=3)
                             for r in range(3) for c in range(3)), "Calculator", "Kalkulator"),
    "flask": (lambda: path("M50,14 L78,14 L78,46 L106,104 C110,112 104,116 98,116 L30,116 C24,116 18,112 22,104 L50,46Z", C["glass"])
              + path("M36,82 L92,82 L104,106 C106,110 102,112 98,112 L30,112 C26,112 22,110 24,106Z", C["green"], stroke=None)
              + circle(60, 98, 5, W, stroke=None, extra='fill-opacity="0.7"') + circle(76, 92, 3, W, stroke=None, extra='fill-opacity="0.7"')
              + rect(44, 8, 40, 10, C["grey"], rx=4) + shine("M56,50 L62,50 L46,100 L40,100Z", 0.6), "Science", "Sains"),
    "atom": (lambda: "".join(ellipse(64, 64, 54, 20, "none", stroke=C["blue"], sw=6, extra=f'transform="rotate({a} 64 64)"') for a in (0, 60, 120))
             + circle(64, 64, 12, C["red"]) + circle(110, 64, 6, C["yellow"], sw=3), "Atom", "Atom"),
    "globe": (lambda: circle(64, 60, 48, C["blue"]) + path("M38,30 C52,26 58,36 52,46 C46,56 30,52 26,62 C22,50 28,36 38,30Z", C["green"], sw=4)
              + path("M70,50 C84,44 100,52 102,66 C104,82 90,96 80,94 C74,82 84,76 74,68 C66,62 64,54 70,50Z", C["green"], sw=4)
              + path(arc_d(64, 60, 56, 120, 300), stroke=C["dwood"], sw=6) + rect(54, 108, 20, 6, C["dwood"]) + rect(40, 114, 48, 8, C["dwood"], rx=3), "Globe", "Glob"),
    "palette": (lambda: path("M64,14 C100,14 118,40 114,64 C110,84 90,80 84,90 C78,100 92,112 70,114 C34,118 12,92 14,62 C16,34 38,14 64,14Z", C["cream"])
                + circle(42, 46, 10, C["red"], sw=4) + circle(68, 34, 10, C["yellow"], sw=4) + circle(92, 48, 10, C["blue"], sw=4)
                + circle(36, 76, 10, C["green"], sw=4) + circle(56, 96, 9, W, sw=4), "Art", "Seni"),
    "info": (lambda: badge(C["blue"], circle(64, 38, 8, W, stroke=None), rect(56, 52, 16, 40, W, rx=5, stroke=None)), "Info", "Maklumat"),
    "question": (lambda: badge(C["purple"], path("M46,46 C46,30 82,28 82,46 C82,58 64,58 64,72", stroke=W, sw=12), circle(64, 90, 7, W, stroke=None)), "Question", "Soalan"),
    "user": (lambda: circle(64, 42, 24, C["skin2"]) + path("M18,116 C18,82 40,72 64,72 C88,72 110,82 110,116Z", C["blue"]), "Player", "Pemain"),
    "users": (lambda: circle(86, 40, 18, C["skin3"]) + path("M56,104 C56,80 70,70 86,70 C102,70 118,80 118,104Z", C["teal"])
              + circle(48, 48, 22, C["skin1"]) + path("M8,114 C8,86 26,76 48,76 C70,76 88,86 88,114Z", C["orange"]), "Class", "Kelas"),
    "leaderboard": (lambda: rect(46, 50, 36, 66, C["yellow"]) + rect(10, 72, 36, 44, C["grey"]) + rect(82, 84, 36, 32, C["orange"])
                    + poly(star_pts(64, 30, 18, 8), C["gold"], sw=4), "Leaderboard", "Papan markah"),
    "calendar": (lambda: rect(16, 24, 96, 90, W, rx=8) + path("M16,32 C16,27 20,24 24,24 L104,24 C108,24 112,27 112,32 L112,48 L16,48Z", C["red"])
                 + "".join(rect(28 + c * 20, 58 + r * 18, 12, 10, C["lgrey"] if (r, c) != (1, 2) else C["blue"], rx=2, sw=0.1) for r in range(3) for c in range(4))
                 + rect(34, 14, 8, 20, C["dgrey"], rx=3) + rect(86, 14, 8, 20, C["dgrey"], rx=3), "Calendar", "Kalendar"),
    "mic": (lambda: rect(46, 14, 36, 62, C["dgrey"], rx=18) + path("M32,58 C32,92 96,92 96,58", stroke=INK, sw=6) + line(64, 86, 64, 108) + line(44, 110, 84, 110)
            + "".join(line(52, 30 + i * 10, 76, 30 + i * 10, stroke=C["grey"], sw=3) for i in range(4)), "Microphone", "Mikrofon"),
    "speaker": (lambda: rect(30, 12, 68, 104, C["navy"], rx=10) + circle(64, 40, 14, C["grey"]) + circle(64, 82, 24, C["grey"]) + circle(64, 82, 10, C["dgrey"]), "Speaker", "Pembesar suara"),
    "puzzle": (lambda: path("M24,40 L50,40 C46,24 76,24 72,40 L98,40 L98,64 C114,60 114,90 98,86 L98,112 L24,112 L24,86 C40,90 40,60 24,64Z", C["purple"]), "Puzzle", "Teka-teki"),
    "target": (lambda: circle(58, 70, 48, C["red"]) + circle(58, 70, 34, W) + circle(58, 70, 20, C["red"]) + circle(58, 70, 7, W, sw=3)
               + line(58, 70, 108, 20, sw=6) + poly([(98, 14), (114, 14), (114, 30)], C["yellow"], sw=4), "Target", "Sasaran"),
    "flag": (lambda: line(30, 14, 30, 116, stroke=C["dwood"], sw=8) + path("M34,18 C56,8 72,30 104,20 L104,64 C72,74 56,52 34,62Z", C["red"]), "Flag", "Bendera"),
    "map": (lambda: poly([(12, 30), (44, 20), (84, 30), (116, 20), (116, 100), (84, 110), (44, 100), (12, 110)], C["cream"])
            + line(44, 20, 44, 100, sw=4) + line(84, 30, 84, 110, sw=4) + path("M24,84 C40,60 60,90 72,62 C78,50 92,58 98,46", stroke=C["red"], sw=4, extra='stroke-dasharray="6 6"')
            + line(94, 40, 104, 52, stroke=C["red"], sw=6) + line(104, 40, 94, 52, stroke=C["red"], sw=6), "Map", "Peta"),
    "pin": (lambda: path("M64,118 C44,88 26,70 26,48 C26,26 44,10 64,10 C84,10 102,26 102,48 C102,70 84,88 64,118Z", C["red"]) + circle(64, 48, 16, W), "Location", "Lokasi"),
    "shield": (lambda: path("M64,12 L108,28 C108,72 92,100 64,116 C36,100 20,72 20,28Z", C["blue"]) + polyline([(44, 62), (58, 78), (86, 46)], stroke=W, sw=10), "Shield", "Perisai"),
    "plus": (lambda: badge(C["green"], rect(56, 34, 16, 56, W, rx=4, stroke=None), rect(36, 54, 56, 16, W, rx=4, stroke=None)), "Add", "Tambah"),
    "minus": (lambda: badge(C["red"], rect(36, 54, 56, 16, W, rx=4, stroke=None)), "Subtract", "Tolak"),
    "menu": (lambda: badge(C["navy"], *(rect(38, 40 + i * 18, 52, 10, W, rx=5, stroke=None) for i in range(3))), "Menu", "Menu"),
    "close": (lambda: badge(C["dgrey"], line(46, 44, 82, 80, stroke=W, sw=10), line(82, 44, 46, 80, stroke=W, sw=10)), "Close", "Tutup"),
    "eye": (lambda: path("M8,64 C30,26 98,26 120,64 C98,102 30,102 8,64Z", W) + circle(64, 64, 22, C["blue"]) + circle(64, 64, 10, INK, stroke=None)
            + circle(70, 58, 4, W, stroke=None), "Show", "Tunjuk"),
    "lightning": (lambda: poly([(72, 8), (26, 72), (58, 72), (48, 120), (102, 50), (68, 50), (84, 8)], C["yellow"]), "Power-up", "Kuasa"),
    "gift": (lambda: rect(20, 52, 88, 62, C["red"], rx=6) + rect(14, 38, 100, 20, L.shade(C["red"], 0.2), rx=5) + rect(56, 38, 16, 76, C["yellow"])
             + path("M64,38 C40,14 26,32 44,38Z", C["yellow"], sw=5) + path("M64,38 C88,14 102,32 84,38Z", C["yellow"], sw=5), "Gift", "Hadiah"),
    "key": (lambda: circle(38, 64, 24, C["gold"]) + circle(38, 64, 9, W) + rect(58, 58, 56, 12, C["gold"], rx=4) + rect(94, 66, 10, 18, C["gold"], rx=2)
            + rect(78, 66, 8, 14, C["gold"], rx=2), "Key", "Kunci"),
    "search": (lambda: line(80, 80, 112, 112, stroke=C["dwood"], sw=16) + circle(54, 54, 38, C["glass"], sw=10, stroke=C["grey"])
               + circle(54, 54, 38, "none", sw=4) + shine_ellipse(42, 40, 8, 14, 40, 0.8), "Search", "Cari"),
    "grad_cap": (lambda: poly([(64, 20), (122, 46), (64, 72), (6, 46)], C["navy"]) + path("M30,58 L30,86 C46,102 82,102 98,86 L98,58 L64,72Z", C["navy"])
                 + line(108, 50, 108, 84, stroke=C["yellow"], sw=5) + circle(108, 90, 7, C["yellow"], sw=4), "Graduate", "Graduan"),
    "school": (lambda: rect(14, 54, 100, 60, C["cream"]) + poly([(6, 58), (64, 22), (122, 58)], C["red"]) + rect(52, 82, 24, 32, C["dwood"], rx=3)
               + "".join(rect(x, 66, 14, 14, C["sky"], rx=2, sw=4) for x in (22, 92)) + line(64, 22, 64, 4, sw=4)
               + path("M64,4 L84,9 L64,14Z", C["blue"], sw=3) + circle(64, 44, 8, W, sw=4), "School", "Sekolah"),
    "chat": (lambda: path("M14,24 C14,16 20,12 28,12 L100,12 C108,12 114,16 114,24 L114,72 C114,80 108,84 100,84 L50,84 L28,108 L32,84 L28,84 C20,84 14,80 14,72Z", W)
             + circle(42, 48, 8, C["blue"], stroke=None) + circle(64, 48, 8, C["blue"], stroke=None) + circle(86, 48, 8, C["blue"], stroke=None), "Talk", "Bual"),
    "translate": (lambda: rect(8, 12, 70, 56, C["blue"], rx=10) + poly([(24, 66), (24, 84), (40, 66)], C["blue"])
                  + rect(50, 46, 70, 56, C["orange"], rx=10) + poly([(104, 100), (104, 118), (88, 100)], C["orange"])
                  + path("M28,52 L42,24 L56,52 M33,42 L51,42", stroke=W, sw=6) + path("M70,62 L100,62 M85,56 L85,62 M74,62 C78,80 92,88 100,90 M96,62 C92,78 80,88 70,90", stroke=W, sw=5), "Language", "Bahasa"),
    "bag": (lambda: path("M44,44 L44,32 A20,20 0 0 1 84,32 L84,44", stroke=INK, sw=6) + path("M20,44 L108,44 L100,116 L28,116Z", C["teal"])
            + circle(44, 60, 4, INK, stroke=None) + circle(84, 60, 4, INK, stroke=None), "Shop", "Kedai"),
    "keyboard": (lambda: rect(8, 34, 112, 64, C["lgrey"], rx=8) + "".join(rect(18 + c * 15, 44 + r * 15, 11, 10, W, rx=2, sw=3) for r in range(3) for c in range(7))
                 + rect(34, 86 - 2, 60, 8, W, rx=2, sw=3), "Type", "Taip"),
    "brush": (lambda: g(rect(58, 6, 12, 64, C["wood"]) + rect(54, 66, 20, 12, C["grey"]) + path("M54,78 L74,78 C76,96 70,110 64,120 C58,110 52,96 54,78Z", C["red"]),
                        transform="rotate(30 64 64)"), "Draw", "Lukis"),
    "camera": (lambda: rect(10, 36, 108, 76, C["dgrey"], rx=10) + rect(40, 24, 40, 16, C["dgrey"], rx=4) + circle(64, 74, 26, C["sky"]) + circle(64, 74, 12, C["navy"], sw=4)
               + rect(92, 46, 14, 8, C["yellow"], rx=2, sw=3), "Camera", "Kamera"),
}


def main():
    for name, (fn, en, bm) in ICONS.items():
        L.save("icons", name, L.doc(128, 128, fn()), en=en, bm=bm, tags=["icon", "ui"])
    return len(ICONS)


if __name__ == "__main__":
    print(main(), "icons")
