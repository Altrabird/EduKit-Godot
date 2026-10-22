## Headless kit check: every asset loads, every script compiles, components run a few
## frames, and the game logic holds. Exit code = number of failures.
## Runs as a scene (not -s) so autoload globals exist:
## godot --headless --path . res://tools/selftest.tscn
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


func _walk(dir: String, exts: Array, out: Array) -> void:
	for f in DirAccess.get_files_at(dir):
		if f.get_extension() in exts:
			out.append(dir.path_join(f))
	for d in DirAccess.get_directories_at(dir):
		if not d.begins_with("."):
			_walk(dir.path_join(d), exts, out)


func _run() -> void:
	await get_tree().process_frame
	var t0 := Time.get_ticks_msec()
	# 1. assets load
	var files := []
	_walk("res://assets", ["svg", "glb", "wav", "ogg", "mp3", "ttf"], files)
	var by_ext := {}
	for f in files:
		var r = load(f)
		ok(r != null, "load " + f)
		by_ext[f.get_extension()] = by_ext.get(f.get_extension(), 0) + 1
	print("assets loaded: ", by_ext)
	# 2. scripts compile
	var scripts := []
	_walk("res://kit", ["gd"], scripts)
	_walk("res://demo", ["gd"], scripts)
	for s in scripts:
		var sc: Script = load(s)
		ok(sc != null and sc.can_instantiate(), "compile " + s)
	print("scripts compiled: ", scripts.size())
	var scenes := []
	_walk("res://demo", ["tscn"], scenes)
	for s in scenes:
		var ps: PackedScene = load(s)
		ok(ps != null and ps.can_instantiate(), "scene " + s)
	# 3. manifests are consistent
	var refs := EduAssets.refs()
	ok(refs.size() > 500, "manifest has %d refs" % refs.size())
	for r in refs:
		ok(ResourceLoader.exists(EduAssets.entry(r).path), "manifest path " + r)
	for m in EduAssets.model_refs():
		ok(EduAssets.model(m) != null, "model " + m)
	var vm = JSON.parse_string(FileAccess.get_file_as_string("res://assets/audio/voice/voice_manifest.json"))
	var vcount := 0
	for lang in vm:
		for grp in vm[lang]:
			for id in vm[lang][grp]:
				vcount += 1
				ok(ResourceLoader.exists(vm[lang][grp][id].path), "voice " + vm[lang][grp][id].path)
	print("voice clips indexed: ", vcount)
	# 4. question logic
	var Q = get_tree().root.get_node("Questions")
	for op in ["+", "-", "x", "/"]:
		for year in range(1, 7):
			for i in 50:
				var q: Dictionary = Q.math(op, year, "ms")
				var a: int = q.a
				var b: int = q.b
				var expect: int = {"+": a + b, "-": a - b, "×": a * b, "÷": a / maxi(b, 1)}[q.op]
				ok(q.choices.size() == 4, "math 4 choices")
				ok(int(q.choices[q.answer]) == expect, "math answer %s" % q.text)
				ok(Array(q.choices).filter(func(c): return int(c) < 0).is_empty(), "math non-negative")
				var uniq := {}
				for c in q.choices:
					uniq[c] = true
				ok(uniq.size() == 4, "math unique choices %s" % [q.choices])
				if q.op == "÷":
					ok(a % b == 0, "division is exact")
	var banks: Array = Q.subjects_with_banks()
	ok(banks.size() >= 10, "question banks: %d" % banks.size())
	for subject in banks:
		var raw: Array = Q.bank(subject)
		for lang in ["ms", "en"]:
			var qs: Array = Q.from_bank(subject, 99, 0, lang)
			ok(qs.size() == raw.size(), "bank size " + subject)
			for q in qs:
				var src = raw.filter(func(r): return r.q[lang] == q.text)[0]
				ok(q.choices[q.answer] == src.choices[lang][0], "bank answer %s: %s" % [subject, q.text])
				ok(q.image == "" or EduAssets.has(q.image), "bank image " + q.image)
	for subject in EduAssets.SUBJECTS:
		for q in Q.picture(subject, 5, "ms"):
			ok(q.choices[q.answer] == EduAssets.name_of(q.image, "ms"), "picture answer " + q.image)
			var u := {}
			for c in q.choices:
				u[c] = true
			ok(u.size() == q.choices.size(), "picture unique choices " + subject)
			ok(ResourceLoader.exists("res://assets/audio/voice/ms/%s/%s.mp3" % [q.speak.group, q.speak.id]), "picture voice " + q.image)
	# 5. small pure functions
	ok(StarRating.stars_for(10, 10) == 3 and StarRating.stars_for(7, 10) == 2 and StarRating.stars_for(4, 10) == 1 and StarRating.stars_for(3, 10) == 0 and StarRating.stars_for(0, 0) == 0, "stars_for table")
	ok(MoneyItem.format_rm(1250) == "RM12.50" and MoneyItem.format_rm(5) == "RM0.05", "format_rm")
	# 6. save / load round trip (restores the player's real progress afterwards)
	var GS = get_tree().root.get_node("GameState")
	var keep: Dictionary = GS.progress.duplicate(true)
	GS.progress = {}
	ok(GS.is_unlocked("t", 1) and not GS.is_unlocked("t", 2), "unlock rule")
	ok(GS.record_level("t", 1, 2, 50), "first record is a best")
	ok(not GS.record_level("t", 1, 1, 10), "worse run is not a best")
	ok(GS.stars_for("t", 1) == 2 and GS.is_unlocked("t", 2), "best kept + next unlocked")
	GS.progress = {}
	GS.load_save()
	ok(GS.stars_for("t", 1) == 2, "save/load round trip")
	GS.progress = keep
	GS.save()
	# 7. components live in the tree for a few frames
	var host := Control.new()
	host.size = Vector2(1920, 1080)
	get_tree().root.add_child(host)
	var comps := [TextTile.new(), PictureCard.new(), DropSlot.new(), QuizCard.new(), AnswerButton.new(), TimerBar.new(), StarRating.new(),
		ScoreCounter.new(), DialogueBox.new(), FractionPie.new(), AnalogClock.new(), NumberLine.new(), MoneyItem.new(), LevelButton.new(), ResultsPanel.new()]
	for c in comps:
		host.add_child(c)
	var ch := Character2D.new()
	host.add_child(ch)
	var pl := Player2D.new()
	host.add_child(pl)
	var prop := Prop3D.new()
	prop.ref = "sains/microscope"
	var w3 := Node3D.new()
	get_tree().root.add_child(w3)
	w3.add_child(prop)
	for i in 5:
		await get_tree().process_frame
	ok(prop.aabb.size.y > 0.1, "Prop3D collider fitted (%s)" % prop.aabb)
	var qc: QuizCard = comps[3]
	qc.show_question(Q.math("+", 1))
	(comps[8] as DialogueBox).play([{"char": "robo", "text": "Ujian."}])
	(comps[10] as AnalogClock).hour = 9
	ok((comps[10] as AnalogClock).as_text() == "9:00", "clock text")
	for i in 5:
		await get_tree().process_frame
	host.queue_free()
	w3.queue_free()
	print("selftest: %d checks, %d failed (%d ms)" % [checks, fails, Time.get_ticks_msec() - t0])
	get_tree().quit(fails)
