"""Voice lines via edge-tts: BM in ms-MY-YasminNeural (Malaysian accent, never an
Indonesian voice), English in en-SG-LunaNeural (closest regional accent).
Also voices every subject picture's BM/EN name from assets/art/manifest.json.
Output: assets/audio/voice/<ms|en>/<group>/<id>.mp3 + voice_manifest.json.
Re-runs skip files that already exist, so an interrupted run can just be restarted."""
import asyncio, json, os, sys
import edge_tts

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(ROOT, "assets", "audio", "voice")
VOICE = {"ms": "ms-MY-YasminNeural", "en": "en-SG-LunaNeural"}

FEEDBACK = {
    "correct": ("Betul!", "Correct!"), "great": ("Hebat!", "Great!"), "good": ("Bagus!", "Good job!"), "well_done": ("Syabas!", "Well done!"),
    "congrats": ("Tahniah!", "Congratulations!"), "excellent": ("Cemerlang!", "Excellent!"), "try_again": ("Cuba lagi.", "Try again."),
    "almost": ("Hampir betul!", "Almost!"), "wrong": ("Salah.", "Wrong."), "dont_give_up": ("Jangan putus asa!", "Don't give up!"),
    "times_up": ("Masa tamat!", "Time's up!"), "lets_start": ("Mari kita mulakan!", "Let's start!"), "ready": ("Sedia...", "Ready..."), "go": ("Mula!", "Go!"),
    "next_level": ("Tahap seterusnya!", "Next level!"), "level_complete": ("Tahap selesai!", "Level complete!"), "game_over": ("Permainan tamat.", "Game over."),
    "choose_answer": ("Pilih jawapan yang betul.", "Choose the correct answer."), "listen_choose": ("Dengar dan pilih.", "Listen and choose."),
    "drag_place": ("Seret ke tempat yang betul.", "Drag it to the right place."), "match": ("Padankan gambar dengan perkataan.", "Match the picture with the word."),
    "count": ("Kira objek ini.", "Count these objects."), "say_word": ("Sebut perkataan ini.", "Say this word."), "welcome": ("Selamat datang!", "Welcome!"),
    "thanks": ("Terima kasih kerana bermain!", "Thank you for playing!"), "three_stars": ("Tiga bintang! Hebatnya!", "Three stars! Amazing!"),
    "your_score": ("Markah anda.", "Your score."), "question": ("Soalan.", "Question."), "paused": ("Permainan dijeda.", "Game paused."),
    "new_record": ("Rekod baharu!", "New record!"), "unlocked": ("Tahap baharu dibuka!", "New level unlocked!"), "hint": ("Ini petunjuk.", "Here is a hint."),
    "spell": ("Eja perkataan ini.", "Spell this word."), "find": ("Cari objek ini.", "Find this object."), "sort": ("Susun mengikut urutan.", "Put them in order."),
}
NUM_MS = "sifar satu dua tiga empat lima enam tujuh lapan sembilan sepuluh sebelas".split() + [f"{w} belas" for w in "dua tiga empat lima enam tujuh lapan sembilan".split()]
NUM_EN = "zero one two three four five six seven eight nine ten eleven twelve thirteen fourteen fifteen sixteen seventeen eighteen nineteen".split()
TENS_MS = {20: "dua puluh", 30: "tiga puluh", 40: "empat puluh", 50: "lima puluh", 60: "enam puluh", 70: "tujuh puluh", 80: "lapan puluh", 90: "sembilan puluh", 100: "seratus", 1000: "seribu"}
TENS_EN = {20: "twenty", 30: "thirty", 40: "forty", 50: "fifty", 60: "sixty", 70: "seventy", 80: "eighty", 90: "ninety", 100: "one hundred", 1000: "one thousand"}
LETTER_MS = ["ei", "bi", "si", "di", "i", "ef", "ji", "hec", "ai", "je", "ke", "el", "em", "en", "o", "pi", "kiu", "ar", "es", "ti", "yu", "vi", "dabel yu", "eks", "wai", "zed"]
LETTER_EN = ["ay", "bee", "see", "dee", "ee", "eff", "gee", "aitch", "eye", "jay", "kay", "el", "em", "en", "oh", "pee", "cue", "ar", "ess", "tee", "you", "vee", "double you", "ex", "why", "zed"]
COLOURS = {"merah": "red", "biru": "blue", "hijau": "green", "kuning": "yellow", "oren": "orange", "ungu": "purple", "merah_jambu": "pink", "hitam": "black", "putih": "white", "coklat": "brown", "kelabu": "grey"}
DAYS = {"isnin": "Monday", "selasa": "Tuesday", "rabu": "Wednesday", "khamis": "Thursday", "jumaat": "Friday", "sabtu": "Saturday", "ahad": "Sunday"}
MONTHS = ["Januari", "Februari", "Mac", "April", "Mei", "Jun", "Julai", "Ogos", "September", "Oktober", "November", "Disember"]
MONTHS_EN = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
CONS = "b c d f g h j k l m n p r s t w y z".split()


def jobs():
    j = []  # (lang, group, id, text)
    for k, (ms, en) in FEEDBACK.items():
        j += [("ms", "feedback", k, ms), ("en", "feedback", k, en)]
    for n in range(20):
        j += [("ms", "numbers", str(n), NUM_MS[n]), ("en", "numbers", str(n), NUM_EN[n])]
    for n in TENS_MS:
        j += [("ms", "numbers", str(n), TENS_MS[n]), ("en", "numbers", str(n), TENS_EN[n])]
    for i, ch in enumerate("abcdefghijklmnopqrstuvwxyz"):
        j += [("ms", "letters", ch, LETTER_MS[i]), ("en", "letters", ch, LETTER_EN[i])]
    for v in "aiueo":
        j.append(("ms", "syllables", v, v))
        for c in CONS:
            j.append(("ms", "syllables", c + v, c + v))
    for ms, en in COLOURS.items():
        j += [("ms", "colours", ms, ms.replace("_", " ")), ("en", "colours", ms, en)]
    for ms, en in DAYS.items():
        j += [("ms", "days", ms, ms.capitalize()), ("en", "days", ms, en)]
    for i, (ms, en) in enumerate(zip(MONTHS, MONTHS_EN)):
        j += [("ms", "months", str(i + 1), ms), ("en", "months", str(i + 1), en)]
    # Bank questions: language subjects are voiced only in their own language.
    qdir = os.path.join(ROOT, "data", "questions")
    for fn in sorted(os.listdir(qdir)):
        subject = fn[:-5]
        for q in json.load(open(os.path.join(qdir, fn), encoding="utf-8")):
            for lang in ("ms", "en"):
                if (subject, lang) in (("bahasa_melayu", "en"), ("bahasa_inggeris", "ms")):
                    continue
                j.append((lang, "questions/" + subject, q["id"], q["q"][lang].replace("___", "...")))
    manifest = json.load(open(os.path.join(ROOT, "assets", "art", "manifest.json"), encoding="utf-8"))
    for m in manifest:
        if m.get("subject"):
            j += [("ms", "vocab/" + m["subject"], m["id"], m["bm"]), ("en", "vocab/" + m["subject"], m["id"], m["en"])]
    return j


async def speak(sem, lang, group, ident, text, failures):
    path = os.path.join(OUT, lang, group, ident + ".mp3")
    if os.path.exists(path) and os.path.getsize(path) > 1000:
        return
    os.makedirs(os.path.dirname(path), exist_ok=True)
    async with sem:
        for attempt in range(4):
            try:
                await edge_tts.Communicate(text, VOICE[lang], rate="-5%").save(path)
                if os.path.getsize(path) > 1000:
                    return
            except Exception as e:  # network hiccups: back off and retry
                err = e
            await asyncio.sleep(1.5 * (attempt + 1))
        failures.append((lang, group, ident, text))


async def main():
    j = jobs()
    sem = asyncio.Semaphore(6)
    failures = []
    await asyncio.gather(*(speak(sem, *x, failures) for x in j))
    index = {}
    for lang, group, ident, text in j:
        index.setdefault(lang, {}).setdefault(group, {})[ident] = {"text": text, "path": f"res://assets/audio/voice/{lang}/{group}/{ident}.mp3"}
    with open(os.path.join(OUT, "voice_manifest.json"), "w", encoding="utf-8") as f:
        json.dump(index, f, ensure_ascii=False, indent=1)
    print(len(j), "lines,", len(failures), "failed")
    for x in failures[:20]:
        print("FAILED", x)
    sys.exit(1 if failures else 0)


if __name__ == "__main__":
    asyncio.run(main())
