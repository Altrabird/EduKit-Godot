## godot --headless --path . res://games/kedai/test_kedai.tscn  (exit code = failures)
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
	var keep_coins: int = GameState.coins
	GameState.progress = {"kedai_upgrades": {"roti": true, "minuman": true, "gerai": true}}
	var rng := RandomNumberGenerator.new()
	rng.seed = 42
	for t in range(1, 5):
		var step: int = [100, 50, 10, 5][t - 1]
		for p in Kedai.shelf(t):
			ok(p.price % step == 0 and p.price > 0, "T%d price step %s %d" % [t, p.ref, p.price])
		for d in range(1, Kedai.DAYS + 1):
			for k in 60:
				var c := Kedai.customer(rng, d, t)
				ok(c.total > 0 and c.total <= Kedai.max_total(t), "T%d total in range %d" % [t, c.total])
				ok(c.paid >= c.total and c.change == c.paid - c.total, "T%d payment covers total" % t)
				ok(Kedai.payable(c.change, t), "T%d change %d payable from drawer" % [t, c.change])
				ok(c.discount == 0 or t == 4, "discount only in Tahun 4")
				var sum := 0
				for it in c["items"]:
					sum += it.price * it.qty
				ok(c.discount > 0 or sum == c.total, "T%d total adds up" % t)
				var ch := Kedai.total_choices(c.total, rng, t)
				var u := {}
				for x in ch:
					u[x] = true
				ok(ch.size() == 4 and c.total in ch and u.size() == 4 and ch.all(func(x): return x > 0), "T%d total choices %s" % [t, ch])
		for k in 30:
			var f := Kedai.fraction_order(rng, t)
			ok(f.x > 0 and f.x < f.y, "fraction %s" % f)
			var o := Kedai.opening_time(rng, t)
			ok(o.y % [60, 30, 5, 5][t - 1] == 0 or (t == 1 and o.y == 0), "opening time step T%d %s" % [t, o])
	ok(Kedai.rm(1250) == "RM12.50", "rm format")
	# scripted day: Tahun 3, day 4 (fraction customer included), every answer right
	Engine.time_scale = 8.0
	Kedai.tahun = 3
	Kedai.day = 4
	var shop: Control = load("res://games/kedai/shop.tscn").instantiate()
	get_tree().root.add_child(shop)
	await get_tree().process_frame
	ok(shop.state == "clock", "day starts with the clock")
	shop._task.hide()
	shop._next_customer()
	var expected := 0
	var guard := 0
	while shop.state != "end" and guard < 3000:
		guard += 1
		await get_tree().process_frame
		match shop.state:
			"list":
				for it in shop.cur["items"]:
					while shop.basket.count(it.ref) < it.qty:
						shop._pick(it.ref)
				expected += shop.cur.total
			"total":
				var btns := _find(shop._task, AnswerButton).filter(func(b): return b.text == Kedai.rm(shop.cur.total) and not b.disabled)
				if not btns.is_empty():
					btns[0].pressed.emit()
					await get_tree().create_timer(1.0).timeout
			"change":
				if shop.tray.is_empty() and shop.cur.get("change", 0) > 0:
					var left: int = shop.cur.change
					var d := Kedai.drawer()
					d.reverse()
					for v in d:
						while v <= left:
							shop.tray.append(v)
							left -= v
					var give := _find(shop._task, Button).filter(func(b): return b.text == GameState.tr2("Beri baki", "Give change"))
					give[0].pressed.emit()
			"fraction":
				var pie: FractionPie = _find(shop._task, FractionPie)[0]
				pie.numerator = shop.cur.fraction.x
				_find(shop._task, Button).filter(func(b): return b.text == GameState.tr2("Potong!", "Cut!"))[0].pressed.emit()
				await get_tree().create_timer(0.5).timeout
	ok(shop.state == "end", "day finished")
	ok(shop.mistakes == 0 and shop.sales == expected, "no mistakes, sales %d == %d" % [shop.sales, expected])
	ok(GameState.stars_for("kedai_t3", 4) == 3, "3 stars recorded")
	ok(GameState.coins == keep_coins + expected / 100, "savings grew")
	shop.queue_free()
	Engine.time_scale = 1.0
	GameState.progress = keep
	GameState.coins = keep_coins
	GameState.save()
	print("test_kedai: %d checks, %d failed" % [checks, fails])
	get_tree().quit(fails)


func _find(n: Node, type) -> Array:
	var out := []
	for c in n.get_children():
		if is_instance_of(c, type):
			out.append(c)
		out += _find(c, type)
	return out
