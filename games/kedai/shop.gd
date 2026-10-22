## One shop day: set the opening time, then serve customers. Each customer:
## pick the listed items from the shelf -> choose the total -> give exact change.
## From Tahun 2 one customer orders a fraction of a fruit.
extends Control

var rng := RandomNumberGenerator.new()
var queue: Array = []        # customers + {"fraction": Vector2i} entries
var cur := {}
var served := 0
var sales := 0
var mistakes := 0
var basket: Array = []       # refs
var tray: Array = []         # sen values given as change
var state := ""

var _shelf := GridContainer.new()
var _basket := HBoxContainer.new()
var _bubble := PanelContainer.new()
var _list := VBoxContainer.new()
var _task := PanelContainer.new()
var _who := Character2D.new()
var _hud := Label.new()
var _summary := PanelContainer.new()


func _ready() -> void:
	rng.seed = hash("kedai_%d_%d_%d" % [Kedai.tahun, Kedai.day, Time.get_ticks_usec()])
	KitUtil.background(self, "backgrounds/kampung")
	_build()
	var n := mini(3 + Kedai.day / 3, 6)
	for k in n:
		queue.append(Kedai.customer(rng, Kedai.day))
	if Kedai.tahun >= 2 and Kedai.day >= 2:
		queue.insert(rng.randi_range(1, queue.size()), {"fraction": Kedai.fraction_order(rng), "char": Kedai.CUSTOMERS.pick_random()})
	Audio.music("santai_kampung")
	_clock_task()
	if "--skip-clock" in OS.get_cmdline_user_args():  # docs screenshots of the customer view
		_task.hide()
		_next_customer()
	KitUtil.maybe_shot(self, "kedai_shop" + ("_customer" if "--skip-clock" in OS.get_cmdline_user_args() else ""), 2.0)


# ---------------- layout ----------------
func _build() -> void:
	var title_lbl := Label.new()
	title_lbl.text = "Kedai Runcit Pak Ali"
	title_lbl.theme_type_variation = "LabelHeading"
	title_lbl.add_theme_color_override("font_color", Color("ffd166"))
	title_lbl.add_theme_color_override("font_outline_color", Color("2b2d42"))
	title_lbl.add_theme_constant_override("outline_size", 16)
	title_lbl.position = Vector2(1240, 30)
	title_lbl.size = Vector2(640, 70)
	title_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(title_lbl)
	var home := Button.new()
	home.icon = EduAssets.texture("icons/home")
	home.expand_icon = true
	home.custom_minimum_size = Vector2(88, 88)
	home.position = Vector2(24, 20)
	home.theme_type_variation = "ButtonYellow"
	home.pressed.connect(func(): Audio.sfx("ui_back"); Fader.go(Kedai.SCENES.menu))
	add_child(home)
	_hud.position = Vector2(130, 36)
	_hud.theme_type_variation = "LabelHeading"
	_hud.add_theme_color_override("font_color", Color.WHITE)
	_hud.add_theme_color_override("font_outline_color", Color("2b2d42"))
	_hud.add_theme_constant_override("outline_size", 10)
	add_child(_hud)
	var shelf_panel := PanelContainer.new()
	shelf_panel.theme_type_variation = "PanelCream"
	shelf_panel.position = Vector2(30, 130)
	shelf_panel.size = Vector2(1180, 560)
	add_child(shelf_panel)
	_shelf.columns = 7
	_shelf.add_theme_constant_override("h_separation", 10)
	_shelf.add_theme_constant_override("v_separation", 10)
	shelf_panel.add_child(_shelf)
	for p in Kedai.shelf():
		var b := Button.new()
		b.custom_minimum_size = Vector2(152, 168)
		b.theme_type_variation = "ButtonYellow"
		var bv := VBoxContainer.new()
		bv.set_anchors_preset(Control.PRESET_FULL_RECT)
		bv.offset_top = 8
		bv.offset_bottom = -10
		bv.mouse_filter = Control.MOUSE_FILTER_IGNORE
		b.add_child(bv)
		var pic := TextureRect.new()
		pic.texture = EduAssets.texture(p.ref)
		pic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		pic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		pic.size_flags_vertical = Control.SIZE_EXPAND_FILL
		pic.mouse_filter = Control.MOUSE_FILTER_IGNORE
		bv.add_child(pic)
		var price := Label.new()
		price.text = Kedai.rm(p.price)
		price.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		price.theme_type_variation = "LabelHeading"
		price.add_theme_font_size_override("font_size", 30)
		price.mouse_filter = Control.MOUSE_FILTER_IGNORE
		bv.add_child(price)
		b.tooltip_text = EduAssets.name_of(p.ref)
		b.pressed.connect(_pick.bind(p.ref))
		_shelf.add_child(b)
	var counter := PanelContainer.new()
	counter.theme_type_variation = "PanelBlue"
	counter.position = Vector2(30, 710)
	counter.size = Vector2(1180, 150)
	add_child(counter)
	var ch := HBoxContainer.new()
	counter.add_child(ch)
	var bl := Label.new()
	bl.text = GameState.tr2("Kaunter:", "Counter:")
	bl.theme_type_variation = "LabelOnDark"
	ch.add_child(bl)
	_basket.add_theme_constant_override("separation", 6)
	_basket.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	ch.add_child(_basket)
	var clear := Button.new()
	clear.text = GameState.tr2("Kosongkan", "Clear")
	clear.theme_type_variation = "ButtonRed"
	clear.pressed.connect(func(): basket.clear(); _refresh(); Audio.sfx("whoosh"))
	ch.add_child(clear)
	_who.position = Vector2(1640, 1060)
	_who.height_px = 480
	add_child(_who)
	_bubble.theme_type_variation = "PanelCream"
	_bubble.position = Vector2(1240, 130)
	_bubble.custom_minimum_size = Vector2(640, 0)
	_list.add_theme_constant_override("separation", 8)
	_bubble.add_child(_list)
	add_child(_bubble)
	_task.theme_type_variation = "PanelCream"
	_task.position = Vector2(30, 600)
	_task.custom_minimum_size = Vector2(1180, 0)
	_task.hide()
	add_child(_task)
	_summary.theme_type_variation = "PanelCream"
	_summary.position = Vector2(560, 220)
	_summary.custom_minimum_size = Vector2(800, 0)
	_summary.hide()
	add_child(_summary)


func _refresh() -> void:
	_hud.text = "%s %d · %s %d/%d · %s %s" % [GameState.tr2("Hari", "Day"), Kedai.day, GameState.tr2("Pelanggan", "Customer"),
		mini(served + 1, queue.size()), queue.size(), GameState.tr2("Jualan", "Sales"), MoneyItem.format_rm(sales)]
	for c in _basket.get_children():
		c.queue_free()
	for r in basket:
		var t := TextureRect.new()
		t.texture = EduAssets.texture(r)
		t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		t.custom_minimum_size = Vector2(100, 100)
		_basket.add_child(t)
	for c in _list.get_children():
		c.queue_free()
	if cur.is_empty():
		_bubble.hide()
		return
	_bubble.show()
	var head := Label.new()
	head.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	head.theme_type_variation = "LabelHeading"
	_list.add_child(head)
	if cur.has("fraction"):
		head.text = GameState.tr2("Saya mahu %d/%d tembikai.", "I'd like %d/%d of a watermelon.") % [cur.fraction.x, cur.fraction.y]
		return
	head.text = GameState.tr2("Saya mahu beli:", "I'd like to buy:")
	for it in cur["items"]:
		var h := HBoxContainer.new()
		var t := TextureRect.new()
		t.texture = EduAssets.texture(it.ref)
		t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		t.custom_minimum_size = Vector2(90, 90)
		h.add_child(t)
		var l := Label.new()
		var have := basket.count(it.ref)
		l.text = "%s x%d  %s" % [EduAssets.name_of(it.ref), it.qty, "✓" if have >= it.qty else ""]
		l.theme_type_variation = "LabelHeading"
		l.add_theme_color_override("font_color", Color("2d936c") if have >= it.qty else Color("2b2d42"))
		h.add_child(l)
		_list.add_child(h)
	if cur.discount > 0:
		var d := Label.new()
		d.text = GameState.tr2("Diskaun %d%% untuk semua!", "%d%% off everything!") % cur.discount
		d.add_theme_color_override("font_color", Color("ef476f"))
		d.theme_type_variation = "LabelHeading"
		_list.add_child(d)


func _task_box() -> VBoxContainer:
	for c in _task.get_children():
		_task.remove_child(c)
		c.queue_free()
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 14)
	_task.add_child(v)
	_task.show()
	return v


func _title(v: Control, text: String) -> void:
	var l := Label.new()
	l.text = text
	l.theme_type_variation = "LabelHeading"
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	l.custom_minimum_size.x = 300
	v.add_child(l)


# ---------------- opening time ----------------
func _clock_task() -> void:
	state = "clock"
	var want := Kedai.opening_time(rng)
	_who.char_id = "rahman"
	var v := _task_box()
	_task.position = Vector2(360, 180)
	var how := GameState.tr2("(guna butang anak panah)", "(use the arrow buttons)") if Kedai.tahun == 1 else GameState.tr2("(seret jarum minit)", "(drag the minute hand)")
	_title(v, GameState.tr2("Kedai buka pukul %d:%02d. Laraskan jam! ", "The shop opens at %d:%02d. Set the clock! ") % [want.x, want.y] + how)
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 40)
	v.add_child(row)
	var clock := AnalogClock.new()
	clock.interactive = true
	clock.snap_minutes = 60 if Kedai.tahun == 1 else (30 if Kedai.tahun == 2 else 5)
	clock.hour = (want.x + 2) % 12 + 1 if Kedai.tahun > 1 else want.x
	clock.minute = 0 if Kedai.tahun == 1 else 15 * rng.randi_range(0, 3) % 60
	clock.custom_minimum_size = Vector2(420, 420)
	row.add_child(clock)
	if Kedai.tahun == 1:
		# whole hours: buttons move the hour hand instead of dragging minutes
		var hb := VBoxContainer.new()
		for d in [-1, 1]:
			var b := Button.new()
			b.icon = EduAssets.texture("icons/" + ("up" if d > 0 else "down"))
			b.expand_icon = true
			b.custom_minimum_size = Vector2(120, 120)
			b.pressed.connect(func(): clock.hour = (clock.hour + d + 11) % 12 + 1; Audio.sfx("countdown_tick"))
			hb.add_child(b)
		row.add_child(hb)
		clock.hour = want.x + (2 if want.x < 9 else -2)
	var go := Button.new()
	go.text = GameState.tr2("Buka kedai", "Open the shop")
	go.theme_type_variation = "ButtonGreen"
	go.custom_minimum_size = Vector2(0, 96)
	go.pressed.connect(func():
		if clock.hour % 12 == want.x % 12 and clock.minute == want.y:
			Feedback.result(self, true, false)
			Audio.say("feedback", "shop_open")
			_task.hide()
			_task.position = Vector2(30, 600)
			_next_customer()
		else:
			mistakes += 1
			Feedback.result(self, false))
	v.add_child(go)
	Audio.say("feedback", "shop_clock")
	_refresh()


# ---------------- customers ----------------
func _next_customer() -> void:
	basket.clear()
	tray.clear()
	if served >= queue.size():
		_end_day()
		return
	cur = queue[served]
	_who.char_id = cur.char
	_who.expression = "happy"
	_who.position.x = 2100
	create_tween().tween_property(_who, "position:x", 1640.0, 0.6).set_trans(Tween.TRANS_BACK)
	Audio.sfx("notification")
	if cur.has("fraction"):
		_fraction_task()
	else:
		state = "list"
		_task.hide()
		Audio.say("feedback", "shop_list")
	_refresh()


func _pick(ref: String) -> void:
	if state != "list":
		return
	var want := 0
	for it in cur["items"]:
		if it.ref == ref:
			want = it.qty
	if basket.count(ref) >= want:
		mistakes += 1
		Audio.sfx("wrong")
		Audio.say("feedback", "shop_wrong_item")
		_who.react(false)
		return
	Audio.sfx("pop", 0.1)
	basket.append(ref)
	_refresh()
	if cur["items"].all(func(it): return basket.count(it.ref) >= it.qty):
		_total_task()


func _total_task() -> void:
	state = "total"
	var v := _task_box()
	_title(v, GameState.tr2("Berapakah jumlah harganya?", "What is the total price?") + ("  (" + GameState.tr2("selepas diskaun", "after discount") + ")" if cur.discount > 0 else ""))
	var g := GridContainer.new()
	g.columns = 4
	g.add_theme_constant_override("h_separation", 12)
	v.add_child(g)
	var choices := Kedai.total_choices(cur.total, rng)
	for i in choices.size():
		var b := AnswerButton.new()
		b.index = i
		b.text = Kedai.rm(choices[i])
		b.custom_minimum_size = Vector2(270, 110)
		b.pressed.connect(func():
			if choices[i] == cur.total:
				b.mark(true)
				Audio.sfx("correct")
				await get_tree().create_timer(0.6).timeout
				_change_task()
			else:
				mistakes += 1
				b.mark(false)
				Audio.sfx("wrong"))
		g.add_child(b)
	Audio.say("feedback", "shop_total")


func _change_task() -> void:
	state = "change"
	sales += cur.total
	if cur.change == 0:
		Audio.say("feedback", "shop_exact")
		_done_customer()
		return
	var v := _task_box()
	var top := HBoxContainer.new()
	top.add_theme_constant_override("separation", 20)
	v.add_child(top)
	_title(top, GameState.tr2("Pelanggan bayar %s. Jumlah %s. Beri baki!", "Customer pays %s. Total %s. Give the change!") % [Kedai.rm(cur.paid), Kedai.rm(cur.total)])
	var paid := MoneyItem.new()
	paid.value_sen = cur.paid
	paid.draggable = false
	paid.mouse_filter = Control.MOUSE_FILTER_IGNORE
	top.add_child(paid)
	var drawer := HBoxContainer.new()
	drawer.add_theme_constant_override("separation", 8)
	v.add_child(drawer)
	var tray_row := HBoxContainer.new()
	v.add_child(tray_row)
	var sum := Label.new()
	sum.theme_type_variation = "LabelHeading"
	sum.custom_minimum_size = Vector2(320, 0)
	tray_row.add_child(sum)
	var tray_box := HFlowContainer.new()
	tray_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tray_row.add_child(tray_box)
	var redraw := func():
		for c in tray_box.get_children():
			c.queue_free()
		var s := 0
		for i in tray.size():
			s += tray[i]
			var m := MoneyItem.new()
			m.value_sen = tray[i]
			m.draggable = false
			m.scale = Vector2(0.7, 0.7)
			m.pressed.connect(func(): tray.remove_at(i); _redraw_change.call())
			tray_box.add_child(m)
		sum.text = GameState.tr2("Baki: %s", "Change: %s") % Kedai.rm(s)
	_redraw_change = redraw
	for v_sen in Kedai.drawer():
		var m := MoneyItem.new()
		m.value_sen = v_sen
		m.draggable = false
		m.pressed.connect(func(): tray.append(v_sen); _redraw_change.call())
		drawer.add_child(m)
	var give := Button.new()
	give.text = GameState.tr2("Beri baki", "Give change")
	give.theme_type_variation = "ButtonGreen"
	give.custom_minimum_size = Vector2(300, 90)
	give.pressed.connect(func():
		var s: int = tray.reduce(func(a, b): return a + b, 0)
		if s == cur.change:
			Feedback.result(self, true, false)
			_done_customer()
		else:
			mistakes += 1
			Feedback.result(self, false, false)
			Feedback.float_text(self, GameState.tr2("Terlebih!", "Too much!") if s > cur.change else GameState.tr2("Tak cukup!", "Not enough!"), Vector2(500, 560), Color("ef476f")))
	tray_row.add_child(give)
	_redraw_change.call()
	Audio.say("feedback", "shop_change")


var _redraw_change := func(): pass


func _fraction_task() -> void:
	state = "fraction"
	var v := _task_box()
	_task.position = Vector2(30, 140)
	var f: Vector2i = cur.fraction
	_title(v, GameState.tr2("Potong tembikai: ketik bahagian untuk menunjukkan %d/%d", "Cut the watermelon: tap the slices to show %d/%d") % [f.x, f.y])
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 40)
	v.add_child(row)
	var pic := TextureRect.new()
	pic.texture = EduAssets.texture("bahasa_melayu/tembikai")
	pic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	pic.custom_minimum_size = Vector2(260, 260)
	row.add_child(pic)
	var pie := FractionPie.new()
	pie.denominator = f.y
	pie.numerator = 0
	pie.interactive = true
	pie.fill_color = Color("ef476f")
	pie.custom_minimum_size = Vector2(380, 380)
	row.add_child(pie)
	var cut := Button.new()
	cut.text = GameState.tr2("Potong!", "Cut!")
	cut.theme_type_variation = "ButtonGreen"
	cut.custom_minimum_size = Vector2(0, 96)
	cut.pressed.connect(func():
		if pie.numerator == f.x:
			Feedback.result(self, true)
			_task.position = Vector2(30, 600)
			_done_customer()
		else:
			mistakes += 1
			Feedback.result(self, false))
	v.add_child(cut)
	Audio.say("feedback", "shop_fraction")


func _done_customer() -> void:
	state = "done"
	_task.hide()
	_who.expression = "happy"
	_who.react(true)
	Audio.say("feedback", "shop_thanks")
	served += 1
	cur = {}
	basket.clear()
	_refresh()
	await get_tree().create_timer(1.2).timeout
	_next_customer()


# ---------------- end of day ----------------
func _end_day() -> void:
	state = "end"
	_bubble.hide()
	var stars := 3 if mistakes == 0 else (2 if mistakes <= 2 else 1)
	GameState.record_level(Kedai.game_id(), Kedai.day, stars, sales)
	var earned := sales / 100
	GameState.coins += earned
	GameState.save()
	for c in _summary.get_children():
		c.queue_free()
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 16)
	_summary.add_child(v)
	_title(v, GameState.tr2("Kedai ditutup! Hasil jualan hari ini: %s", "Shop closed! Today's sales: %s") % MoneyItem.format_rm(sales))
	var sr := StarRating.new()
	v.add_child(sr)
	sr.set_stars(stars)
	_title(v, GameState.tr2("Kesilapan: %d · Duit simpanan: RM%d", "Mistakes: %d · Savings: RM%d") % [mistakes, GameState.coins])
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 20)
	v.add_child(row)
	var next := Button.new()
	next.text = GameState.tr2("Hari seterusnya", "Next day")
	next.theme_type_variation = "ButtonGreen"
	next.custom_minimum_size = Vector2(300, 96)
	next.pressed.connect(func(): Kedai.day = mini(Kedai.day + 1, Kedai.DAYS); get_tree().reload_current_scene())
	row.add_child(next)
	var menu := Button.new()
	menu.text = "Menu"
	menu.theme_type_variation = "ButtonBlue"
	menu.custom_minimum_size = Vector2(300, 96)
	menu.pressed.connect(func(): Fader.go(Kedai.SCENES.menu))
	row.add_child(menu)
	_summary.show()
	Audio.say("feedback", "shop_day_end")
	Audio.music("jingle_menang" if stars >= 2 else "jingle_cuba_lagi", 0.2)
	if stars == 3:
		Feedback.confetti(self, Vector2(960, 300), 80)
