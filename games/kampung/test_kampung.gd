## godot --headless --path . res://games/kampung/test_kampung.tscn  (exit code = failures)
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


func _frames(n := 3) -> void:
	for k in n:
		await get_tree().process_frame


func _scene(path: String) -> Node:
	var s: Node = load(path).instantiate()
	get_tree().root.add_child(s)
	await _frames()
	return s


func _find(n: Node, pred: Callable) -> Array:
	var out := []
	for c in n.get_children():
		if pred.call(c):
			out.append(c)
		out += _find(c, pred)
	return out


func _run() -> void:
	await get_tree().process_frame
	var keep: Dictionary = GameState.progress.duplicate(true)
	GameState.progress = {}
	Engine.time_scale = 8.0
	for r in Kampung.PLATE.keys() + Kampung.RECYCLE.keys() + Kampung.RAYA_YES + Kampung.RAYA_NO:
		ok(EduAssets.has(r), "art %s" % r)
	for h in Kampung.HELP:
		ok(EduAssets.has(h[2]) and h[1].size() == 3, "help scenario %s" % h[0][0])
	for a in Kampung.ACTIVITIES:
		ok(EduAssets.has(a[4]) and ResourceLoader.exists(a[1]), "activity %s" % a[0])
	ok(Kampung.mix_ok("hijau", "kuning", "biru") and not Kampung.mix_ok("hijau", "merah", "biru") and not Kampung.mix_ok("ungu", "merah", "merah"), "colour mixing")
	ok(is_equal_approx(Kampung.saturation(), 0.12), "village starts grey")
	ok(ResourceLoader.exists("res://assets/audio/sfx/kompang_dum.wav") and ResourceLoader.exists("res://assets/audio/sfx/kompang_pak.wav"), "kompang sounds")
	# plate + recycle: drop every card into its zone
	for p in ["res://games/kampung/plate.tscn", "res://games/kampung/recycle.tscn"]:
		var s: Node = await _scene(p)
		var zones: Array = s._zones.get_children()
		var first: PictureCard = s._cards.get_child(0)
		var wrong_zone = zones.filter(func(z): return z.category != z.answers[first.ref])[0]
		wrong_zone._drop_data(Vector2.ZERO, {"key": first.ref, "node": first})
		ok(s.mistakes == 1, "%s wrong zone counted" % p)
		for card in s._cards.get_children().duplicate():
			var z = zones.filter(func(zz): return zz.category == zz.answers[card.ref])[0]
			z._drop_data(Vector2.ZERO, {"key": card.ref, "node": card})
		await _frames()
		ok(GameState.stars_for(Kampung.GAME, s.index + 1) == 2, "%s finished with 2 stars" % p)
		s.queue_free()
	# wash: steps in order with the scrub in the middle
	var w: Node = await _scene("res://games/kampung/wash.tscn")
	for i in Kampung.WASH_STEPS.size():
		if i == 3:
			ok(w._scrubbing, "scrubbing started after step 3")
			w.skip_scrub()
			await _frames(3)
			continue
		var b: Button = w._steps.get_children().filter(func(x): return x.text == Kampung.WASH_STEPS[i][0])[0]
		w._tap_step(i, b)
	await _frames()
	ok(GameState.stars_for(Kampung.GAME, 3) == 3, "wash 3 stars")
	w.queue_free()
	# help: always the kind choice
	var h: Node = await _scene("res://games/kampung/help.tscn")
	for i in Kampung.HELP.size():
		var right: String = Kampung.HELP[i][1][0][0]
		var b: AnswerButton = h._choices.get_children().filter(func(x): return x.text == right and not x.is_queued_for_deletion())[0]
		b.pressed.emit()
		await get_tree().create_timer(1.3).timeout
	ok(GameState.stars_for(Kampung.GAME, 4) == 3, "help 3 stars")
	h.queue_free()
	# PI: wudhu order then the Raya items
	var pi: Node = await _scene("res://games/kampung/pi.tscn")
	for i in Kampung.WUDHU.size():
		var b: Button = pi._row.get_children().filter(func(x): return x is Button and x.text == Kampung.WUDHU[i][0])[0]
		pi._tap(i, b)
	await get_tree().create_timer(1.3).timeout
	ok(pi._phase == "raya", "raya phase")
	for r in Kampung.RAYA_YES:
		pi._picked[r] = true
	pi.check_raya()
	await _frames()
	ok(GameState.stars_for(Kampung.GAME, 5) == 3, "PI 3 stars")
	pi.queue_free()
	# art: three rhythms then three colour mixes
	var art: Node = await _scene("res://games/kampung/art.tscn")
	for r in 3:
		for c in Kampung.RHYTHMS[r]:
			art.hit(c)
		await get_tree().create_timer(1.0).timeout
	for t in Kampung.MIXES.keys():
		ok(art._target == t, "colour round %s" % t)
		for c in Kampung.MIXES[t]:
			art.pick_colour(c, Button.new())
		await get_tree().create_timer(1.2).timeout
	await _frames()
	ok(GameState.stars_for(Kampung.GAME, 6) == 3, "art 3 stars")
	art.queue_free()
	ok(Kampung.done_count() == 6 and is_equal_approx(Kampung.saturation(), 1.0), "village fully coloured")
	var m: Node = await _scene(Kampung.MAP)
	ok(m.get_children().filter(func(c): return c is Button).size() >= 6, "map markers")
	m.queue_free()
	Engine.time_scale = 1.0
	GameState.progress = keep
	GameState.save()
	print("test_kampung: %d checks, %d failed" % [checks, fails])
	get_tree().quit(fails)
