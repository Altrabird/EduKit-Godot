## Pick Tahun, subject, and (class mode) how many teams.
extends Control

var _grid := GridContainer.new()
var _year_btns: Array[Button] = []
var _team_btns: Array[Button] = []


func _ready() -> void:
	KitUtil.background(self, "backgrounds/classroom")
	var shade := ColorRect.new()
	shade.color = Color(1, 1, 1, 0.35)
	shade.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(shade)
	var v := JksUI.center_column(self, 24, 24, 16)
	var top := HBoxContainer.new()
	top.add_theme_constant_override("separation", 16)
	v.add_child(top)
	var back := JksUI.icon_button("icons/back", "ButtonYellow")
	back.pressed.connect(func(): JksUI.go("menu"))
	top.add_child(back)
	var t := JksUI.title(GameState.tr2("Pilih Tahun & Mata Pelajaran", "Choose Year & Subject"), "LabelTitle")
	t.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(t)
	var years := HBoxContainer.new()
	years.alignment = BoxContainer.ALIGNMENT_CENTER
	years.add_theme_constant_override("separation", 12)
	v.add_child(years)
	for y in range(1, 7):
		var b := JksUI.button(GameState.tr2("Tahun %d", "Year %d") % y, "ButtonPurple", "", Vector2(200, 80))
		b.toggle_mode = true
		b.pressed.connect(_set_year.bind(y))
		years.add_child(b)
		_year_btns.append(b)
	if Jks.teams > 0:
		var teams := HBoxContainer.new()
		teams.alignment = BoxContainer.ALIGNMENT_CENTER
		teams.add_theme_constant_override("separation", 12)
		var tl := JksUI.title(GameState.tr2("Pasukan:", "Teams:"), "LabelHeading", Color("2b2d42"))
		tl.remove_theme_color_override("font_outline_color")
		tl.add_theme_constant_override("outline_size", 0)
		teams.add_child(tl)
		for n in [2, 3, 4]:
			var b := JksUI.button(str(n), "ButtonOrange", "icons/users", Vector2(160, 80))
			b.toggle_mode = true
			b.pressed.connect(_set_teams.bind(n))
			teams.add_child(b)
			_team_btns.append(b)
		v.add_child(teams)
		_set_teams(Jks.teams)
	_grid.columns = 6
	_grid.add_theme_constant_override("h_separation", 16)
	_grid.add_theme_constant_override("v_separation", 16)
	var cc := CenterContainer.new()
	cc.size_flags_vertical = Control.SIZE_EXPAND_FILL
	cc.add_child(_grid)
	v.add_child(cc)
	_set_year(Jks.year)
	KitUtil.maybe_shot(self, "jks_subjects", 1.5)


func _set_year(y: int) -> void:
	Jks.year = y
	for i in _year_btns.size():
		_year_btns[i].button_pressed = i + 1 == y
		_year_btns[i].theme_type_variation = "ButtonYellow" if i + 1 == y else "ButtonPurple"
	for c in _grid.get_children():
		c.queue_free()
	for s in Jks.subjects():
		_grid.add_child(_card(s))


func _set_teams(n: int) -> void:
	Jks.teams = n
	for i in _team_btns.size():
		_team_btns[i].button_pressed = i + 2 == n
		_team_btns[i].theme_type_variation = "ButtonYellow" if i + 2 == n else "ButtonOrange"


func _card(s: String) -> Control:
	var b := Button.new()
	b.custom_minimum_size = Vector2(270, 250)
	b.theme_type_variation = "ButtonYellow" if s == Jks.MIXED else "Button"
	b.add_theme_stylebox_override("normal", _flat(Color("fdfcf7")))
	b.add_theme_stylebox_override("hover", _flat(Color("dbeafe")))
	b.add_theme_stylebox_override("pressed", _flat(Color("bfdbfe")))
	b.add_theme_stylebox_override("disabled", _flat(Color("dee2e6")))
	var v := VBoxContainer.new()
	v.set_anchors_preset(Control.PRESET_FULL_RECT)
	v.offset_top = 14
	v.offset_bottom = -10
	v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	b.add_child(v)
	var img := TextureRect.new()
	img.texture = EduAssets.texture(Jks.ICON[s])
	img.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	img.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	img.size_flags_vertical = Control.SIZE_EXPAND_FILL
	img.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v.add_child(img)
	var l := Label.new()
	l.text = Jks.subject_name(s)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.theme_type_variation = "LabelSmall"
	l.add_theme_font_size_override("font_size", 24)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v.add_child(l)
	var stars := Label.new()
	stars.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stars.theme_type_variation = "LabelSmall"
	stars.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var got := GameState.total_stars("jks_%s_t%d" % [s, Jks.year])
	stars.text = "★ %d / 15" % got
	v.add_child(stars)
	if not Jks.available(s, Jks.year):
		b.disabled = true
		img.modulate.a = 0.35
		stars.text = GameState.tr2("Tahun 4–6", "Year 4–6")
	b.pressed.connect(func():
		Audio.sfx("ui_click")
		Jks.subject = s
		JksUI.go("stages"))
	return b


static func _flat(c: Color) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = c
	s.set_corner_radius_all(24)
	s.set_border_width_all(5)
	s.border_color = Color("2b2d42")
	s.shadow_color = Color(0, 0, 0, 0.2)
	s.shadow_offset = Vector2(0, 6)
	s.shadow_size = 1
	return s
