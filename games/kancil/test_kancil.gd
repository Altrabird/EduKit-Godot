## godot --headless --path . res://games/kancil/test_kancil.tscn  (exit code = failures)
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
	for m in ["ms", "en"]:
		ok(Kancil.level_count(m) >= 10, "%s has >= 10 levels" % m)
		for lv in range(1, Kancil.level_count(m) + 1):
			var d: Dictionary = Kancil.build(lv, m)
			ok(Kancil.check(d) == "", "%s L%d terrain: %s" % [m, lv, Kancil.check(d)])
			var words := Kancil.level_words(lv, m)
			var parts: Array = d.items.filter(func(i): return i.type == "part")
			var n := 0
			for w in words:
				n += w.parts.size()
				ok(ResourceLoader.exists("res://assets/audio/voice/%s/words/%s.mp3" % [m, w.word]), "word voice %s" % w.word)
				for p in w.parts:
					ok(ResourceLoader.exists("res://assets/audio/voice/%s/%s/%s.mp3" % [m, "syllables" if m == "ms" else "letters", p]), "part voice %s" % p)
				ok(EduAssets.has(w.img), "picture %s" % w.img)
			ok(parts.size() == n, "%s L%d all parts placed" % [m, lv])
			ok(d.items.filter(func(i): return i.type == "gate").size() == words.size(), "%s L%d one gate per word" % [m, lv])
			ok(d.items.filter(func(i): return i.type == "flag").size() == 1, "flag")
			for dec in d.items.filter(func(i): return i.type == "decoy"):
				ok(not dec.text in words[dec.word].parts, "decoy differs from word parts")
	ok(Kancil.check({"heights": [3, 0, 0, 0, 0, 3], "items": []}) != "", "check catches wide pit")
	ok(Kancil.check({"heights": [2, 5], "items": []}) != "", "check catches tall step")
	# scripted run: collect everything, spell both words, finish
	GameState.progress = {}
	Kancil.mode = "ms"
	Kancil.level = 7
	var lvl: Node2D = load("res://games/kancil/level.tscn").instantiate()
	get_tree().root.add_child(lvl)
	await get_tree().process_frame
	await get_tree().process_frame
	for wi in lvl.words.size():
		for p in lvl.words[wi].parts:
			lvl.collected.append({"text": p, "word": wi, "decoy": false})
		lvl._open_panel(wi)
		ok(get_tree().paused, "panel pauses the game")
		var tray: Array = lvl._panel.get_child(0).get_child(3).get_children()
		var wrong: TextTile = tray.filter(func(t): return not t.key in lvl.words[wi].parts)[0]
		lvl._slots[0]._drop_data(Vector2.ZERO, {"key": wrong.key, "node": wrong})
		ok(lvl.errors == 1 + wi, "wrong drop counted")
		var used := []
		for s in lvl._slots:
			var t: TextTile = tray.filter(func(x): return x.key == s.accept_key and not x in used)[0]
			used.append(t)
			s._drop_data(Vector2.ZERO, {"key": t.key, "node": t})
		await get_tree().create_timer(2.0, true).timeout
		ok(wi in lvl.solved and not get_tree().paused, "word %d solved and game resumed" % wi)
		ok(lvl.map.get_cell_source_id(lvl._gate_cells[wi][0]) == -1, "gate %d opened" % wi)
	lvl._finish()
	ok(GameState.stars_for("kancil_ms", 7) >= 2, "stars recorded (%d)" % GameState.stars_for("kancil_ms", 7))
	get_tree().paused = false
	lvl.queue_free()
	GameState.progress = keep
	GameState.save()
	print("test_kancil: %d checks, %d failed" % [checks, fails])
	get_tree().quit(fails)
