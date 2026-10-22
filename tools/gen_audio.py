"""Synthesised SFX (WAV) and music loops (OGG via ffmpeg). No samples, no licences.
Music loops are an exact whole number of bars so they loop seamlessly
(kit/autoload/audio.gd sets loop=true on them)."""
import json, math, os, subprocess, wave
import numpy as np

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SFX = os.path.join(ROOT, "assets", "audio", "sfx")
MUS = os.path.join(ROOT, "assets", "audio", "music")
SR = 44100
rng = np.random.default_rng(7)


def t(d):
    return np.arange(int(SR * d)) / SR


def osc(freq, d, kind="sine", duty=0.5):
    """freq may be a scalar or an array (for sweeps)."""
    n = int(SR * d)
    f = np.broadcast_to(np.asarray(freq, dtype=float), (n,)) if np.ndim(freq) else np.full(n, float(freq))
    ph = np.cumsum(f) / SR
    if kind == "sine":
        return np.sin(2 * np.pi * ph)
    if kind == "square":
        return np.where((ph % 1) < duty, 1.0, -1.0) * 0.6
    if kind == "tri":
        return 2 * np.abs(2 * (ph % 1) - 1) - 1
    if kind == "saw":
        return (2 * (ph % 1) - 1) * 0.6
    raise ValueError(kind)


def noise(d):
    return rng.uniform(-1, 1, int(SR * d))


def env(n, a=0.005, dcy=0.1, s=0.0, r=0.05, total=None):
    """ADSR over n samples; s is sustain level (0 = pluck)."""
    a_n, d_n, r_n = int(a * SR), int(dcy * SR), int(r * SR)
    s_n = max(0, n - a_n - d_n - r_n)
    e = np.concatenate([np.linspace(0, 1, max(a_n, 1)), np.linspace(1, s, max(d_n, 1)), np.full(s_n, s), np.linspace(s, 0, max(r_n, 1))])
    e = np.pad(e, (0, max(0, n - len(e))))[:n]
    return e


def lowpass(x, cutoff):
    a = math.exp(-2 * math.pi * cutoff / SR)
    y = np.empty_like(x)
    acc = 0.0
    for i, v in enumerate(x):  # small buffers only; fine for SFX
        acc = (1 - a) * v + a * acc
        y[i] = acc
    return y


def note(f, d, kind="sine", a=0.005, dcy=0.12, s=0.3, r=0.08, vib=0.0, duty=0.5):
    tt = t(d)
    freq = f * (1 + vib * np.sin(2 * np.pi * 5.5 * tt))
    return osc(freq, d, kind, duty) * env(len(tt), a, dcy, s, r)


def bell(f, d, bright=1.0):
    tt = t(d)
    x = sum(w * np.sin(2 * np.pi * f * m * tt) * np.exp(-tt * k) for m, w, k in ((1, 1, 3), (2.0, 0.5 * bright, 5), (3.01, 0.25 * bright, 8), (4.2, 0.12 * bright, 12)))
    return x * env(len(tt), 0.002, d, 0, 0.01)


def seq(*parts, gap=0.0):
    out = []
    for p in parts:
        out.append(p)
        if gap:
            out.append(np.zeros(int(SR * gap)))
    return np.concatenate(out)


def mix(*tracks):
    n = max(len(x) for x in tracks)
    return sum(np.pad(x, (0, n - len(x))) for x in tracks)


def at(x, start, total):
    out = np.zeros(int(SR * total))
    s = int(SR * start)
    out[s:s + len(x)] += x[:len(out) - s]
    return out


def save_wav(path, x, peak=0.85):
    x = np.asarray(x, dtype=float)
    m = np.max(np.abs(x)) or 1
    x = x / m * peak
    fade = min(len(x), int(0.004 * SR))
    x[-fade:] *= np.linspace(1, 0, fade)
    with wave.open(path, "wb") as w:
        w.setnchannels(1); w.setsampwidth(2); w.setframerate(SR)
        w.writeframes((x * 32767).astype(np.int16).tobytes())


N = {n: 440 * 2 ** ((i - 9) / 12) for i, n in enumerate(["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"])}


def hz(name):
    """'C5', 'F#4' -> Hz."""
    p, o = name[:-1], int(name[-1])
    return N[p] * 2 ** (o - 4)


def sfx():
    os.makedirs(SFX, exist_ok=True)
    S = {}
    S["ui_click"] = note(1200, 0.05, "sine", dcy=0.04, s=0) + 0.3 * noise(0.05) * env(int(SR * 0.05), 0.001, 0.01, 0, 0.01)
    S["ui_hover"] = note(1800, 0.04, "sine", dcy=0.03, s=0) * 0.5
    S["ui_back"] = note(np.linspace(900, 500, int(SR * 0.09)), 0.09, "tri", dcy=0.08, s=0)
    S["ui_toggle"] = seq(note(700, 0.04, "square", dcy=0.03, s=0, duty=0.25), note(1050, 0.05, "square", dcy=0.04, s=0, duty=0.25))
    S["pop"] = note(np.geomspace(300, 1400, int(SR * 0.08)), 0.08, "sine", dcy=0.07, s=0)
    S["bubble"] = note(np.geomspace(400, 2000, int(SR * 0.12)), 0.12, "sine", dcy=0.1, s=0) * 0.8
    S["correct"] = seq(bell(hz("C6"), 0.12), bell(hz("E6"), 0.12), bell(hz("G6"), 0.5))
    S["wrong"] = seq(note(220, 0.16, "square", dcy=0.1, s=0.5, duty=0.3), note(165, 0.32, "square", dcy=0.2, s=0.4, duty=0.3), gap=0.03)
    S["error_buzz"] = note(110, 0.35, "saw", s=0.8, r=0.05) * (0.6 + 0.4 * np.sign(np.sin(2 * np.pi * 18 * t(0.35))))
    S["star"] = mix(*[at(bell(f, 0.6), i * 0.06, 1.0) for i, f in enumerate((hz("E6"), hz("G6"), hz("C7"), hz("E7")))])
    S["sparkle"] = mix(*[at(bell(rng.uniform(2000, 4000), 0.25, 0.5) * 0.5, rng.uniform(0, 0.3), 0.6) for _ in range(8)])
    S["coin"] = seq(note(hz("B5"), 0.07, "square", dcy=0.05, s=0.6, r=0.01, duty=0.25), note(hz("E6"), 0.35, "square", dcy=0.3, s=0.2, duty=0.25))
    S["collect"] = seq(*[note(hz(n), 0.06, "tri", dcy=0.05, s=0.3, r=0.01) for n in ("C6", "E6", "G6", "C7")])
    S["powerup"] = note(np.geomspace(200, 1600, int(SR * 0.6)), 0.6, "square", s=0.6, duty=0.25) * (0.7 + 0.3 * np.sin(2 * np.pi * 30 * t(0.6)))
    S["level_up"] = mix(*[at(note(hz(n), 0.25, "square", dcy=0.1, s=0.5, duty=0.25), i * 0.11, 1.2) for i, n in enumerate(("C5", "E5", "G5", "C6"))],
                        at(bell(hz("C7"), 0.8), 0.44, 1.2))
    S["win_fanfare"] = mix(*[at(note(hz(n), d, "square", dcy=0.1, s=0.6, r=0.1, duty=0.3) + 0.5 * note(hz(n) / 2, d, "tri", s=0.6), st, 2.2)
                             for n, st, d in (("G4", 0, 0.15), ("C5", 0.15, 0.15), ("E5", 0.3, 0.15), ("G5", 0.45, 0.3), ("E5", 0.8, 0.15), ("G5", 0.95, 1.1))])
    S["lose"] = seq(*[note(hz(n), 0.22, "tri", dcy=0.1, s=0.6, r=0.05, vib=0.01) for n in ("G4", "F#4", "F4")], note(hz("E4"), 0.7, "tri", s=0.6, r=0.3, vib=0.02))
    S["countdown_tick"] = note(1000, 0.06, "sine", dcy=0.05, s=0)
    S["countdown_go"] = note(1500, 0.45, "square", dcy=0.1, s=0.7, r=0.15, duty=0.3)
    S["timer_warning"] = seq(*[note(880, 0.1, "square", dcy=0.05, s=0.6, r=0.02, duty=0.4) for _ in range(3)], gap=0.08)
    S["time_up"] = mix(note(440, 0.8, "saw", s=0.7, r=0.3), note(466, 0.8, "saw", s=0.7, r=0.3))
    S["whoosh"] = lowpass(noise(0.35), 2500) * np.sin(np.linspace(0, np.pi, int(SR * 0.35))) ** 2
    S["swoosh_up"] = lowpass(noise(0.25), 3000) * np.linspace(0, 1, int(SR * 0.25)) ** 2
    S["page_flip"] = lowpass(noise(0.18), 6000) * env(int(SR * 0.18), 0.02, 0.15, 0, 0.01) + 0.3 * lowpass(noise(0.18), 900)
    S["card_flip"] = seq(lowpass(noise(0.05), 5000) * env(int(SR * 0.05), 0.001, 0.04, 0, 0.005), lowpass(noise(0.06), 3000) * env(int(SR * 0.06), 0.001, 0.05, 0, 0.005), gap=0.04)
    S["typing_blip"] = note(660, 0.03, "square", dcy=0.025, s=0, duty=0.5) * 0.6
    S["pick_up"] = note(np.linspace(500, 800, int(SR * 0.08)), 0.08, "tri", dcy=0.07, s=0)
    S["drop"] = note(np.linspace(600, 350, int(SR * 0.1)), 0.1, "tri", dcy=0.09, s=0)
    S["snap"] = mix(0.7 * noise(0.03) * env(int(SR * 0.03), 0.0005, 0.02, 0, 0.005), note(1600, 0.06, "sine", dcy=0.05, s=0))
    S["unlock"] = seq(note(900, 0.05, "square", dcy=0.04, s=0, duty=0.2), bell(hz("A6"), 0.4), gap=0.05)
    S["jump"] = note(np.geomspace(250, 700, int(SR * 0.16)), 0.16, "square", dcy=0.14, s=0, duty=0.25)
    S["land"] = lowpass(noise(0.08), 600) * env(int(SR * 0.08), 0.001, 0.07, 0, 0.005) + note(90, 0.08, "sine", dcy=0.07, s=0)
    S["hurt"] = note(np.linspace(500, 150, int(SR * 0.25)), 0.25, "saw", dcy=0.2, s=0)
    S["dice_roll"] = mix(*[at(mix(0.6 * noise(0.025) * env(int(SR * 0.025), 0.001, 0.02, 0, 0.002), 0.4 * note(rng.uniform(1500, 2500), 0.03, "sine", dcy=0.02, s=0)), k * 0.06 + rng.uniform(0, 0.02), 0.8) for k in range(11)])
    S["school_bell"] = mix(*[at(bell(hz("E5"), 0.3, 1.4) + 0.5 * bell(hz("E6"), 0.3), k * 0.07, 2.0) for k in range(24)]) * np.linspace(1, 0.3, int(SR * 2.0))
    S["applause"] = lowpass(sum(at(noise(0.03) * env(int(SR * 0.03), 0.001, 0.025, 0, 0.003), rng.uniform(0, 2.4), 2.5) for _ in range(500)), 5000) * np.concatenate([np.linspace(0, 1, int(SR * 0.3)), np.ones(int(SR * 1.4)), np.linspace(1, 0, int(SR * 2.5) - int(SR * 0.3) - int(SR * 1.4))])
    S["combo"] = seq(*[bell(hz(n), 0.09, 0.6) for n in ("C6", "D6", "E6", "G6", "A6", "C7")])
    S["chalk_write"] = lowpass(noise(0.6), 4000) * (0.5 + 0.5 * np.abs(np.sin(2 * np.pi * 3 * t(0.6)))) * 0.5
    S["notification"] = seq(bell(hz("A5"), 0.15), bell(hz("E6"), 0.45))
    for name, x in S.items():
        save_wav(os.path.join(SFX, name + ".wav"), x)
    return list(S)


# ---------------- music ----------------
def chord_tones(root, quality):
    r = hz(root)
    steps = {"maj": (0, 4, 7), "min": (0, 3, 7), "sus": (0, 5, 7), "maj7": (0, 4, 7, 11), "min7": (0, 3, 7, 10)}[quality]
    return [r * 2 ** (s / 12) for s in steps]


def drum_kick(d=0.25):
    return osc(np.geomspace(150, 45, int(SR * d)), d) * env(int(SR * d), 0.001, d * 0.9, 0, 0.01)


def drum_snare(d=0.18):
    return (0.7 * noise(d) + 0.3 * osc(190, d, "tri")) * env(int(SR * d), 0.001, d * 0.8, 0, 0.01)


def drum_hat(d=0.05):
    x = noise(d)
    return (x - lowpass(x, 7000)) * env(int(SR * d), 0.001, d * 0.8, 0, 0.005) * 0.6


def song(bpm, bars, prog, melody, lead="square", bass_kind="tri", drums="pop", pad=True, arp=False, lead_duty=0.25, swing=0.0):
    beat = 60 / bpm
    total = bars * 4 * beat
    tracks = []
    for bi in range(bars):
        root, q = prog[bi % len(prog)]
        tones = chord_tones(root, q)
        t0 = bi * 4 * beat
        if pad:
            tracks.append(at(0.18 * sum(note(f, 4 * beat, "tri", a=0.2, dcy=0.3, s=0.6, r=0.3) for f in tones), t0, total))
        if arp:
            for k in range(8):
                f = tones[k % len(tones)] * (2 if k >= 4 else 1)
                tracks.append(at(0.16 * note(f, beat / 2, "sine", dcy=0.2, s=0.2, r=0.05), t0 + k * beat / 2, total))
        b = tones[0] / 2
        for k, (off, f) in enumerate(((0, b), (1.5, b), (2, b * 1.5), (3, b))):
            tracks.append(at(0.35 * note(f, beat * 0.9, bass_kind, dcy=0.2, s=0.5, r=0.05), t0 + off * beat, total))
        if drums:
            for k in range(4):
                if drums == "pop":
                    if k in (0, 2):
                        tracks.append(at(0.6 * drum_kick(), t0 + k * beat, total))
                    else:
                        tracks.append(at(0.35 * drum_snare(), t0 + k * beat, total))
                elif drums == "soft" and k == 0:
                    tracks.append(at(0.35 * drum_kick(), t0, total))
                elif drums == "four":
                    tracks.append(at(0.6 * drum_kick(), t0 + k * beat, total))
                    if k % 2:
                        tracks.append(at(0.3 * drum_snare(), t0 + k * beat, total))
                for h in (0, 0.5):
                    tracks.append(at(0.25 * drum_hat(), t0 + (k + h + (swing if h else 0)) * beat, total))
    t_cursor = 0.0
    for n, d in melody:
        if n != "-":
            tracks.append(at(0.22 * note(hz(n), d * beat * 0.95, lead, dcy=0.15, s=0.55, r=0.06, vib=0.004, duty=lead_duty), t_cursor, total))
        t_cursor += d * beat
    assert abs(t_cursor - total) < 1e-6, f"melody length {t_cursor} != {total}"
    x = mix(*tracks)
    # wrap the release tail of the last bar onto the start so the loop point is seamless
    return x[:int(SR * total)]


def mel(s):
    """'C5:1 E5:0.5 -:0.5' -> [(note, beats)]"""
    return [(a, float(b)) for a, b in (tok.split(":") for tok in s.split())]


def music():
    os.makedirs(MUS, exist_ok=True)
    tracks = {
        "menu_ceria": song(112, 8, [("C4", "maj"), ("G3", "maj"), ("A3", "min"), ("F3", "maj")],
                           mel("E5:1 G5:1 A5:1 G5:1 D5:1 G5:1 B5:1 G5:1 C6:1 B5:1 A5:1 E5:1 F5:1 A5:1 G5:2 "
                               "E5:0.5 F5:0.5 G5:1 E5:1 C5:1 D5:1 B4:1 G4:1 D5:1 C5:1 E5:1 A5:1 G5:1 F5:1 E5:1 D5:1 C5:1")),
        "quiz_berfikir": song(92, 8, [("A3", "min7"), ("F3", "maj7"), ("C4", "maj7"), ("G3", "sus")],
                              mel("-:2 E5:1 C5:1 -:2 A4:1 C5:1 -:2 G5:1 E5:1 D5:4 -:2 E5:1 C5:1 -:2 A4:1 C5:1 -:2 B4:1 C5:1 D5:4"),
                              lead="sine", drums="soft", arp=True),
        "arcade_laju": song(140, 8, [("C4", "min"), ("G#3", "maj"), ("A#3", "maj"), ("G3", "maj")],
                            mel("C5:0.5 C5:0.5 D#5:0.5 G5:0.5 F5:1 D#5:1 D#5:0.5 D#5:0.5 F5:0.5 G#5:0.5 G5:1 F5:1 F5:0.5 F5:0.5 G5:0.5 A#5:0.5 G#5:1 G5:1 F5:1 D5:1 B4:2 "
                                "C5:0.5 C5:0.5 D#5:0.5 G5:0.5 C6:1 A#5:1 G#5:0.5 G5:0.5 F5:0.5 D#5:0.5 F5:2 D#5:0.5 D5:0.5 D#5:0.5 F5:0.5 G5:1 D#5:1 D5:1 B4:1 C5:2"),
                            drums="four", lead_duty=0.125),
        "jelajah_santai": song(100, 8, [("D4", "maj"), ("B3", "min"), ("G3", "maj"), ("A3", "maj")],
                               mel("A5:1.5 F#5:0.5 E5:1 D5:1 E5:1.5 F#5:0.5 A5:2 B5:1.5 A5:0.5 F#5:1 E5:1 D5:4 "
                                   "F#5:1 A5:1 B5:1 D6:1 B5:1.5 A5:0.5 F#5:2 E5:1 F#5:1 A5:1 F#5:1 E5:2 D5:2"),
                               lead="tri", drums="soft", arp=True, swing=0.08),
        "santai_kampung": song(84, 8, [("G3", "maj"), ("E3", "min"), ("C3", "maj"), ("D3", "maj")],
                               mel("D5:1 E5:1 G5:2 A5:1 G5:1 E5:2 D5:1 E5:1 G5:1 A5:1 B5:4 A5:1 G5:1 E5:2 D5:1 E5:1 G5:2 E5:1 D5:1 B4:1 D5:1 G4:4"),
                               lead="sine", drums=None, arp=True),
    }
    jingles = {
        "jingle_menang": mix(*[at(note(hz(n), d, "square", dcy=0.1, s=0.6, r=0.1, duty=0.25) * 0.4 + 0.3 * note(hz(n) / 2, d, "tri", s=0.5), st, 3.0) for n, st, d in
                               (("C5", 0, 0.2), ("E5", 0.2, 0.2), ("G5", 0.4, 0.2), ("C6", 0.6, 0.6), ("A5", 1.2, 0.2), ("B5", 1.4, 0.2), ("C6", 1.6, 1.2))],
                             *[at(0.25 * drum_snare(), s, 3.0) for s in (0.6, 1.6, 1.7, 1.8)]),
        "jingle_cuba_lagi": mix(*[at(note(hz(n), d, "tri", dcy=0.1, s=0.6, r=0.2, vib=0.01) * 0.5, st, 2.2) for n, st, d in (("E5", 0, 0.3), ("D5", 0.3, 0.3), ("C5", 0.6, 0.3), ("D5", 0.9, 1.0))]),
    }
    out = []
    for name, x in {**tracks, **jingles}.items():
        wav = os.path.join(MUS, name + ".wav")
        save_wav(wav, x, peak=0.8)
        ogg = os.path.join(MUS, name + ".ogg")
        subprocess.run(["ffmpeg", "-y", "-loglevel", "error", "-i", wav, "-c:a", "libvorbis", "-q:a", "5", ogg], check=True)
        os.remove(wav)
        out.append(name)
    return out


if __name__ == "__main__":
    s = sfx()
    m = music()
    with open(os.path.join(ROOT, "assets", "audio", "audio_manifest.json"), "w", encoding="utf-8") as f:
        json.dump({"sfx": sorted(s), "music": sorted(m)}, f, indent=1)
    print(len(s), "sfx,", len(m), "music")
