"""Remaining KSSR subjects: Pendidikan Islam, Pendidikan Moral, PJPK, Seni Visual, Muzik,
Sejarah and Reka Bentuk dan Teknologi. 256 view box -> 512 px.
Pendidikan Islam art is objects and places only (no figures), in line with common
Malaysian classroom material."""
import math
import svg_lib as L
from svg_lib import C, INK, circle, ellipse, rect, path, poly, line, polyline, g, star_pts, ngon, shadow, shine, shine_ellipse, arc_d

W = "#FFFFFF"
SUBJ = {}


def mk(subject):
    def f(name, body, en, bm, tags=(), w=256, h=256, defs=""):
        L.save(f"subjects/{subject}", name, L.doc(w, h, body, defs=defs), en=en, bm=bm, tags=[subject, *tags])
    return f


PI, MO, PJ, SV, MU, SJ, RB = (mk(s) for s in ("pendidikan_islam", "pendidikan_moral", "pjpk", "seni_visual", "muzik", "sejarah", "rbt"))


def crescent(cx, cy, r, col, sw=None):
    return path(f"M{cx},{cy - r} A{r},{r} 0 1 0 {cx},{cy + r} A{r * 1.25},{r * 1.25} 0 0 1 {cx},{cy - r}Z", col, sw=sw)


def ball_shadow():
    return shadow(128, 240, 70, 8)


def main():
    L.SW = 7
    # ======================= PENDIDIKAN ISLAM =======================
    PI("masjid", shadow(128, 240, 120, 8) + rect(30, 130, 196, 106, W) + path("M60,130 C60,60 196,60 196,130Z", C["dgreen"])
       + line(128, 64, 128, 40, sw=5) + crescent(128, 30, 9, C["gold"], sw=3)
       + rect(4, 70, 26, 166, W) + path("M4,70 C4,44 30,44 30,70Z", C["dgreen"]) + rect(226, 70, 26, 166, W) + path("M226,70 C226,44 252,44 252,70Z", C["dgreen"])
       + path("M108,236 L108,190 C108,170 148,170 148,190 L148,236Z", C["dgreen"]) + "".join(path(f"M{x},176 L{x},156 C{x},146 {x + 20},146 {x + 20},156 L{x + 20},176Z", C["sky"], sw=5) for x in (50, 186)),
       "Mosque", "Masjid", ["place"])
    PI("sejadah", g(rect(50, 20, 156, 216, C["red"], rx=6) + rect(64, 34, 128, 188, "none", rx=4, stroke=C["gold"], sw=6)
                    + path("M90,100 L90,70 C90,48 166,48 166,70 L166,100", stroke=C["gold"], sw=6) + "".join(poly(ngon(128, 160 + k * 26, 10, 4), C["gold"], sw=3) for k in range(2))
                    + "".join(line(x, 236, x, 250, stroke=C["gold"], sw=4) for x in range(56, 206, 12)), transform="rotate(-8 128 128)"),
       "Prayer mat", "Sejadah", ["prayer"])
    PI("al_quran_rehal", shadow(128, 240, 110, 8) + poly([(20, 236), (128, 150), (236, 236)], C["wood"]) + poly([(20, 160), (128, 236), (236, 160)], C["dwood"])
       + path("M30,150 L120,70 L128,150 L40,170Z", C["dgreen"]) + path("M226,150 L136,70 L128,150 L216,170Z", C["dgreen"])
       + path("M50,140 L110,92 L112,138 L60,154Z", "none", stroke=C["gold"], sw=4) + path("M206,140 L146,92 L144,138 L196,154Z", "none", stroke=C["gold"], sw=4)
       + poly(ngon(86, 126, 12, 8, rot=22.5), C["gold"], sw=3) + poly(ngon(170, 126, 12, 8, rot=22.5), C["gold"], sw=3),
       "Quran on a stand (rehal)", "Al-Quran dan rehal", ["book"])
    PI("tasbih", "".join(circle(128 + 86 * math.cos(math.radians(a)), 116 + 86 * math.sin(math.radians(a)), 11, C["dgreen"], sw=4) for a in range(0, 360, 12))
       + circle(128, 202, 15, C["gold"], sw=4) + line(128, 216, 128, 240, stroke=C["gold"], sw=5) + path("M118,240 L138,240 L128,252Z", C["gold"], sw=3),
       "Prayer beads", "Tasbih", ["prayer"])
    PI("kopiah", shadow(128, 220, 100, 8) + path("M30,190 L30,130 C30,70 226,70 226,130 L226,190 C190,206 66,206 30,190Z", W)
       + "".join(path(f"M30,{y} C66,{y + 14} 190,{y + 14} 226,{y}", stroke=C["lgrey"], sw=4) for y in (130, 150, 170))
       + "".join(poly(ngon(x, 112, 7, 6, rot=0), C["lgrey"], sw=2) for x in (70, 100, 128, 156, 186)), "Prayer cap", "Kopiah", ["clothing"])
    PI("songkok", shadow(128, 220, 100, 8) + path("M30,200 L42,90 C70,80 186,80 214,90 L226,200 C190,212 66,212 30,200Z", C["black"])
       + ellipse(128, 88, 86, 14, "#3A3A55") + path("M30,200 C66,212 190,212 226,200", stroke="#555577", sw=4), "Songkok", "Songkok", ["clothing"])
    PI("paip_air_wuduk", rect(20, 40, 216, 30, C["lgrey"], rx=6) + rect(100, 66, 56, 40, C["grey"], rx=6) + path("M146,86 L196,86 C210,86 214,100 214,110", stroke=C["grey"], sw=18)
       + rect(116, 30, 24, 16, C["red"], rx=4) + "".join(path(f"M{x},{y} C{x - 8},{y + 14} {x - 8},{y + 22} {x},{y + 22} C{x + 8},{y + 22} {x + 8},{y + 14} {x},{y}Z", C["blue"], sw=4)
                                                      for x, y in ((214, 130), (206, 170), (220, 206))), "Ablution tap", "Paip air wuduk", ["wudhu"])
    PI("kendi", shadow(128, 240, 70, 8) + path("M96,60 L160,60 L156,84 C210,100 220,190 180,226 L76,226 C36,190 46,100 100,84Z", C["wood"])
       + path("M180,130 C210,120 230,100 244,80", stroke=INK, sw=20) + path("M180,130 C210,120 230,100 244,80", stroke=C["wood"], sw=10)
       + rect(90, 48, 76, 16, C["dwood"], rx=5) + path("M60,160 C100,176 156,176 196,160", stroke=C["gold"], sw=6), "Water jug", "Kendi", ["wudhu"])
    PI("kurma", shadow(128, 236, 100, 8) + ellipse(128, 190, 110, 40, C["wood"]) + ellipse(128, 180, 96, 28, C["cream"], sw=4)
       + "".join(ellipse(x, y, 26, 16, "#6D2E1F", extra=f'transform="rotate({a} {x} {y})"') + shine_ellipse(x - 6, y - 5, 8, 3, a, 0.4)
                 for x, y, a in ((86, 170, -20), (128, 164, 10), (170, 170, -10), (108, 186, 20), (150, 188, -30))), "Dates", "Kurma", ["food", "ramadan"])
    PI("bulan_bintang", crescent(110, 128, 92, C["gold"]) + poly(star_pts(140, 96, 30, 12), C["yellow"]), "Crescent and star", "Bulan dan bintang", ["symbol"])
    PI("pelita", shadow(128, 236, 60, 8) + path("M128,40 C146,70 150,90 128,106 C106,90 110,70 128,40Z", C["orange"]) + path("M128,62 C138,80 136,92 128,100 C120,92 118,80 128,62Z", C["yellow"], sw=4)
       + line(128, 106, 128, 130, sw=5) + path("M60,130 L196,130 C196,180 170,200 128,200 C86,200 60,180 60,130Z", C["gold"]) + rect(98, 200, 60, 30, C["gold"], rx=6),
       "Oil lamp (pelita)", "Pelita", ["festival", "raya"])
    PI("tanglung", line(128, 6, 128, 34, sw=5) + path("M128,30 L170,60 L86,60Z", C["gold"]) + rect(80, 60, 96, 130, C["dgreen"], rx=10)
       + rect(94, 74, 68, 102, C["yellow"], rx=6, sw=5) + path("M128,96 C140,116 140,134 128,150 C116,134 116,116 128,96Z", C["orange"], sw=3) + path("M80,190 L176,190 L150,226 L106,226Z", C["gold"]),
       "Lantern", "Tanglung", ["festival", "ramadan"])
    PI("kaabah", shadow(128, 240, 110, 8) + poly([(30, 90), (150, 70), (226, 96), (106, 116)], "#2A2A3A") + poly([(30, 90), (106, 116), (106, 230), (30, 200)], C["black"])
       + poly([(106, 116), (226, 96), (226, 204), (106, 230)], "#2A2A3A") + poly([(30, 112), (106, 140), (106, 156), (30, 128)], C["gold"], sw=3)
       + poly([(106, 140), (226, 118), (226, 134), (106, 156)], C["gold"], sw=3) + rect(150, 160, 24, 50, C["gold"], sw=3), "Kaaba", "Kaabah", ["place", "hajj"])
    PI("kompas_kiblat", circle(128, 128, 104, C["dgreen"]) + circle(128, 128, 88, C["cream"], sw=5)
       + poly([(128, 40), (144, 128), (112, 128)], C["red"], sw=4) + poly([(128, 216), (144, 128), (112, 128)], C["lgrey"], sw=4)
       + rect(176, 64, 22, 22, C["black"], sw=3, extra='transform="rotate(30 187 75)"') + circle(128, 128, 9, C["gold"], sw=3), "Qibla compass", "Kompas kiblat", ["prayer"])
    PI("sampul_duit_raya", shadow(128, 228, 100, 8) + rect(24, 60, 208, 150, C["dgreen"], rx=10) + poly([(24, 64), (128, 140), (232, 64)], L.shade(C["dgreen"], 0.2))
       + crescent(120, 170, 20, C["gold"], sw=4) + poly(star_pts(146, 160, 10, 4), C["gold"], sw=2) + rect(24, 60, 208, 150, "none", rx=10), "Raya money packet", "Sampul duit raya", ["festival", "raya"])
    # ======================= PENDIDIKAN MORAL =======================
    hand = lambda col: path("M40,170 L40,120 C40,110 56,110 56,120 L56,80 C56,70 72,70 72,80 L72,70 C72,60 88,60 88,70 L88,78 C88,68 104,68 104,78 L104,140 L116,124 C122,116 136,122 130,134 L104,190 C96,206 80,212 64,212 L56,212 C46,212 40,200 40,190Z", col, sw=6)
    MO("tolong_menolong", hand(C["skin2"]) + g(hand(C["skin3"]), transform="translate(256,0) scale(-1,1)") + path("M128,64 C116,44 92,52 100,72 C104,84 128,100 128,100 C128,100 152,84 156,72 C164,52 140,44 128,64Z", C["red"], sw=5),
       "Helping each other", "Tolong-menolong", ["value"])
    MO("berjabat_tangan", path("M10,140 L70,110 L120,120 L170,100 L246,130 L246,170 L190,170 L150,200 C140,208 128,208 120,200 L80,170 L10,170Z", C["skin2"])
       + path("M120,120 L90,140 C84,150 96,160 108,154 L140,138", C["skin3"], sw=6) + rect(0, 104, 30, 74, C["blue"], rx=4) + rect(226, 104, 30, 74, C["orange"], rx=4), "Handshake", "Berjabat tangan", ["value"])
    MO("keluarga", "".join(circle(x, y, r, sk) + path(f"M{x - r * 1.5},{y + r * 3.2} C{x - r * 1.5},{y + r * 1.4} {x + r * 1.5},{y + r * 1.4} {x + r * 1.5},{y + r * 3.2}Z", col)
                         for x, y, r, sk, col in ((70, 70, 28, C["skin2"], C["blue"]), (186, 74, 26, C["skin2"], C["pink"]), (110, 140, 18, C["skin2"], C["green"]), (150, 146, 16, C["skin2"], C["yellow"])))
       + path("M128,40 C122,30 110,34 114,44 C116,50 128,58 128,58 C128,58 140,50 142,44 C146,34 134,30 128,40Z", C["red"], sw=4), "Family", "Keluarga", ["value"])
    MO("berkongsi", path("M30,150 C60,150 80,170 110,170 L150,170", stroke=INK, sw=0.1) + hand(C["skin1"]) + g(hand(C["skin4"]), transform="translate(256,0) scale(-1,1)")
       + circle(128, 66, 34, C["red"]) + path("M128,34 C128,20 136,12 144,8", stroke=C["dwood"], sw=6) + line(128, 34, 128, 98, stroke=W, sw=4), "Sharing", "Berkongsi", ["value"])
    for nm, col, en, bm in (("tong_kitar_biru", "#2F6FD6", "Recycling bin (paper)", "Tong kitar semula biru (kertas)"),
                            ("tong_kitar_oren", "#F28C28", "Recycling bin (plastic & cans)", "Tong kitar semula oren (plastik & tin)"),
                            ("tong_kitar_coklat", "#8D5A3B", "Recycling bin (glass)", "Tong kitar semula coklat (kaca)")):
        MO(nm, shadow(128, 240, 80, 8) + path("M50,70 L206,70 L190,236 L66,236Z", col) + rect(40, 46, 176, 28, L.shade(col, -0.25), rx=8)
           + g("".join(g(path("M128,104 L150,140 L136,140", stroke=W, sw=10), transform=f"rotate({a} 128 150)") for a in (0, 120, 240))), en, bm, ["environment", "recycle"])
    MO("tong_sampah", shadow(128, 240, 70, 8) + path("M60,70 L196,70 L182,236 L74,236Z", C["dgrey"]) + rect(50, 50, 156, 24, C["grey"], rx=6) + rect(108, 34, 40, 18, C["grey"], rx=4)
       + "".join(line(x, 96, x - (x - 128) * 0.1, 214, stroke=C["grey"], sw=6) for x in (96, 128, 160)), "Rubbish bin", "Tong sampah", ["environment"])
    MO("tabung", shadow(128, 236, 90, 8) + ellipse(128, 150, 96, 74, C["pink"]) + circle(206, 140, 26, C["pink"]) + ellipse(214, 142, 10, 12, L.shade(C["pink"], -0.2), sw=4)
       + poly([(70, 90), (84, 60), (104, 84)], C["pink"]) + rect(110, 76, 44, 8, INK, rx=4, stroke=None) + circle(170, 120, 7, INK, stroke=None)
       + "".join(rect(x, 206, 20, 26, C["pink"], rx=6) for x in (70, 160)) + circle(132, 50, 18, C["yellow"]) , "Piggy bank (savings)", "Tabung", ["value", "money"])
    MO("dompet", rect(28, 70, 200, 136, "#8D5A3B", rx=14) + rect(28, 70, 200, 40, "#A0663F", rx=14) + rect(170, 112, 58, 44, "#6D4423", rx=8) + circle(196, 134, 7, C["gold"], sw=3)
       + rect(44, 50, 70, 30, "#3FAE6A", rx=4, sw=4), "Wallet (honesty)", "Dompet (amanah)", ["value"])
    MO("kad_terima_kasih", g(rect(40, 30, 176, 196, C["cream"], rx=8) + path("M128,96 C112,70 72,80 80,112 C88,140 128,164 128,164 C128,164 168,140 176,112 C184,80 144,70 128,96Z", C["red"])
                             + "".join(rect(70, 184 + k * 14, 116 - k * 30, 6, C["lgrey"], rx=3, stroke=None) for k in range(2)), transform="rotate(-6 128 128)"), "Thank-you card", "Kad terima kasih", ["value"])
    MO("ibu_jari", path("M70,120 L110,120 L130,50 C134,36 160,40 156,60 L150,100 L206,100 C222,100 226,120 214,128 C226,134 222,152 210,154 C220,160 216,176 204,178 C212,186 206,204 190,204 L110,204 L70,204Z", C["skin2"])
       + rect(30, 112, 46, 100, C["blue"], rx=6), "Thumbs up", "Bagus", ["value", "feedback"])
    MO("lampu_isyarat", rect(88, 12, 80, 180, C["black"], rx=16) + circle(128, 48, 24, C["red"]) + circle(128, 102, 24, C["yellow"], extra='fill-opacity="0.4"')
       + circle(128, 156, 24, C["green"], extra='fill-opacity="0.4"') + rect(116, 192, 24, 56, C["dgrey"]), "Traffic light", "Lampu isyarat", ["safety", "road"])
    MO("lintasan_zebra", rect(0, 40, 256, 176, C["dgrey"], stroke=None) + "".join(rect(20 + i * 46, 60, 28, 136, W, stroke=None) for i in range(5)), "Zebra crossing", "Lintasan belang", ["safety", "road"])
    # ======================= PJPK =======================
    PJ("bola_sepak", ball_shadow() + circle(128, 124, 100, W) + poly(ngon(128, 124, 30, 5), INK, stroke=None)
       + "".join(poly(ngon(128 + 84 * math.cos(math.radians(-90 + a)), 124 + 84 * math.sin(math.radians(-90 + a)), 24, 5, rot=-90 + a + 180), INK, stroke=None) for a in range(0, 360, 72))
       + "".join(line(128 + 30 * math.cos(math.radians(-90 + a)), 124 + 30 * math.sin(math.radians(-90 + a)), 128 + 62 * math.cos(math.radians(-90 + a)), 124 + 62 * math.sin(math.radians(-90 + a)), sw=4) for a in range(0, 360, 72))
       + circle(128, 124, 100, "none") + shine_ellipse(92, 76, 12, 22, 40, 0.4), "Football", "Bola sepak", ["sport", "ball"], defs="")
    PJ("bola_takraw", ball_shadow() + circle(128, 124, 100, "#E8C547")
       + "".join(circle(128 + 64 * math.cos(math.radians(a)), 124 + 64 * math.sin(math.radians(a)), 36, "none", stroke=L.shade("#E8C547", -0.35), sw=6) for a in range(0, 360, 60))
       + circle(128, 124, 36, "none", stroke=L.shade("#E8C547", -0.35), sw=6) + circle(128, 124, 100, "none"), "Sepak takraw ball", "Bola sepak takraw", ["sport", "ball", "local"])
    PJ("bola_keranjang", ball_shadow() + circle(128, 124, 100, C["orange"]) + line(28, 124, 228, 124, sw=5) + line(128, 24, 128, 224, sw=5)
       + path("M60,50 C100,90 100,160 60,200", stroke=INK, sw=5) + path("M196,50 C156,90 156,160 196,200", stroke=INK, sw=5), "Basketball", "Bola keranjang", ["sport", "ball"])
    PJ("bola_jaring", ball_shadow() + circle(128, 124, 100, W) + path("M28,124 C80,100 176,100 228,124", stroke=C["blue"], sw=6) + path("M60,52 C110,90 110,160 60,196", stroke=C["blue"], sw=6)
       + path("M196,52 C146,90 146,160 196,196", stroke=C["blue"], sw=6) + circle(128, 124, 100, "none") + shine_ellipse(92, 76, 12, 22, 40, 0.4), "Netball", "Bola jaring", ["sport", "ball"])
    PJ("badminton", g(ellipse(128, 70, 50, 64, "none", sw=12, stroke=C["red"]) + ellipse(128, 70, 50, 64, "none", sw=4)
                      + "".join(line(128 + dx, 10, 128 + dx, 130, stroke=C["lgrey"], sw=2) for dx in range(-40, 44, 10)) + "".join(line(78, 30 + dy, 178, 30 + dy, stroke=C["lgrey"], sw=2) for dy in range(0, 90, 12))
                      + ellipse(128, 70, 50, 64, "none", sw=4) + rect(122, 132, 12, 70, C["grey"]) + rect(116, 196, 24, 50, C["navy"], rx=8), transform="rotate(-30 128 128)")
       + path("M180,170 L222,150 L236,190 L196,204Z", W) + circle(190, 196, 14, W) + line(200, 156, 214, 196, stroke=C["lgrey"], sw=3), "Badminton racket and shuttle", "Raket dan bulu tangkis", ["sport", "local"])
    PJ("ping_pong", circle(100, 110, 74, C["red"]) + rect(88, 176, 24, 66, C["wood"], rx=8, extra='transform="rotate(20 100 210)"') + circle(196, 70, 22, C["orange"]), "Table tennis", "Ping pong", ["sport"])
    PJ("wisel", line(60, 70, 20, 40, stroke=C["red"], sw=6) + path("M60,90 L180,90 L180,130 C180,150 170,170 140,170 C110,170 90,150 90,130 L60,130Z", C["lgrey"]) + circle(140, 126, 14, C["dgrey"], sw=4)
       + rect(176, 86, 14, 48, C["grey"], rx=4) + path("M196,100 L220,90 M198,116 L226,116 M196,132 L220,142", stroke=INK, sw=5), "Whistle", "Wisel", ["sport"])
    PJ("kon", shadow(128, 240, 100, 8) + rect(30, 210, 196, 24, C["orange"], rx=6) + path("M100,30 L156,30 L200,214 L56,214Z", C["orange"])
       + path("M88,90 L168,90 L176,124 L80,124Z", W, sw=4) + path("M72,154 L184,154 L192,186 L64,186Z", W, sw=4), "Cone", "Kon", ["sport"])
    PJ("tali_lompat", path("M60,60 C20,180 120,250 128,250 C136,250 236,180 196,60", stroke=C["pink"], sw=8) + rect(44, 14, 32, 60, C["blue"], rx=12) + rect(180, 14, 32, 60, C["blue"], rx=12),
       "Skipping rope", "Tali lompat", ["sport"])
    PJ("hula_hoop", ellipse(128, 140, 110, 50, "none", stroke=INK, sw=24) + ellipse(128, 140, 110, 50, "none", stroke=C["purple"], sw=14)
       + "".join(line(128 + 110 * math.cos(math.radians(a)), 140 + 50 * math.sin(math.radians(a)), 128 + 110 * math.cos(math.radians(a + 8)), 140 + 50 * math.sin(math.radians(a + 8)), stroke=C["yellow"], sw=12) for a in range(0, 360, 40)),
       "Hula hoop", "Gelung rotan", ["sport"])
    PJ("kit_pertolongan_cemas", shadow(128, 236, 100, 8) + rect(24, 66, 208, 160, W, rx=16) + path("M90,66 L90,46 C90,40 96,36 102,36 L154,36 C160,36 166,40 166,46 L166,66", stroke=INK, sw=8)
       + rect(110, 100, 36, 92, C["red"], rx=4, stroke=None) + rect(82, 128, 92, 36, C["red"], rx=4, stroke=None), "First aid kit", "Kit pertolongan cemas", ["health"])
    PJ("berus_gigi", g(rect(20, 116, 170, 26, C["teal"], rx=12) + rect(150, 96, 70, 22, C["teal"], rx=6) + "".join(rect(156 + i * 12, 66, 8, 32, W, rx=3, sw=3) for i in range(5)), transform="rotate(-20 128 128)")
       + path("M60,200 L170,200 C186,200 196,210 196,220 L60,220Z", C["red"]) + rect(196, 202, 20, 16, C["lgrey"], rx=3), "Toothbrush and toothpaste", "Berus gigi dan ubat gigi", ["health", "hygiene"])
    PJ("sabun", shadow(128, 226, 90, 8) + rect(40, 100, 176, 110, C["pink"], rx=40) + "".join(circle(x, y, r, W, sw=4, extra='fill-opacity="0.8"') for x, y, r in ((70, 80, 20), (110, 60, 14), (170, 74, 24), (210, 50, 12)))
       + shine_ellipse(90, 130, 30, 8, 0, 0.5), "Soap", "Sabun", ["health", "hygiene"])
    PJ("basuh_tangan", rect(10, 180, 236, 40, W, rx=10) + path("M30,180 C30,230 226,230 226,180", C["lgrey"]) + rect(120, 30, 16, 50, C["grey"]) + path("M128,40 L180,40 C192,40 196,50 196,60", stroke=C["grey"], sw=14)
       + "".join(path(f"M{x},{y} C{x - 6},{y + 10} {x - 6},{y + 16} {x},{y + 16} C{x + 6},{y + 16} {x + 6},{y + 10} {x},{y}Z", C["blue"], sw=3) for x, y in ((196, 78), (190, 104)))
       + path("M100,180 C110,140 150,130 180,150 C190,160 170,176 150,170 L120,180Z", C["skin2"]) + path("M200,180 C190,140 150,124 120,140 C110,150 130,166 150,160 L180,180Z", C["skin2"])
       + "".join(circle(x, y, 8, W, sw=3) for x, y in ((140, 128), (170, 120), (120, 120))), "Washing hands", "Basuh tangan", ["health", "hygiene"])
    PJ("tuala", path("M40,40 L216,40 L216,220 C190,230 66,230 40,220Z", C["sky"]) + "".join(line(40, y, 216, y, stroke=W, sw=6) for y in (70, 190)) + rect(30, 30, 196, 20, C["dgrey"], rx=6),
       "Towel", "Tuala", ["health", "hygiene"])
    PJ("pinggan_sihat", ellipse(128, 132, 120, 108, W) + ellipse(128, 132, 104, 92, C["lgrey"], sw=4)
       + path("M128,132 L128,40 A104,92 0 0 1 128,224Z", "#7CB342", sw=4) + path("M128,132 L128,40 A104,92 0 0 0 24,132Z", "#FFF3D6", sw=4) + path("M128,132 L24,132 A104,92 0 0 0 128,224Z", "#E57373", sw=4)
       + "".join(circle(x, y, 10, "#558B2F", stroke=None) for x, y in ((170, 90), (190, 130), (160, 170), (200, 170), (160, 130)))
       + "".join(ellipse(x, y, 8, 5, W, sw=2) for x, y in ((70, 100), (90, 90), (100, 110), (60, 120), (84, 120))) + ellipse(78, 170, 30, 16, "#C88A5A", sw=4),
       "Malaysian healthy plate (quarter-quarter-half)", "Pinggan Sihat Malaysia (suku-suku separuh)", ["health", "nutrition"])
    PJ("lobak_merah", path("M100,60 C130,60 160,70 160,90 L120,240 C116,248 108,248 106,240 L80,90 C80,70 90,60 100,60Z", C["orange"]) + "".join(line(92, y, 108, y + 2, sw=4) for y in (110, 150, 190))
       + "".join(path(f"M120,62 C{120 + dx},20 {140 + dx},10 {150 + dx},6", stroke=C["green"], sw=10) for dx in (-40, -10, 20)), "Carrot", "Lobak merah", ["nutrition", "vegetable"])
    PJ("brokoli", rect(110, 140, 36, 96, "#9CCC65", rx=10) + "".join(circle(x, y, r, C["dgreen"]) for x, y, r in ((80, 110, 40), (128, 80, 46), (176, 110, 40), (128, 130, 40))), "Broccoli", "Brokoli", ["nutrition", "vegetable"])
    PJ("tomato", shadow(128, 236, 80, 8) + ellipse(128, 146, 100, 84, C["red"]) + "".join(poly([(128, 70), (128 + 40 * math.cos(math.radians(a)), 70 + 16 * math.sin(math.radians(a))), (128 + 20 * math.cos(math.radians(a + 25)), 74 + 8 * math.sin(math.radians(a + 25)))], C["green"], sw=4) for a in range(0, 360, 72))
       + shine_ellipse(84, 116, 10, 22, 40, 0.5), "Tomato", "Tomato", ["nutrition", "vegetable"])
    PJ("ayam_goreng", path("M100,170 C40,170 30,90 80,60 C130,30 200,60 190,120 C184,150 150,160 130,170Z", "#C6782F") + path("M130,170 L200,226", stroke=INK, sw=24) + path("M130,170 L200,226", stroke=C["cream"], sw=14)
       + circle(206, 222, 16, C["cream"]) + circle(222, 210, 14, C["cream"]), "Fried chicken", "Ayam goreng", ["nutrition", "food"])
    PJ("nasi", shadow(128, 236, 100, 8) + path("M30,140 L226,140 C226,200 190,230 128,230 C66,230 30,200 30,140Z", C["blue"]) + path("M30,140 C30,80 226,80 226,140Z", W)
       + "".join(ellipse(x, y, 6, 3, C["lgrey"], stroke=None) for x, y in ((80, 120), (110, 104), (150, 110), (180, 124), (128, 128), (96, 136))), "Rice", "Nasi", ["nutrition", "food"])
    PJ("burger", rect(30, 160, 196, 40, "#E0A050", rx=16) + rect(26, 136, 204, 30, "#7A4A2A", rx=12) + path("M24,136 L232,136 L210,152 L190,138 L170,152 L150,138 L130,152 L110,138 L90,152 L70,138 L50,152Z", C["green"], sw=4)
       + path("M30,130 C30,60 226,60 226,130Z", "#E0A050") + "".join(ellipse(x, y, 5, 3, C["cream"], stroke=None) for x, y in ((90, 96), (128, 84), (166, 96), (110, 112), (150, 112))),
       "Burger (eat less)", "Burger (kurangkan)", ["nutrition", "junk"])
    PJ("minuman_bergas", shadow(128, 240, 50, 8) + rect(80, 40, 96, 196, C["red"], rx=14) + rect(80, 100, 96, 70, W, stroke=None) + rect(80, 40, 96, 196, "none", rx=14) + ellipse(128, 40, 48, 10, C["lgrey"])
       + path("M100,140 C120,110 140,160 160,130", stroke=C["red"], sw=8), "Fizzy drink (eat less)", "Minuman bergas (kurangkan)", ["nutrition", "junk"])
    # ======================= SENI VISUAL =======================
    SV("berus_cat", "".join(g(rect(118, 20, 20, 140, col) + rect(114, 150, 28, 24, C["lgrey"]) + path(f"M114,174 L142,174 C144,200 136,226 128,240 C120,226 112,200 114,174Z", tip), transform=f"rotate({a} 128 140)")
                            for a, col, tip in ((-20, C["wood"], C["red"]), (0, C["blue"], C["yellow"]), (20, C["green"], C["blue"]))), "Paint brushes", "Berus cat", ["tool"])
    SV("krayon", rect(20, 90, 216, 140, C["yellow"], rx=10) + "".join(path(f"M{x},90 L{x},50 L{x + 11},26 L{x + 22},50 L{x + 22},90Z", c, sw=5)
                                                                  for x, c in zip(range(34, 230, 32), (C["red"], C["orange"], C["yellow"], C["green"], C["blue"], C["purple"])))
       + rect(20, 90, 216, 40, C["green"], rx=10) + rect(40, 150, 176, 50, W, rx=8, sw=4), "Crayons", "Krayon", ["tool"])
    SV("pensel_warna", "".join(g(rect(118, 30, 20, 170, c, sw=5) + poly([(118, 200), (138, 200), (128, 232)], C["cream"], sw=5) + poly([(124, 222), (132, 222), (128, 232)], c, sw=2), transform=f"rotate({a} 128 230)")
                               for a, c in ((-24, C["red"]), (-12, C["orange"]), (0, C["yellow"]), (12, C["green"]), (24, C["blue"]))), "Coloured pencils", "Pensel warna", ["tool"])
    SV("tiub_cat", "".join(g(path("M100,40 L156,40 L150,180 L106,180Z", W) + rect(100, 40, 56, 30, c, sw=5) + rect(116, 180, 24, 20, C["dgrey"], rx=3) + path(f"M114,200 L142,200 C150,230 106,230 114,200Z", c, sw=5),
                             transform=f"translate({dx},0) rotate({a} 128 128)") for dx, a, c in ((-70, -10, C["red"]), (0, 0, C["yellow"]), (70, 10, C["blue"]))), "Paint tubes", "Tiub cat", ["tool", "colour"])
    SV("kanvas_easel", shadow(128, 240, 90, 8) + line(128, 20, 50, 240, stroke=C["dwood"], sw=12) + line(128, 20, 206, 240, stroke=C["dwood"], sw=12) + line(128, 20, 128, 240, stroke=C["dwood"], sw=10)
       + rect(40, 40, 176, 130, W) + circle(90, 90, 22, C["yellow"], sw=4) + path("M40,170 L100,110 L140,150 L170,120 L216,170Z", C["green"], sw=4) + rect(36, 170, 184, 12, C["wood"], rx=4),
       "Easel and canvas", "Kekuda dan kanvas", ["tool"])
    SV("roda_warna", "".join(path(f"M128,128 L{128 + 110 * math.cos(math.radians(a))},{128 + 110 * math.sin(math.radians(a))} A110,110 0 0 1 {128 + 110 * math.cos(math.radians(a + 30))},{128 + 110 * math.sin(math.radians(a + 30))}Z", c, sw=4)
                             for a, c in zip(range(-90, 270, 30), ("#FFD166", "#F4A100", "#FF9F1C", "#FF6B35", "#EF476F", "#C1121F", "#9B5DE5", "#5E60CE", "#3A86FF", "#2EC4B6", "#6BCB77", "#B5E48C")))
       + circle(128, 128, 30, W), "Colour wheel", "Roda warna", ["colour", "theory"])
    SV("canting", line(40, 220, 160, 100, stroke=C["wood"], sw=16) + path("M150,80 C160,60 200,60 210,80 C214,96 200,112 180,112 C164,112 150,100 150,80Z", C["gold"])
       + path("M200,104 L230,140", stroke=C["gold"], sw=6) + circle(232, 144, 5, C["dwood"], stroke=None), "Batik canting", "Canting batik", ["tool", "batik", "local"])
    SV("kain_batik", rect(10, 30, 236, 196, "#1D3557", rx=6) + "".join(path(f"M{x},{y} C{x - 20},{y - 30} {x + 20},{y - 50} {x},{y - 20} C{x + 30},{y - 50} {x + 40},{y - 10} {x},{y}Z", c, sw=3)
                                                                 for x, y, c in ((60, 110, C["red"]), (150, 90, C["yellow"]), (200, 180, C["pink"]), (90, 200, C["orange"])))
       + "".join(circle(x, y, 10, C["teal"], sw=3) for x, y in ((120, 150), (40, 160), (210, 60), (180, 130))) + "".join(path(f"M{x},210 q10,-14 20,0", stroke=C["yellow"], sw=3) for x in range(20, 236, 24)),
       "Batik cloth", "Kain batik", ["batik", "local", "pattern"])
    SV("tanah_liat", shadow(128, 236, 100, 8) + path("M40,226 C30,180 60,140 100,150 C110,120 160,120 170,150 C210,140 236,190 220,226Z", "#C9824B")
       + path("M190,90 C190,60 230,60 230,90 L224,130 L196,130Z", "#C9824B") + "".join(path(f"M{x},{y} q10,6 20,0", stroke="#9C5E30", sw=4) for x, y in ((80, 190), (130, 170), (170, 200))),
       "Modelling clay", "Tanah liat", ["material"])
    SV("gunting", circle(80, 190, 30, "none", stroke=C["red"], sw=14) + circle(80, 190, 30, "none", sw=4) + circle(176, 190, 30, "none", stroke=C["red"], sw=14)
       + poly([(104, 166), (190, 30), (200, 40), (124, 176)], C["lgrey"]) + poly([(152, 166), (66, 30), (56, 40), (132, 176)], C["lgrey"]) + circle(128, 140, 6, INK, stroke=None), "Scissors", "Gunting", ["tool"])
    SV("gam", shadow(128, 240, 50, 8) + rect(88, 80, 80, 156, W, rx=10) + rect(88, 120, 80, 70, C["orange"], stroke=None) + rect(88, 80, 80, 156, "none", rx=10) + rect(96, 30, 64, 54, C["purple"], rx=10),
       "Glue stick", "Gam", ["tool"])
    SV("origami", poly([(30, 170), (128, 120), (226, 60), (150, 160)], C["red"]) + poly([(128, 120), (90, 40), (150, 160)], L.shade(C["red"], 0.25)) + poly([(30, 170), (60, 130), (90, 150)], L.shade(C["red"], -0.2))
       + poly([(150, 160), (180, 220), (110, 168)], L.shade(C["red"], -0.2)), "Origami crane", "Origami burung", ["craft"])
    SV("kertas_warna", "".join(rect(40 + i * 14, 40 + i * 14, 160, 160, c, rx=4, extra=f'transform="rotate({i * 6 - 8} 128 128)"') for i, c in enumerate((C["blue"], C["green"], C["yellow"], C["pink"]))),
       "Coloured paper", "Kertas warna", ["material"])
    # ======================= MUZIK =======================
    MU("kompang", ellipse(128, 128, 110, 104, "#C68B59") + ellipse(128, 128, 92, 86, "#F3DFBF", sw=5) + "".join(circle(128 + 101 * math.cos(math.radians(a)), 128 + 95 * math.sin(math.radians(a)), 4, C["gold"], stroke=None) for a in range(0, 360, 20))
       + shine_ellipse(96, 96, 16, 26, 40, 0.3), "Kompang", "Kompang", ["instrument", "percussion", "local"])
    MU("gendang", shadow(128, 240, 80, 8) + path("M30,70 L226,70 L210,210 L46,210Z", "#A0522D") + ellipse(128, 70, 98, 22, "#F3DFBF") + ellipse(128, 210, 82, 16, "#F3DFBF", extra='fill-opacity="0"')
       + "".join(line(30 + i * 28, 72, 54 + i * 22, 208, stroke=C["cream"], sw=4) for i in range(7)) + "".join(line(54 + i * 22, 72, 30 + i * 28, 208, stroke=C["cream"], sw=4) for i in range(7)),
       "Gendang (Malay drum)", "Gendang", ["instrument", "percussion", "local"])
    MU("rekoder", g(rect(116, 10, 24, 220, C["cream"], rx=10) + rect(112, 10, 32, 40, C["wood"], rx=10) + rect(112, 200, 32, 40, C["wood"], rx=10)
                    + "".join(circle(128, 70 + i * 22, 6, INK, stroke=None) for i in range(6)), transform="rotate(30 128 128)"), "Recorder", "Rekoder", ["instrument", "wind"])
    MU("zilofon", shadow(128, 236, 120, 8) + line(20, 70, 236, 110, stroke=C["dwood"], sw=10) + line(20, 210, 236, 180, stroke=C["dwood"], sw=10)
       + "".join(rect(28 + i * 27, 64 + i * 5, 22, 150 - i * 10, c, rx=4, sw=4) for i, c in enumerate((C["red"], C["orange"], C["yellow"], C["green"], C["teal"], C["blue"], C["purple"], C["pink"])))
       + line(150, 30, 220, 0, sw=5) + circle(150, 30, 10, C["red"], sw=4), "Xylophone", "Zilofon", ["instrument", "percussion"])
    MU("piano", rect(10, 60, 236, 150, W, rx=6) + "".join(line(10 + i * 33.7, 60, 10 + i * 33.7, 210, sw=4) for i in range(1, 7))
       + "".join(rect(10 + i * 33.7 - 10, 60, 20, 90, INK, rx=3, stroke=None) for i in (1, 2, 4, 5, 6)) + rect(10, 40, 236, 24, C["red"], rx=6), "Piano keys", "Kekunci piano", ["instrument", "keyboard"])
    MU("gitar", g(path("M128,250 C60,250 50,180 90,160 C70,130 90,100 128,100 C166,100 186,130 166,160 C206,180 196,250 128,250Z", C["orange"]) + circle(128, 182, 20, INK, stroke=None)
                  + rect(118, 10, 20, 150, C["dwood"]) + rect(112, 0, 32, 26, C["dwood"], rx=4) + rect(108, 214, 40, 10, C["dwood"], rx=3) + "".join(line(124 + k * 3, 20, 124 + k * 3, 220, stroke=C["lgrey"], sw=1.5) for k in range(3)),
                  transform="rotate(25 128 128) scale(0.9) translate(14,10)"), "Guitar", "Gitar", ["instrument", "string"])
    MU("sape", g(path("M128,20 C160,20 170,40 166,70 L166,220 C166,240 90,240 90,220 L90,70 C86,40 96,20 128,20Z", "#C1121F")
                 + "".join(path(f"M96,{y} q32,-12 64,0", stroke=W, sw=4) for y in (90, 130, 170, 210)) + rect(116, -20, 24, 50, C["dwood"]) + line(122, 0, 122, 220, stroke=C["lgrey"], sw=2) + line(134, 0, 134, 220, stroke=C["lgrey"], sw=2),
                 transform="rotate(20 128 128) scale(0.92) translate(10,20)"), "Sape (Sarawak lute)", "Sape", ["instrument", "string", "local"])
    MU("marakas", "".join(g(rect(122, 130, 14, 110, C["wood"], rx=6) + ellipse(128, 90, 46, 56, c) + "".join(circle(128 + dx, 90 + dy, 6, W, stroke=None) for dx, dy in ((-16, -20), (14, -6), (-8, 20))),
                            transform=f"rotate({a} 128 230)") for a, c in ((-22, C["red"]), (22, C["yellow"]))), "Maracas", "Marakas", ["instrument", "percussion"])
    MU("tamborin", circle(128, 128, 100, "none", stroke=INK, sw=36) + circle(128, 128, 100, "none", stroke=C["wood"], sw=24) + circle(128, 128, 88, "#F3DFBF")
       + "".join(ellipse(128 + 100 * math.cos(math.radians(a)), 128 + 100 * math.sin(math.radians(a)), 12, 6, C["gold"], sw=3, extra=f'transform="rotate({a + 90} {128 + 100 * math.cos(math.radians(a)):.1f} {128 + 100 * math.sin(math.radians(a)):.1f})"') for a in range(0, 360, 45)),
       "Tambourine", "Tamborin", ["instrument", "percussion"])
    MU("segi_tiga", line(128, 14, 128, 40, stroke=C["red"], sw=4) + polyline([(108, 52), (128, 40), (220, 210), (30, 210), (114, 60)], stroke=C["lgrey"], sw=10)
       + polyline([(108, 52), (128, 40), (220, 210), (30, 210), (114, 60)], stroke=INK, sw=2) + line(190, 120, 120, 170, stroke=C["grey"], sw=6), "Triangle", "Segi tiga (alat muzik)", ["instrument", "percussion"])
    MU("angklung", rect(30, 220, 196, 20, C["wood"], rx=4) + rect(30, 20, 14, 220, C["wood"]) + rect(212, 20, 14, 220, C["wood"]) + rect(30, 20, 196, 14, C["wood"])
       + "".join(rect(x, y, 32, 220 - y - 10, "#D8C27A", rx=8, sw=5) + line(x + 2, y + 30, x + 30, y + 30, sw=3) for x, y in ((64, 40), (110, 70), (156, 100))), "Angklung", "Angklung", ["instrument", "local"])
    # notation (stems up; heads at the bottom so they sit on a staff built in Godot)
    def note(flags=0, filled=True, stem=True):
        b = ellipse(110, 196, 34, 24, INK if filled else W, sw=8, extra='transform="rotate(-20 110 196)"')
        if stem:
            b += line(140, 190, 140, 40, sw=9)
        for k in range(flags):
            b += path(f"M140,{40 + k * 34} C170,{60 + k * 34} 196,{80 + k * 34} 176,{130 + k * 34}", stroke=INK, sw=9)
        return b
    MU("not_semibreve", note(0, False, False), "Whole note (semibreve)", "Semibrif", ["notation"])
    MU("not_minim", note(0, False), "Half note (minim)", "Minim", ["notation"])
    MU("not_krocet", note(0, True), "Quarter note (crotchet)", "Krocet", ["notation"])
    MU("not_kuaver", note(1, True), "Eighth note (quaver)", "Kuaver", ["notation"])
    MU("not_semikuaver", note(2, True), "Sixteenth note (semiquaver)", "Semikuaver", ["notation"])
    MU("not_kuaver_berpasangan", ellipse(70, 200, 30, 22, INK, extra='transform="rotate(-20 70 200)"') + ellipse(180, 200, 30, 22, INK, extra='transform="rotate(-20 180 200)"')
       + line(96, 194, 96, 50, sw=9) + line(206, 194, 206, 50, sw=9) + poly([(92, 40), (210, 40), (210, 64), (92, 64)], INK, stroke=None), "Beamed quavers", "Kuaver berpasangan", ["notation"])
    MU("klef_trebel", path("M140,236 C110,240 100,214 120,206 C136,200 146,220 134,228 M132,236 L120,30 C118,10 150,6 150,34 C150,70 70,100 70,160 C70,200 110,214 140,200 C176,184 170,130 130,130 C100,130 96,170 120,176",
                           stroke=INK, sw=10), "Treble clef", "Klef trebel", ["notation"])
    MU("baluk_krocet", path("M110,40 L150,90 C130,110 130,130 152,160 C120,150 100,170 124,210 C90,190 92,150 128,150 L100,110 C120,90 120,70 110,40Z", INK, sw=3), "Crotchet rest", "Tanda rehat krocet", ["notation"])
    # ======================= SEJARAH =======================
    stripes = "".join(rect(0, i * 256 / 14 * 0.75 + 16, 384, 256 / 14 * 0.75, C["dred"] if i % 2 == 0 else W, stroke=None) for i in range(14))
    SJ("jalur_gemilang", rect(0, 16, 384, 192, W, stroke=None) + stripes + rect(0, 16, 192, 8 * 192 / 14, "#010066", stroke=None)
       + crescent(82, 71, 42, "#FFCC00", sw=0.01) + poly(star_pts(140, 71, 36, 15, 14), "#FFCC00", stroke=None)
       + rect(0, 16, 384, 192, "none", sw=6), "Malaysian flag (Jalur Gemilang)", "Jalur Gemilang", ["national", "symbol"], w=384, h=224)
    SJ("bunga_raya", "".join(path(f"M128,128 C{128 + 40 * math.cos(math.radians(a - 30))},{128 + 40 * math.sin(math.radians(a - 30))} {128 + 110 * math.cos(math.radians(a - 25))},{128 + 110 * math.sin(math.radians(a - 25))} {128 + 108 * math.cos(math.radians(a))},{128 + 108 * math.sin(math.radians(a))} C{128 + 110 * math.cos(math.radians(a + 25))},{128 + 110 * math.sin(math.radians(a + 25))} {128 + 40 * math.cos(math.radians(a + 30))},{128 + 40 * math.sin(math.radians(a + 30))} 128,128Z", C["dred"])
                             for a in range(-90, 270, 72)) + circle(128, 128, 22, "#8B0000", sw=4) + path("M128,128 C150,100 170,70 186,50", stroke=C["yellow"], sw=6)
       + "".join(circle(186 + dx, 50 + dy, 5, C["yellow"], sw=2) for dx, dy in ((0, 0), (-10, 6), (8, 10), (-4, -10))), "Hibiscus (national flower)", "Bunga raya", ["national", "symbol", "flower"])
    SJ("keris", g(path("M128,10 C140,40 116,60 128,80 C140,100 116,120 128,140 C140,160 120,180 128,196 L120,196 C112,180 132,160 120,140 C108,120 132,100 120,80 C108,60 132,40 128,10Z", C["lgrey"], sw=5)
                  + path("M96,196 L156,196 C150,210 104,210 96,196Z", C["gold"], sw=5) + path("M118,206 L138,206 C150,230 140,250 118,248 C112,240 120,226 118,206Z", C["dwood"], sw=5),
                  transform="rotate(30 128 128)"), "Keris", "Keris", ["heritage", "weapon"])
    SJ("tengkolok", shadow(128, 220, 100, 8) + path("M30,180 C30,120 80,90 128,90 C176,90 226,120 226,180Z", C["gold"]) + path("M128,90 L170,20 L196,120Z", C["gold"])
       + "".join(path(f"M40,{y} C90,{y - 16} 166,{y - 16} 216,{y}", stroke=L.shade(C["gold"], -0.3), sw=4) for y in (140, 160)) + path("M30,180 C70,196 186,196 226,180", stroke=INK, sw=7),
       "Tengkolok (royal headgear)", "Tengkolok", ["heritage", "clothing"])
    SJ("mahkota", shadow(128, 228, 100, 8) + path("M30,200 L20,80 L76,130 L128,50 L180,130 L236,80 L226,200Z", C["yellow"]) + rect(30, 186, 196, 30, C["gold"], rx=6)
       + "".join(circle(x, y, 10, c, sw=4) for x, y, c in ((20, 76, C["red"]), (128, 46, C["blue"]), (236, 76, C["red"]), (80, 200, C["teal"]), (128, 200, C["red"]), (176, 200, C["teal"]))), "Crown", "Mahkota", ["heritage", "royal"])
    SJ("kapal_layar", path("M0,214 C40,204 60,224 100,214 C140,204 160,224 200,214 C230,206 250,220 256,218 L256,256 L0,256Z", C["blue"], stroke=None, extra='fill-opacity="0.5"')
       + path("M14,170 L242,160 C226,206 190,216 128,216 C66,216 30,206 14,170Z", C["dwood"]) + line(110, 170, 110, 20, stroke=C["dwood"], sw=8) + line(180, 166, 180, 60, stroke=C["dwood"], sw=6)
       + path("M114,28 C170,50 170,130 114,150Z", C["cream"]) + path("M106,40 C60,60 50,130 106,150Z", C["cream"]) + path("M184,66 C220,90 220,140 184,150Z", C["cream"]) + path("M110,20 L140,26 L110,32Z", C["red"], sw=3),
       "Sailing ship (Melaka era)", "Kapal layar", ["heritage", "trade", "melaka"])
    SJ("meriam", shadow(128, 236, 100, 8) + g(rect(30, 90, 170, 50, C["dgrey"], rx=20) + rect(186, 82, 30, 66, C["dgrey"], rx=8) + circle(30, 115, 18, C["dgrey"]), transform="rotate(-12 128 128)")
       + circle(100, 180, 40, C["wood"]) + circle(100, 180, 12, C["dwood"]) + "".join(line(100, 180, 100 + 36 * math.cos(math.radians(a)), 180 + 36 * math.sin(math.radians(a)), stroke=C["dwood"], sw=5) for a in range(0, 360, 60))
       + circle(220, 210, 14, INK, stroke=None) + circle(236, 214, 12, INK, stroke=None), "Cannon", "Meriam", ["heritage"])
    SJ("kota_lama", shadow(128, 240, 120, 8) + rect(20, 70, 216, 166, "#B9A88C") + "".join(rect(20 + i * 44, 46, 28, 28, "#B9A88C") for i in range(5))
       + path("M90,236 L90,150 C90,110 166,110 166,150 L166,236Z", C["black"]) + "".join(line(20, y, 236, y, stroke="#9C8B6E", sw=3) for y in (100, 130, 160, 190, 220))
       + rect(110, 84, 36, 24, C["cream"], sw=4), "Old fort gate", "Pintu kota lama", ["heritage", "melaka"])
    SJ("manuskrip", path("M40,40 L216,40 L216,216 L40,216Z", C["cream"]) + rect(20, 26, 216, 28, C["wood"], rx=14) + rect(20, 204, 216, 28, C["wood"], rx=14)
       + "".join(path(f"M60,{y} q20,-6 40,0 q20,6 40,0 q20,-6 40,0", stroke=C["dgrey"], sw=4) for y in (80, 110, 140, 170)), "Old manuscript", "Manuskrip", ["heritage", "writing"])
    SJ("pokok_getah", shadow(128, 240, 90, 8) + rect(100, 60, 56, 180, C["wood"]) + path("M104,90 L150,120 M104,120 L150,150 M104,150 L150,180", stroke=W, sw=5)
       + path("M100,60 C40,60 20,20 70,6 C100,-4 156,-4 186,6 C236,20 216,60 156,60Z", C["green"]) + path("M150,184 L160,184 L156,214 L170,230 L140,230 L152,214Z", W, sw=4)
       + rect(140, 200, 30, 30, C["lgrey"], rx=6, sw=4), "Rubber tree tapping", "Menoreh getah", ["economy", "history"])
    SJ("dulang_bijih_timah", ellipse(128, 160, 120, 46, C["wood"]) + ellipse(128, 150, 100, 32, "#7A5230") + "".join(circle(128 + dx, 150 + dy, 5, C["lgrey"], sw=2) for dx, dy in ((-30, -4), (10, 6), (40, -6), (-6, -10), (24, 10)))
       + path("M20,110 C40,80 60,90 70,100", stroke=C["blue"], sw=6), "Tin panning tray (dulang)", "Dulang bijih timah", ["economy", "history"])
    SJ("peta_lama", rect(20, 30, 216, 196, C["cream"], rx=6) + path("M40,90 C70,60 120,80 130,110 C140,140 110,170 80,160 C50,150 30,120 40,90Z", C["green"], sw=4)
       + path("M150,120 C170,100 210,110 214,140 C218,170 190,190 170,180Z", C["green"], sw=4) + path("M60,200 C90,180 140,200 170,190", stroke=C["red"], sw=4, extra='stroke-dasharray="6 6"')
       + poly(star_pts(200, 60, 18, 7, 4), C["gold"], sw=3), "Old map", "Peta lama", ["geography", "history"])
    # ======================= RBT =======================
    RB("tukul", g(rect(118, 80, 20, 160, C["wood"], rx=6) + path("M70,40 L190,40 C200,40 206,50 206,58 L206,82 L60,82 L60,52Z", C["dgrey"]) + path("M60,52 L30,40 L30,90 L60,82", C["dgrey"]), transform="rotate(-30 128 128)"),
       "Hammer", "Tukul", ["tool"])
    RB("pemutar_skru", g(rect(110, 20, 36, 100, C["red"], rx=14) + rect(122, 120, 12, 110, C["lgrey"]) + poly([(122, 230), (134, 230), (128, 246)], C["lgrey"], sw=4), transform="rotate(35 128 128)"),
       "Screwdriver", "Pemutar skru", ["tool"])
    RB("gergaji", g(path("M40,90 L226,110 L226,150 L40,170Z", C["lgrey"]) + "".join(poly([(50 + i * 18, 170 - i * 1.0), (59 + i * 18, 184 - i * 1.0), (68 + i * 18, 168 - i * 1.0)], C["lgrey"], sw=3) for i in range(10))
                    + path("M200,80 L250,80 L250,180 L200,180 C210,150 210,110 200,80Z", C["orange"]) + rect(212, 110, 24, 40, W, rx=8, sw=4), transform="rotate(-10 128 128)"), "Saw", "Gergaji", ["tool"])
    RB("playar", g(path("M110,130 L80,250", stroke=INK, sw=26) + path("M110,130 L80,250", stroke=C["blue"], sw=16) + path("M146,130 L176,250", stroke=INK, sw=26) + path("M146,130 L176,250", stroke=C["blue"], sw=16)
                   + path("M110,130 L118,20 L138,20 L146,130Z", C["lgrey"]) + circle(128, 130, 14, C["dgrey"])), "Pliers", "Playar", ["tool"])
    RB("sepana", g(rect(116, 70, 24, 170, C["lgrey"], rx=10) + path("M90,30 C90,90 166,90 166,30 L148,30 L148,56 L108,56 L108,30Z", C["lgrey"]), transform="rotate(30 128 128)"), "Spanner", "Sepana", ["tool"])
    RB("gear", poly([(128 + (104 if (i % 4) in (1, 2) else 82) * math.cos(math.radians(i * 7.5)), 128 + (104 if (i % 4) in (1, 2) else 82) * math.sin(math.radians(i * 7.5))) for i in range(48)], C["grey"])
       + circle(128, 128, 40, C["lgrey"]) + circle(128, 128, 16, C["dgrey"]), "Gear", "Gear", ["mechanism"])
    RB("led", line(110, 160, 110, 246, stroke=C["grey"], sw=6) + path("M146,160 L146,210 L160,230", stroke=C["grey"], sw=6) + rect(80, 150, 96, 16, C["red"], rx=4)
       + path("M86,150 L86,80 A42,42 0 0 1 170,80 L170,150Z", C["red"]) + shine_ellipse(108, 80, 8, 24, 0, 0.6)
       + "".join(line(128 + 70 * math.cos(math.radians(a)), 70 + 70 * math.sin(math.radians(a)), 128 + 92 * math.cos(math.radians(a)), 70 + 92 * math.sin(math.radians(a)), stroke=C["orange"], sw=5) for a in (-160, -120, -60, -20)),
       "LED", "LED", ["electronics"])
    RB("perintang", line(10, 128, 246, 128, stroke=C["grey"], sw=6) + path("M60,104 C60,90 90,90 96,100 L160,100 C166,90 196,90 196,104 L196,152 C196,166 166,166 160,156 L96,156 C90,166 60,166 60,152Z", "#E8D3A8")
       + "".join(rect(x, 98, 10, 60, c, stroke=None) for x, c in ((84, C["brown"]), (112, C["black"]), (136, C["red"]), (172, C["gold"]))), "Resistor", "Perintang", ["electronics"])
    RB("suis", rect(30, 150, 196, 60, C["lgrey"], rx=10) + circle(70, 150, 12, C["dgrey"]) + circle(186, 150, 12, C["dgrey"]) + line(70, 150, 170, 100, sw=10) + circle(170, 100, 8, C["red"], sw=4),
       "Switch", "Suis", ["electronics"])
    RB("motor", rect(40, 70, 140, 120, C["lgrey"], rx=20) + rect(40, 70, 40, 120, C["orange"], rx=14) + rect(180, 120, 60, 20, C["grey"], rx=4) + line(60, 190, 60, 236, stroke=C["red"], sw=6)
       + line(100, 190, 100, 236, stroke=C["black"], sw=6), "Electric motor", "Motor elektrik", ["electronics"])
    RB("litar", rect(30, 40, 196, 176, "none", rx=10, stroke=C["red"], sw=8) + rect(80, 196, 96, 40, C["dgrey"], rx=6) + rect(176, 206, 10, 20, C["grey"]) + circle(128, 40, 26, C["yellow"])
       + line(30, 128, 10, 128, sw=0.1) + rect(10, 110, 40, 36, C["lgrey"], rx=6) + line(18, 128, 42, 118, sw=5), "Simple circuit", "Litar ringkas", ["electronics"])
    RB("papan_mikropengawal", rect(20, 50, 216, 156, C["dgreen"], rx=12) + rect(90, 100, 76, 56, C["black"], rx=4) + "".join(rect(94 + i * 12, 92, 6, 8, C["lgrey"], stroke=None) + rect(94 + i * 12, 156, 6, 8, C["lgrey"], stroke=None) for i in range(6))
       + "".join(circle(40 + i * 22, 190, 7, C["gold"], sw=3) for i in range(9)) + rect(30, 64, 30, 20, C["lgrey"], rx=3, sw=4) + "".join(circle(200 + (i % 2) * 14, 76 + (i // 2) * 14, 4, C["red"], stroke=None) for i in range(6)),
       "Microcontroller board", "Papan mikropengawal", ["electronics", "coding"])
    RB("robot", shadow(128, 240, 80, 8) + rect(70, 140, 116, 90, C["lgrey"], rx=16) + rect(96, 160, 64, 36, C["sky"], rx=6, sw=5) + rect(56, 150, 18, 60, C["grey"], rx=8) + rect(182, 150, 18, 60, C["grey"], rx=8)
       + rect(60, 40, 136, 96, W, rx=24) + circle(102, 88, 16, C["teal"]) + circle(154, 88, 16, C["teal"]) + rect(108, 112, 40, 8, INK, rx=4, stroke=None) + line(128, 40, 128, 14, sw=5) + circle(128, 12, 9, C["red"], sw=4),
       "Robot", "Robot", ["coding", "robotics"])
    blk = lambda y, col, w=180, cap=False: path(f"M40,{y} {'C40,' + str(y - 24) + ' 110,' + str(y - 24) + ' 110,' + str(y) if cap else 'L64,' + str(y) + ' L70,' + str(y + 8) + ' L94,' + str(y + 8) + ' L100,' + str(y)} L{40 + w},{y} L{40 + w},{y + 40} L100,{y + 40} L94,{y + 48} L70,{y + 48} L64,{y + 40} L40,{y + 40}Z", col)
    RB("kod_blok", blk(40, C["yellow"], cap=True) + blk(84, C["blue"]) + blk(128, C["purple"]) + blk(172, C["green"], 140)
       + "".join(rect(60, y + 14, w, 12, W, rx=6, stroke=None, extra='fill-opacity="0.8"') for y, w in ((40, 120), (84, 100), (128, 140), (172, 80))), "Block code", "Kod blok", ["coding"])
    RB("komputer_riba", path("M50,40 L206,40 C214,40 220,46 220,54 L220,170 L36,170 L36,54 C36,46 42,40 50,40Z", C["dgrey"]) + rect(50, 54, 156, 104, C["navy"], sw=4)
       + "".join(rect(64, 70 + i * 20, w, 8, c, rx=4, stroke=None) for i, (w, c) in enumerate(((60, C["pink"]), (100, C["sky"]), (80, C["yellow"]), (40, C["green"]))))
       + path("M14,170 L242,170 L230,200 L26,200Z", C["lgrey"]), "Laptop with code", "Komputer riba", ["coding"])
    RB("jarum_benang", path("M200,20 L60,230", stroke=C["lgrey"], sw=8) + ellipse(196, 28, 4, 10, W, sw=3, extra='transform="rotate(35 196 28)"')
       + path("M196,28 C230,60 180,120 120,110 C60,100 40,150 80,180", stroke=C["red"], sw=5) + circle(70, 200, 42, C["red"]) + "".join(path(f"M34,{y} Q70,{y - 14} 106,{y}", stroke=L.shade(C["red"], -0.3), sw=4) for y in (186, 200, 214)),
       "Needle and thread", "Jarum dan benang", ["sewing"])
    RB("butang_baju", "".join(circle(x, y, r, c) + "".join(circle(x + dx * r * 0.25, y + dy * r * 0.25, r * 0.12, INK, stroke=None) for dx in (-1, 1) for dy in (-1, 1))
                              for x, y, r, c in ((80, 90, 56, C["blue"]), (176, 110, 46, C["pink"]), (120, 190, 40, C["yellow"]))), "Buttons", "Butang", ["sewing"])
    RB("penyiram", path("M60,100 L170,100 L180,210 L50,210Z", C["green"]) + path("M170,130 L240,70", stroke=INK, sw=20) + path("M170,130 L240,70", stroke=C["green"], sw=10) + ellipse(242, 66, 10, 14, C["dgreen"], extra='transform="rotate(-40 242 66)"')
       + path("M60,110 C10,110 10,190 54,190", stroke=INK, sw=8), "Watering can", "Penyiram", ["agriculture"])
    RB("cangkul", line(60, 240, 170, 40, stroke=C["wood"], sw=14) + path("M150,40 L230,20 L240,70 C210,90 180,80 170,60Z", C["grey"]), "Hoe", "Cangkul", ["agriculture"])
    RB("penyodok", line(128, 20, 128, 160, stroke=C["wood"], sw=14) + rect(100, 10, 56, 18, C["wood"], rx=8) + path("M80,150 L176,150 L176,200 C176,236 128,250 128,250 C128,250 80,236 80,200Z", C["grey"]),
       "Spade", "Penyodok", ["agriculture"])
    RB("polibeg_anak_benih", shadow(128, 240, 70, 8) + path("M60,120 L196,120 L186,236 L70,236Z", C["black"]) + ellipse(128, 120, 68, 12, C["dwood"])
       + path("M128,120 L128,60", stroke=C["dgreen"], sw=8) + path("M128,80 C100,80 86,56 92,40 C116,40 128,60 128,80Z", C["green"]) + path("M128,70 C156,70 170,46 164,30 C140,30 128,50 128,70Z", C["green"])
       + "".join(circle(x, 200, 4, C["dgrey"], stroke=None) for x in (90, 128, 166)), "Seedling in polybag", "Anak benih dalam polibeg", ["agriculture"])
    RB("lakaran_reka_bentuk", rect(30, 20, 196, 220, W, rx=6) + "".join(line(30, y, 226, y, stroke=C["sky"], sw=1.5) for y in range(40, 240, 16)) + "".join(line(x, 20, x, 240, stroke=C["sky"], sw=1.5) for x in range(46, 226, 16))
       + rect(70, 80, 100, 70, "none", sw=4, stroke=C["blue"]) + poly([(70, 80), (100, 56), (200, 56), (170, 80)], "none", sw=4, stroke=C["blue"]) + line(170, 150, 200, 126, sw=4, stroke=C["blue"]) + line(200, 56, 200, 126, sw=4, stroke=C["blue"])
       + g(rect(150, 170, 16, 70, C["yellow"], sw=4) + poly([(150, 240), (166, 240), (158, 254)], C["cream"], sw=3), transform="rotate(-30 158 210)"), "Design sketch", "Lakaran reka bentuk", ["design"])


if __name__ == "__main__":
    main()
    print(len(L._manifest), "subject assets")
