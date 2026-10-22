## Title, Tahun (money level), 10-day map and shop upgrades bought with savings.
extends Control

static var _tapped := false

var _days := GridContainer.new()
var _tahun_btns: Array[Button] = []
var _savings := Label.new()
var _upgrades := VBoxContainer.new()


func _ready() -> void:
	KitUtil.background(self, "backgrounds/kampung")
	var ali := Character2D.new()
	ali.char_id = "rahman"
	ali.expression = "happy"
	ali.height_px = 520
	ali.position = Vector2(1700, 1060)
	add_child(ali)
	var v := VBoxContainer.new()
	v.set_anchors_preset(Control.PRESET_FULL_RECT)
	v.offset_left = 60; v.offset_top = 30; v.offset_right = -420; v.offset_bottom = -30
	v.add_theme_constant_override("separation", 18)
	add_child(v)
	var t := Label.new()
	t.text = "Kedai Runcit Pak Ali"
	t.theme_type_variation = "LabelTitle"
	t.add_theme_font_size_override("font_size", 88)
	t.add_theme_color_override("font_color", Color("ffd166"))
	t.add_theme_color_override("font_outline_color", Color("2b2d42"))
	t.add_theme_constant_override("outline_size", 18)
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(t)
	var sub := Label.new()
	sub.text = GameState.tr2("Wang · Baki · Masa · Pecahan", "Money · Change · Time · Fractions")
	sub.theme_type_variation = "LabelHeading"
	sub.add_theme_color_override("font_color", Color.WHITE)
	sub.add_theme_color_override("font_outline_color", Color("2b2d42"))
	sub.add_theme_constant_override("outline_size", 10)
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(sub)
	var th := HBoxContainer.new()
	th.alignment = BoxContainer.ALIGNMENT_CENTER
	th.add_theme_constant_override("separation", 14)
	v.add_child(th)
	for k in range(1, 5):
		var b := Button.new()
		b.text = GameState.tr2("Tahun %d", "Year %d") % k
		b.custom_minimum_size = Vector2(220, 88)
		b.pressed.connect(func(): Audio.sfx("ui_click"); Kedai.tahun = k; _refresh())
		th.add_child(b)
		_tahun_btns.append(b)
	_days.columns = 5
	_days.add_theme_constant_override("h_separation", 30)
	_days.add_theme_constant_override("v_separation", 20)
	var cc := CenterContainer.new()
	cc.size_flags_vertical = Control.SIZE_EXPAND_FILL
	cc.add_child(_days)
	v.add_child(cc)
	var shop := PanelContainer.new()
	shop.theme_type_variation = "PanelCream"
	shop.position = Vector2(1480, 40)
	shop.custom_minimum_size = Vector2(410, 0)
	add_child(shop)
	shop.add_child(_upgrades)
	_upgrades.add_theme_constant_override("separation", 10)
	var home := Button.new()
	home.text = GameState.tr2("BM / EN", "BM / EN")
	home.theme_type_variation = "ButtonTeal"
	home.position = Vector2(30, 30)
	home.pressed.connect(func(): GameState.lang = "en" if GameState.lang == "ms" else "ms"; get_tree().reload_current_scene())
	add_child(home)
	_refresh()
	if not _tapped:
		var o := ColorRect.new()
		o.color = Color(0.1, 0.08, 0.05, 0.7)
		o.set_anchors_preset(Control.PRESET_FULL_RECT)
		var l := Label.new()
		l.text = GameState.tr2("Ketik untuk bermula", "Tap to start")
		l.theme_type_variation = "LabelTitle"
		l.add_theme_color_override("font_color", Color.WHITE)
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		l.position = Vector2(460, 480)
		l.size = Vector2(1000, 120)
		o.add_child(l)
		o.gui_input.connect(func(e):
			if (e is InputEventMouseButton or e is InputEventScreenTouch) and e.pressed:
				_tapped = true
				o.queue_free()
				Audio.music("santai_kampung"))
		add_child(o)
	else:
		Audio.music("santai_kampung")
	KitUtil.maybe_shot(self, "kedai_menu", 1.5)


func _refresh() -> void:
	for i in _tahun_btns.size():
		_tahun_btns[i].theme_type_variation = "ButtonYellow" if i + 1 == Kedai.tahun else "ButtonPurple"
	for c in _days.get_children():
		c.queue_free()
	for d in range(1, Kedai.DAYS + 1):
		var b := LevelButton.new()
		b.game_id = Kedai.game_id()
		b.level = d
		b.chosen.connect(func(l): Kedai.day = l; Fader.go(Kedai.SCENES.shop))
		_days.add_child(b)
	for c in _upgrades.get_children():
		c.queue_free()
	var h := Label.new()
	h.text = GameState.tr2("Naik taraf kedai", "Shop upgrades")
	h.theme_type_variation = "LabelHeading"
	_upgrades.add_child(h)
	_savings.text = GameState.tr2("Simpanan: RM%d", "Savings: RM%d") % GameState.coins
	_savings.theme_type_variation = "LabelHeading"
	_savings.add_theme_color_override("font_color", Color("2d936c"))
	if _savings.get_parent():
		_savings.get_parent().remove_child(_savings)
	_upgrades.add_child(_savings)
	var owned := Kedai.unlocked()
	for u in Kedai.UPGRADES:
		var b := Button.new()
		b.icon = EduAssets.texture(u[4])
		b.expand_icon = true
		b.custom_minimum_size = Vector2(0, 90)
		b.add_theme_font_size_override("font_size", 24)
		if u[0] in owned:
			b.text = (u[1] if GameState.lang == "ms" else u[2]) + " ✓"
			b.disabled = true
		else:
			b.text = "%s — RM%d" % [u[1] if GameState.lang == "ms" else u[2], u[3]]
			b.theme_type_variation = "ButtonGreen" if GameState.coins >= u[3] else "Button"
			b.pressed.connect(func():
				if Kedai.buy_upgrade(u[0], u[3]):
					Audio.sfx("level_up")
					Feedback.confetti(self, Vector2(1680, 300), 40)
				else:
					Audio.sfx("error_buzz")
				_refresh())
		_upgrades.add_child(b)
