## godot --headless --path . res://games/makmal/test_makmal.tscn  (exit code = failures)
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


func _run() -> void:
	await get_tree().process_frame
	var keep: Dictionary = GameState.progress.duplicate(true)
	GameState.progress = {}
	Engine.time_scale = 8.0
	# rules
	for i in Makmal.PLANETS.size():
		ok(Makmal.ring_at(Makmal.ring_radius(i)) == i, "ring %d" % i)
		ok(Makmal.ring_at(Makmal.ring_radius(i) + 0.37) == -1 or i == Makmal.PLANETS.size() - 1, "between rings -> none")
		ok(EduAssets.model_entry("sains/planet_" + Makmal.PLANETS[i]).size() > 0, "planet model %s" % Makmal.PLANETS[i])
	for k in Makmal.LIFECYCLES:
		for r in Makmal.LIFECYCLES[k][0]:
			ok(EduAssets.has(r), "lifecycle art %s" % r)
	ok(Makmal.MAGNET_OBJECTS.filter(func(o): return o[1]).size() >= 4 and Makmal.MAGNET_OBJECTS.filter(func(o): return not o[1]).size() >= 4, "magnet objects both kinds")
	for o in Makmal.MAGNET_OBJECTS:
		ok(EduAssets.has(o[0]), "magnet art %s" % o[0])
	for r in Makmal.PARTS:
		ok(EduAssets.has(r), "circuit art %s" % r)
	for m in Makmal.MISSIONS:
		ok(EduAssets.model_entry(m[4]).size() > 0 and ResourceLoader.exists(m[1]), "mission %s" % m[0])
	ok(Makmal.circuit_result(0, ["sains/battery", "rbt/suis", "sains/light_bulb"], true) == "", "bulb circuit works")
	ok(Makmal.circuit_result(0, ["sains/battery", "rbt/suis", "sains/light_bulb"], false) == "switch_off", "switch off")
	ok(Makmal.circuit_result(0, ["sains/battery", "icons/pencil", "sains/light_bulb"], true) == "insulator", "pencil insulates")
	ok(Makmal.circuit_result(0, ["sains/battery", "rbt/suis", ""], true) == "open", "gap is open")
	ok(Makmal.circuit_result(2, ["sains/battery", "rbt/suis", "rbt/led", "rbt/motor"], true) == "missing_resistor", "LED needs resistor")
	ok(Makmal.circuit_result(2, ["rbt/perintang", "rbt/suis", "rbt/led", "sains/battery"], true) == "", "LED + resistor works")
	ok(Makmal.plant_grows(true, true) == "healthy" and Makmal.plant_grows(false, true) == "wilted" and Makmal.plant_grows(true, false) == "pale", "plant rules")
	# hub loads
	var hub: Node = await _scene(Makmal.HUB)
	ok(hub.get_children().filter(func(c): return c is Prop3D).size() >= 10, "hub props")
	hub.queue_free()
	# solar: one wrong, then all right
	var solar: Node = await _scene("res://games/makmal/solar.tscn")
	solar._select("earth")
	solar._place("earth", 0)
	ok(solar.mistakes == 1 and not "earth" in solar.placed, "wrong orbit rejected")
	for id in Makmal.PLANETS:
		solar._select(id)
		solar._place(id, Makmal.PLANETS.find(id))
	await get_tree().create_timer(3.0).timeout
	ok(solar.placed.size() == 8 and GameState.stars_for(Makmal.GAME, 1) == 2, "solar done, 1 mistake -> 2 stars")
	solar.queue_free()
	# lifecycle: drop everything right
	var lc: Node = await _scene("res://games/makmal/lifecycle.tscn")
	for round_i in 3:
		for s in lc._slots:
			var card := PictureCard.new()
			card.ref = s.accept_key
			lc._row_cards.add_child(card)
			s._drop_data(Vector2.ZERO, {"key": s.accept_key, "node": card})
		await get_tree().create_timer(2.0).timeout
	ok(GameState.stars_for(Makmal.GAME, 2) == 3, "lifecycle 3 stars")
	lc.queue_free()
	# magnet: sort every card into its true bin
	var mg: Node = await _scene("res://games/makmal/magnet.tscn")
	var bins: Array = mg._bins.get_children()
	for card in mg._items.get_children().duplicate():
		var magnetic: bool = card.get_meta("magnetic")
		var bin = bins.filter(func(b): return b.attracted == magnetic)[0]
		bin._drop_data(Vector2.ZERO, {"key": card.ref, "node": card})
	await _frames()
	ok(GameState.stars_for(Makmal.GAME, 3) == 3, "magnet 3 stars")
	mg.queue_free()
	# circuit: insulator first (mistake), then the three correct circuits
	var cc: Node = await _scene("res://games/makmal/circuit.tscn")
	var sols := [["sains/battery", "rbt/suis", "sains/light_bulb"], ["sains/battery", "rbt/suis", "rbt/motor"], ["sains/battery", "rbt/suis", "rbt/led", "rbt/perintang"]]
	for lv in 3:
		if lv == 0:
			for i in 3:
				var bad: String = ["sains/battery", "icons/pencil", "sains/light_bulb"][i]
				cc._slots[i]._drop_data(Vector2.ZERO, {"key": bad, "node": null})
			cc._flip()
			ok(cc.mistakes == 1, "insulator circuit fails")
		for i in sols[lv].size():
			cc._slots[i]._drop_data(Vector2.ZERO, {"key": sols[lv][i], "node": null})
		cc._flip()
		await get_tree().create_timer(2.6).timeout
	ok(cc.level == 3 and GameState.stars_for(Makmal.GAME, 4) == 2, "circuits done (level %d)" % cc.level)
	cc.queue_free()
	# plant: predict A, watch, answer
	var pl: Node = await _scene("res://games/makmal/plant.tscn")
	pl._ask.get_child(0).pressed.emit()
	await get_tree().create_timer(6.5).timeout
	pl._ask.get_children().filter(func(b): return not b.is_queued_for_deletion())[0].pressed.emit()
	await _frames()
	ok(GameState.stars_for(Makmal.GAME, 5) == 3, "plant 3 stars")
	pl.queue_free()
	Engine.time_scale = 1.0
	GameState.progress = keep
	GameState.save()
	print("test_makmal: %d checks, %d failed" % [checks, fails])
	get_tree().quit(fails)
