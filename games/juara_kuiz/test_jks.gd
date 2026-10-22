## Headless game test: godot --headless --path . res://games/juara_kuiz/test_jks.tscn
## Exit code = number of failures.
extends Node

var fails := 0
var checks := 0


func ok(cond: bool, what: String) -> void:
	checks += 1
	if not cond:
		fails += 1
		printerr("FAIL: ", what)


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	await get_tree().process_frame
	var keep: Dictionary = GameState.progress.duplicate(true)
	# 1. every subject x year x stage builds a valid round
	for s in Jks.subjects():
		for y in range(1, 7):
			if not Jks.available(s, y):
				continue
			Jks.subject = s
			Jks.year = y
			for st in range(1, 6):
				Jks.stage = st
				var qs := Jks.build_round()
				ok(qs.size() == Jks.ROUND, "%s T%d S%d size %d" % [s, y, st, qs.size()])
				ok(qs[-1].get("boss", false) and qs.filter(func(q): return q.get("boss", false)).size() == 1, "%s boss last" % s)
				var keys := {}
				for q in qs:
					ok(q.choices.size() == 4 and q.answer >= 0 and q.answer < 4, "%s choices/answer %s" % [s, q.text])
					var u := {}
					for c in q.choices:
						u[str(c)] = true
					ok(u.size() == 4, "%s unique choices %s" % [s, q.choices])
					keys[str(q.text) + "|" + str(q.get("image", ""))] = true
					ok(q.get("year", 1) <= y or q.get("boss", false) or q.subject == "matematik", "%s year filter T%d" % [s, y])
					var h := Jks.hint(q)
					var ans := str(q.choices[q.answer])
					ok(h != "" and (ans.length() <= 2 or not h.contains(ans)), "hint leaks answer: %s" % ans)
					if s == "bahasa_inggeris" and q.get("speak", {}).has("group"):
						ok(not str(q.speak.group).begins_with("questions/") or ResourceLoader.exists("res://assets/audio/voice/en/%s/%s.mp3" % [q.speak.group, q.speak.id]), "BI voice in English")
					if q.get("speak", {}).has("group") and str(q.speak.group).begins_with("questions/"):
						var lang := Jks.lang_for(q.subject)
						ok(ResourceLoader.exists("res://assets/audio/voice/%s/%s/%s.mp3" % [lang, q.speak.group, q.speak.id]), "question voice %s %s" % [lang, q.text])
				ok(keys.size() >= Jks.ROUND - 1, "%s T%d mostly unique questions (%d)" % [s, y, keys.size()])
	ok(Jks.points(10, 0, false) == 150 and Jks.points(10, 3, false) == 300 and Jks.points(0, 5, true) == 600, "points formula")
	# 2. editor validation
	var good := {"q": {"ms": "A?", "en": "A?"}, "choices": {"ms": ["1", "2", "3", "4"], "en": ["1", "2", "3", "4"]}}
	ok(Questions.validate(good) == "", "valid teacher question")
	var dup := good.duplicate(true)
	dup.choices.ms[1] = "1"
	ok(Questions.validate(dup) != "", "duplicate answers rejected")
	# 3. solo playthrough, all correct, with a 50:50 and a skip
	Engine.time_scale = 10.0
	GameState.progress = {}
	Jks.subject = "sains"
	Jks.year = 3
	Jks.stage = 1
	Jks.teams = 0
	var play: Control = load("res://games/juara_kuiz/play.tscn").instantiate()
	get_tree().root.add_child(play)
	await _frames(3)
	play._use_lifeline("fifty")
	var hidden := 0
	for b in play.card._buttons:
		hidden += 1 if b.disabled else 0
	ok(hidden == 2, "50:50 hides two (%d)" % hidden)
	var before: String = play.qs[play.i].text
	play._use_lifeline("skip")
	await _frames(2)
	ok(play.i == 0 and play.card.question.text == play.qs[0].text, "skip replaces the question (%s -> %s)" % [before, play.qs[0].text])
	await _answer_all(play, func(_k): return true)
	ok(play.correct == Jks.ROUND, "solo all correct (%d)" % play.correct)
	ok(GameState.stars_for("jks_sains_t3", 1) == 3, "3 stars recorded")
	ok(GameState.is_unlocked("jks_sains_t3", 2), "stage 2 unlocked")
	ok(play.points > Jks.ROUND * 100, "points with streak bonus (%d)" % play.points)
	play.queue_free()
	await _frames(2)
	# 4. team playthrough, 3 teams, alternate right/wrong
	Jks.teams = 3
	Jks.subject = Jks.MIXED
	var tp: Control = load("res://games/juara_kuiz/play.tscn").instantiate()
	get_tree().root.add_child(tp)
	await _frames(3)
	await _answer_all(tp, func(k): return k % 2 == 0)
	var sum := 0
	for p in tp.team_points:
		sum += p
	ok(sum == tp.points and tp.correct == 5, "team points add up (%d/%d, %d right)" % [sum, tp.points, tp.correct])
	ok(tp._podium.visible, "podium shown")
	tp.queue_free()
	Jks.teams = 0
	Engine.time_scale = 1.0
	GameState.progress = keep
	GameState.save()
	print("test_jks: %d checks, %d failed" % [checks, fails])
	get_tree().quit(fails)


func _frames(n: int) -> void:
	for k in n:
		await get_tree().process_frame


func _answer_all(play: Control, right: Callable) -> void:
	var k := 0
	var guard := 0
	while play.i < play.qs.size() and guard < 4000:
		guard += 1
		await get_tree().process_frame
		if play.card.visible and not play.card.is_locked() and play.card.question == play.qs[play.i]:
			var q: Dictionary = play.card.question
			var pick: int = q.answer if right.call(k) else (q.answer + 1) % 4
			k += 1
			play.card._on_pick(pick)
	ok(guard < 4000, "round finished")
