## Question source for quiz-style games. Every question comes back in one shape:
##   {"text": String, "choices": Array[String], "answer": int, "image": String(ref), "subject": String, "speak": Dictionary}
## Sources:
##   Questions.from_bank("sains", 5, year)       # data/questions/<subject>.json, choices shuffled
##   Questions.math("+", year)                   # generated arithmetic, KSSR-ish ranges per year
##   Questions.picture("bahasa_melayu", 5)       # "What is this?" from the art manifest + voice
extends Node

const BANK_DIR := "res://data/questions/"
const USER_DIR := "user://questions/"  ## teacher-added questions (IndexedDB on web)

var _banks := {}


static func _read(path: String) -> Array:
	var data = JSON.parse_string(FileAccess.get_file_as_string(path)) if FileAccess.file_exists(path) else null
	return data if data is Array else []


## Built-in bank + the teacher's own questions for that subject.
func bank(subject: String) -> Array:
	if not _banks.has(subject):
		_banks[subject] = _read(BANK_DIR + subject + ".json") + user_bank(subject)
	return _banks[subject]


func user_bank(subject: String) -> Array:
	return _read(USER_DIR + subject + ".json")


func save_user_bank(subject: String, questions: Array) -> bool:
	DirAccess.make_dir_recursive_absolute(USER_DIR)
	var f := FileAccess.open(USER_DIR + subject + ".json", FileAccess.WRITE)
	if f == null:
		push_warning("Questions: cannot save %s (%d)" % [subject, FileAccess.get_open_error()])
		return false
	f.store_string(JSON.stringify(questions, " "))
	f.close()
	_banks.erase(subject)
	return true


## Checks one teacher question before it is saved: text, 4 distinct non-empty choices per language.
static func validate(q: Dictionary) -> String:
	for lang in ["ms", "en"]:
		if str(q.get("q", {}).get(lang, "")).strip_edges() == "":
			return "question text (%s) is empty" % lang
		var c: Array = q.get("choices", {}).get(lang, [])
		if c.size() != 4 or c.any(func(x): return str(x).strip_edges() == ""):
			return "need 4 answers (%s)" % lang
		var u := {}
		for x in c:
			u[str(x).strip_edges().to_lower()] = true
		if u.size() != 4:
			return "answers must be different (%s)" % lang
	return ""


## Banks store the correct choice first; this shuffles and tracks where it went.
func _prepare(raw: Dictionary, subject: String, lang: String) -> Dictionary:
	var choices: Array = raw.choices[lang].duplicate()
	var correct: String = choices[raw.get("answer", 0)]
	choices.shuffle()
	var speak := {"group": "questions/" + subject, "id": raw.id} if raw.has("id") else {}
	return {"text": raw.q[lang], "choices": choices, "answer": choices.find(correct), "image": raw.get("image", ""), "subject": subject,
		"speak": speak, "year": int(raw.get("year", 1))}


func from_bank(subject: String, count := 5, year := 0, lang := "") -> Array:
	lang = lang if lang != "" else GameState.lang
	var pool := bank(subject).filter(func(q): return year == 0 or q.year <= year)
	pool.shuffle()
	return pool.slice(0, count).map(func(q): return _prepare(q, subject, lang))


## Arithmetic with distinct, non-negative distractors near the answer.
func math(op := "+", year := 1, lang := "") -> Dictionary:
	lang = lang if lang != "" else GameState.lang
	var hi: int = [10, 20, 100, 1000, 10000, 100000][clampi(year, 1, 6) - 1]
	var a := 0
	var b := 0
	var ans := 0
	match op:
		"+":
			a = randi_range(0, hi / 2); b = randi_range(0, hi / 2); ans = a + b
		"-":
			a = randi_range(1, hi); b = randi_range(0, a); ans = a - b
		"x", "×":
			op = "×"
			var t := 5 if year <= 2 else (10 if year <= 4 else 12)
			a = randi_range(1, t); b = randi_range(1, t); ans = a * b
		"/", "÷":
			op = "÷"
			var t2 := 5 if year <= 2 else (10 if year <= 4 else 12)
			b = randi_range(1, t2); ans = randi_range(1, t2); a = b * ans
		_:
			push_error("Questions.math: unknown op " + op)
			return {}
	var spread := maxi(3, ans / 10)
	var choices := [ans]
	var tries := 0
	while choices.size() < 4 and tries < 100:
		tries += 1
		var d := ans + randi_range(-spread, spread)
		if d >= 0 and d not in choices:
			choices.append(d)
	var n := 1
	while choices.size() < 4:  # tiny answers: fall back to the next free numbers
		if ans + n not in choices:
			choices.append(ans + n)
		n += 1
	choices.shuffle()
	var q := "Berapakah %d %s %d?" if lang == "ms" else "What is %d %s %d?"
	return {"text": q % [a, op, b], "choices": choices.map(func(c): return str(c)), "answer": choices.find(ans),
		"image": "", "subject": "matematik", "a": a, "b": b, "op": op, "speak": {}}


## Picture-naming questions from the art manifest: image + 4 names, the answer is spoken.
func picture(subject: String, count := 5, lang := "", tag := "") -> Array:
	lang = lang if lang != "" else GameState.lang
	var refs := EduAssets.by_subject(subject).filter(func(r): return tag == "" or tag in EduAssets.entry(r).tags)
	refs.shuffle()
	var out := []
	for r in refs.slice(0, count):
		var others := refs.filter(func(o): return o != r)
		others.shuffle()
		var names := [EduAssets.name_of(r, lang)]
		for o in others:
			var nm := EduAssets.name_of(o, lang)
			if nm not in names:
				names.append(nm)
			if names.size() == 4:
				break
		var correct: String = names[0]
		names.shuffle()
		out.append({"text": "Apakah ini?" if lang == "ms" else "What is this?", "choices": names, "answer": names.find(correct),
			"image": r, "subject": subject, "speak": {"group": "vocab/" + subject, "id": r.get_slice("/", 1)}})
	return out


func subjects_with_banks() -> Array:
	return Array(DirAccess.get_files_at(BANK_DIR)).filter(func(f): return f.ends_with(".json")).map(func(f): return f.get_basename())
