## Juara Kuiz Sekolah: session state shared by the scenes + round building.
## A round is 10 questions; the 10th is the boss question (harder, double points).
class_name Jks
extends RefCounted

const ROUND := 10
const SCENES := {
	"menu": "res://games/juara_kuiz/main_menu.tscn", "subjects": "res://games/juara_kuiz/subject_select.tscn",
	"stages": "res://games/juara_kuiz/stage_map.tscn", "play": "res://games/juara_kuiz/play.tscn",
	"editor": "res://games/juara_kuiz/editor.tscn",
}
const MIXED := "campuran"
const ICON := {
	"bahasa_melayu": "bahasa_melayu/wau", "bahasa_inggeris": "bahasa_inggeris/bus", "matematik": "matematik/op_plus",
	"sains": "sains/flask_conical", "pendidikan_islam": "pendidikan_islam/masjid", "pendidikan_moral": "pendidikan_moral/tolong_menolong",
	"pjpk": "pjpk/bola_sepak", "seni_visual": "seni_visual/roda_warna", "muzik": "muzik/kompang", "sejarah": "sejarah/jalur_gemilang",
	"rbt": "rbt/robot", MIXED: "icons/star",
}
const MIN_YEAR := {"sejarah": 4, "rbt": 4}  ## KSSR: Sejarah and RBT start in Tahun 4
## name ms, name en, background, seconds per question
const STAGES := [["Kelas", "Classroom", "backgrounds/classroom", 25], ["Sekolah", "School", "backgrounds/library", 22],
	["Daerah", "District", "backgrounds/school_field", 19], ["Negeri", "State", "backgrounds/kampung", 16],
	["Kebangsaan", "National", "backgrounds/stage_hall", 13]]
const TEAMS := [["Merah", "Red", Color("ef476f")], ["Biru", "Blue", Color("3a86ff")], ["Kuning", "Yellow", Color("f4a100")], ["Hijau", "Green", Color("6bcb77")]]

static var subject := "sains"
static var year := 1
static var stage := 1
static var teams := 0  ## 0 = solo, 2-4 = class mode (hot-seat teams)


static func subjects() -> Array:
	return EduAssets.SUBJECTS + [MIXED]


static func subject_name(s: String, lang := "") -> String:
	lang = lang if lang != "" else GameState.lang
	if s == MIXED:
		return "Campuran" if lang == "ms" else "Mixed"
	return EduAssets.subject_name(s, lang)


static func available(s: String, y: int) -> bool:
	return y >= MIN_YEAR.get(s, 1)


static func game_id() -> String:
	return "jks_%s_t%d" % [subject, year]


## Language subjects are always played in their own language.
static func lang_for(s: String) -> String:
	return {"bahasa_melayu": "ms", "bahasa_inggeris": "en"}.get(s, GameState.lang)


static func stage_name(n: int) -> String:
	return STAGES[n - 1][0 if GameState.lang == "ms" else 1]


static func team_name(i: int) -> String:
	return ("Pasukan " + TEAMS[i][0]) if GameState.lang == "ms" else ("Team " + TEAMS[i][1])


static func _math_ops(y: int) -> Array:
	return ["+", "-"] if y <= 2 else ["+", "-", "×", "÷"]


## Points for a correct answer: base + speed bonus, times streak and boss multipliers.
static func points(time_left: float, streak: int, boss: bool) -> int:
	var mult := 3 if streak >= 5 else (2 if streak >= 3 else 1)
	return (100 + int(time_left * 5.0)) * mult * (2 if boss else 1)


static func multiplier(streak: int) -> int:
	return 3 if streak >= 5 else (2 if streak >= 3 else 1)


## One question for subject s (used for filling, skipping and mixed rounds).
static func one(s: String, avoid: Array = []) -> Dictionary:
	var lang := lang_for(s)
	for attempt in 8:
		var q: Dictionary
		var r := randf()
		if s == "matematik" and r < 0.5:
			q = Questions.math(_math_ops(year).pick_random(), year, lang)
		elif r < 0.6:
			var b: Array = Questions.from_bank(s, 1, year, lang)
			q = b[0] if not b.is_empty() else {}
		if q.is_empty():
			var p: Array = Questions.picture(s, 1, lang)
			q = p[0] if not p.is_empty() else Questions.math("+", year, lang)
		if not _key(q) in avoid:
			return q
	return Questions.math(_math_ops(year).pick_random(), year, lang)


static func _key(q: Dictionary) -> String:
	return str(q.text) + "|" + str(q.get("image", ""))


## 9 normal questions + 1 boss. Later stages prefer bank questions near the chosen Tahun.
static func build_round() -> Array:
	var out: Array = []
	var keys: Array = []
	if subject == MIXED:
		var pool := EduAssets.SUBJECTS.filter(func(x): return available(x, year))
		for i in ROUND - 1:
			var q := one(pool[i % pool.size()] if i < pool.size() else pool.pick_random(), keys)
			keys.append(_key(q))
			out.append(q)
		out.shuffle()
	else:
		var lang := lang_for(subject)
		var bank: Array = Questions.from_bank(subject, 99, year, lang)
		if stage >= 3:
			bank.sort_custom(func(a, b): return a.year > b.year)
		var n_bank := mini(bank.size(), 6 if subject != "matematik" else 4)
		for q in bank.slice(0, n_bank):
			out.append(q)
		if subject == "matematik":
			while out.size() < ROUND - 1:
				out.append(Questions.math(_math_ops(year).pick_random(), year, lang))
		else:
			for q in Questions.picture(subject, ROUND - 1 - out.size(), lang):
				out.append(q)
		for q in out:
			keys.append(_key(q))
		while out.size() < ROUND - 1:
			var q := one(subject, keys)
			keys.append(_key(q))
			out.append(q)
		out.shuffle()
	out.append(boss(keys))
	return out


static func boss(avoid: Array) -> Dictionary:
	var s: String = subject if subject != MIXED else EduAssets.SUBJECTS.filter(func(x): return available(x, year)).pick_random()
	var lang := lang_for(s)
	var q: Dictionary = {}
	if s == "matematik":
		q = Questions.math(["×", "÷"].pick_random(), mini(year + 1, 6), lang)
	else:
		var hard: Array = Questions.from_bank(s, 99, year, lang).filter(func(x): return not _key(x) in avoid)
		hard.sort_custom(func(a, b): return a.year > b.year)
		q = hard[0] if not hard.is_empty() else one(s, avoid)
	q = q.duplicate()
	q["boss"] = true
	return q


## Lifeline hint text that never gives the answer away completely.
static func hint(q: Dictionary) -> String:
	var ans := str(q.choices[q.answer])
	if ans.is_valid_int():
		var n := int(ans)
		var lo := maxi(0, n - randi_range(1, maxi(2, n / 5)))
		var hi := n + randi_range(1, maxi(2, n / 5))
		return GameState.tr2("Jawapannya antara %d dan %d." % [lo, hi], "The answer is between %d and %d." % [lo, hi])
	var first := ans.substr(0, 1).to_upper()
	var words := ans.split(" ", false).size()
	if words > 1:
		return GameState.tr2("Jawapannya bermula dengan '%s' dan ada %d perkataan." % [first, words], "The answer starts with '%s' and has %d words." % [first, words])
	return GameState.tr2("Jawapannya bermula dengan huruf '%s'." % first, "The answer starts with the letter '%s'." % first)
