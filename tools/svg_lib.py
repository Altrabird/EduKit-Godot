"""Tiny SVG toolkit shared by every art generator.

House style: flat fills, one dark ink outline, a soft white highlight and a
ground shadow. Every asset goes through `save()` so the manifest (used by the
gallery, the vocab data and docs) can never drift from the files on disk.
"""
import json, math, os

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ART = os.path.join(ROOT, "assets", "art")

INK = "#2B2D42"
C = {
    "ink": INK, "white": "#FFFFFF", "paper": "#FDFCF7", "cream": "#FFF3D6",
    "blue": "#3A86FF", "navy": "#1D3557", "sky": "#8ECAE6", "teal": "#2EC4B6",
    "green": "#6BCB77", "dgreen": "#2D936C", "lime": "#B5E48C", "yellow": "#FFD166",
    "gold": "#F4A100", "orange": "#FF9F1C", "red": "#EF476F", "dred": "#C1121F",
    "purple": "#9B5DE5", "pink": "#F15BB5", "brown": "#A0663F", "wood": "#C68B59",
    "dwood": "#7A4A2A", "grey": "#ADB5BD", "lgrey": "#DEE2E6", "dgrey": "#6C757D",
    "chalk": "#2F5D50", "black": "#22223B", "skin1": "#FFDBB4", "skin2": "#E8B48A",
    "skin3": "#C68642", "skin4": "#8D5524", "glass": "#D7F3FF",
}
SKINS = [C["skin1"], C["skin2"], C["skin3"], C["skin4"]]

_manifest = []


def shade(hexc, f):
    """f<0 darkens, f>0 lightens (towards white)."""
    h = hexc.lstrip("#")
    r, g, b = (int(h[i:i + 2], 16) for i in (0, 2, 4))
    if f < 0:
        r, g, b = (int(v * (1 + f)) for v in (r, g, b))
    else:
        r, g, b = (int(v + (255 - v) * f) for v in (r, g, b))
    return "#%02X%02X%02X" % (r, g, b)


def _st(fill, stroke, sw, extra):
    s = f'fill="{fill}"'
    if stroke:
        s += f' stroke="{stroke}" stroke-width="{sw}" stroke-linejoin="round" stroke-linecap="round"'
    return s + (" " + extra if extra else "")


# Default stroke width; generators set this per canvas size.
SW = 5


def circle(cx, cy, r, fill, stroke=INK, sw=None, extra=""):
    return f'<circle cx="{cx:.2f}" cy="{cy:.2f}" r="{r:.2f}" {_st(fill, stroke, sw or SW, extra)}/>'


def ellipse(cx, cy, rx, ry, fill, stroke=INK, sw=None, extra=""):
    return f'<ellipse cx="{cx:.2f}" cy="{cy:.2f}" rx="{rx:.2f}" ry="{ry:.2f}" {_st(fill, stroke, sw or SW, extra)}/>'


def rect(x, y, w, h, fill, rx=0, stroke=INK, sw=None, extra=""):
    return f'<rect x="{x:.2f}" y="{y:.2f}" width="{w:.2f}" height="{h:.2f}" rx="{rx}" {_st(fill, stroke, sw or SW, extra)}/>'


def path(d, fill="none", stroke=INK, sw=None, extra=""):
    return f'<path d="{d}" {_st(fill, stroke, sw or SW, extra)}/>'


def poly(pts, fill, stroke=INK, sw=None, extra=""):
    p = " ".join(f"{x:.2f},{y:.2f}" for x, y in pts)
    return f'<polygon points="{p}" {_st(fill, stroke, sw or SW, extra)}/>'


def line(x1, y1, x2, y2, stroke=INK, sw=None, extra=""):
    return f'<line x1="{x1:.2f}" y1="{y1:.2f}" x2="{x2:.2f}" y2="{y2:.2f}" stroke="{stroke}" stroke-width="{sw or SW}" stroke-linecap="round" {extra}/>'


def polyline(pts, stroke=INK, sw=None, fill="none", extra=""):
    p = " ".join(f"{x:.2f},{y:.2f}" for x, y in pts)
    return f'<polyline points="{p}" {_st(fill, stroke, sw or SW, extra)}/>'


def g(*children, transform="", extra=""):
    t = f' transform="{transform}"' if transform else ""
    e = f" {extra}" if extra else ""
    return f"<g{t}{e}>" + "".join(children) + "</g>"


def star_pts(cx, cy, ro, ri, n=5, rot=-90):
    pts = []
    for i in range(n * 2):
        r = ro if i % 2 == 0 else ri
        a = math.radians(rot + i * 180 / n)
        pts.append((cx + r * math.cos(a), cy + r * math.sin(a)))
    return pts


def ngon(cx, cy, r, n, rot=-90):
    return [(cx + r * math.cos(math.radians(rot + i * 360 / n)),
             cy + r * math.sin(math.radians(rot + i * 360 / n))) for i in range(n)]


def shadow(cx, cy, rx, ry, op=0.18):
    return ellipse(cx, cy, rx, ry, "#000000", stroke=None, extra=f'fill-opacity="{op}"')


def shine(d_or_shape, op=0.45):
    """White translucent highlight. Accepts an SVG path 'd' string."""
    return path(d_or_shape, "#FFFFFF", stroke=None, extra=f'fill-opacity="{op}"')


def shine_ellipse(cx, cy, rx, ry, rot=0, op=0.45):
    return ellipse(cx, cy, rx, ry, "#FFFFFF", stroke=None,
                   extra=f'fill-opacity="{op}" transform="rotate({rot} {cx} {cy})"')


def arc_d(cx, cy, r, a0, a1):
    """Path data for an arc from angle a0 to a1 (degrees, 0 = right, clockwise)."""
    x0, y0 = cx + r * math.cos(math.radians(a0)), cy + r * math.sin(math.radians(a0))
    x1, y1 = cx + r * math.cos(math.radians(a1)), cy + r * math.sin(math.radians(a1))
    large = 1 if (a1 - a0) % 360 > 180 else 0
    return f"M{x0:.2f},{y0:.2f} A{r},{r} 0 {large} 1 {x1:.2f},{y1:.2f}"


def lgrad(gid, stops, x1=0, y1=0, x2=0, y2=1):
    s = "".join(f'<stop offset="{o}" stop-color="{c}"/>' for o, c in stops)
    return f'<linearGradient id="{gid}" x1="{x1}" y1="{y1}" x2="{x2}" y2="{y2}">{s}</linearGradient>'


def rgrad(gid, stops, cx=0.5, cy=0.5, r=0.5):
    s = "".join(f'<stop offset="{o}" stop-color="{c}" stop-opacity="{a}"/>' for o, c, a in stops)
    return f'<radialGradient id="{gid}" cx="{cx}" cy="{cy}" r="{r}">{s}</radialGradient>'


def doc(w, h, body, scale=2, defs=""):
    d = f"<defs>{defs}</defs>" if defs else ""
    return (f'<svg xmlns="http://www.w3.org/2000/svg" width="{int(w * scale)}" height="{int(h * scale)}" '
            f'viewBox="0 0 {w} {h}">{d}{body}</svg>')


def save(category, name, svg, en="", bm="", tags=()):
    folder = os.path.join(ART, category)
    os.makedirs(folder, exist_ok=True)
    with open(os.path.join(folder, name + ".svg"), "w", encoding="utf-8") as f:
        f.write(svg)
    entry = {"id": name, "category": category, "path": f"res://assets/art/{category}/{name}.svg",
             "en": en or name.replace("_", " ").title(), "bm": bm, "tags": list(tags)}
    if category.startswith("subjects/"):
        entry["subject"] = category.split("/", 1)[1]
    _manifest.append(entry)


def write_manifest(extra=()):
    items = sorted(_manifest + list(extra), key=lambda e: (e["category"], e["id"]))
    with open(os.path.join(ART, "manifest.json"), "w", encoding="utf-8") as f:
        json.dump(items, f, ensure_ascii=False, indent=1)
    return len(items)
