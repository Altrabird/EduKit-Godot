## Title screen: Solo, Mod Kelas (teams), Guru (long-press, question editor), Tetapan.
extends Control

static var _tapped := false  # browsers only allow audio after the first tap

var _settings := PanelContainer.new()
var _guru_hold := 0.0
var _guru: Button


func _ready() -> void:
	KitUtil.background(self, "backgrounds/stage_hall")
	for c in [["robo", 250, 1020, 500], ["kenyalang", 1690, 1020, 440], ["aisyah", 520, 1060, 300], ["weijie", 1420, 1060, 300]]:
		var ch := Character2D.new()
		ch.char_id = c[0]
		ch.position = Vector2(c[1], c[2])
		ch.height_px = c[3]
		ch.expression = "happy"
		add_child(ch)
	var v := JksUI.center_column(self, 40, 60, 22)
	var ribbon := TextureRect.new()
	ribbon.texture = EduAssets.texture("ui/ribbon_banner")
	ribbon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	ribbon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	ribbon.custom_minimum_size = Vector2(0, 260)
	v.add_child(ribbon)
	var t := JksUI.title("Juara Kuiz Sekolah")
	t.set_anchors_preset(Control.PRESET_FULL_RECT)
	t.offset_bottom = -70
	t.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	t.add_theme_font_size_override("font_size", 84)
	ribbon.add_child(t)
	var sub := JksUI.title(GameState.tr2("Kuiz KSSR Tahun 1–6 · 11 mata pelajaran", "KSSR quiz for Year 1–6 · 11 subjects"), "LabelHeading")
	v.add_child(sub)
	var col := VBoxContainer.new()
	col.alignment = BoxContainer.ALIGNMENT_CENTER
	col.add_theme_constant_override("separation", 18)
	col.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var cc := CenterContainer.new()
	cc.size_flags_vertical = Control.SIZE_EXPAND_FILL
	cc.add_child(col)
	v.add_child(cc)
	var solo := JksUI.button(GameState.tr2("Main", "Play"), "ButtonGreen", "icons/play", Vector2(560, 110))
	solo.pressed.connect(func(): Jks.teams = 0; JksUI.go("subjects"))
	col.add_child(solo)
	var cls := JksUI.button(GameState.tr2("Mod Kelas (Pasukan)", "Class Mode (Teams)"), "ButtonOrange", "icons/users", Vector2(560, 110))
	cls.pressed.connect(func(): Jks.teams = maxi(Jks.teams, 2); JksUI.go("subjects"))
	col.add_child(cls)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 18)
	col.add_child(row)
	_guru = JksUI.button(GameState.tr2("Guru (tekan lama)", "Teacher (hold)"), "ButtonPurple", "icons/grad_cap", Vector2(271, 96))
	_guru.button_down.connect(func(): _guru_hold = 0.001)
	_guru.button_up.connect(func(): _guru_hold = 0.0; _guru.modulate = Color.WHITE)
	row.add_child(_guru)
	var set_b := JksUI.button(GameState.tr2("Tetapan", "Settings"), "ButtonTeal", "icons/settings", Vector2(271, 96))
	set_b.pressed.connect(func(): _settings.visible = not _settings.visible)
	row.add_child(set_b)
	_build_settings()
	if not _tapped:
		_tap_overlay()
	else:
		Audio.music("menu_ceria")
	KitUtil.maybe_shot(self, "jks_menu", 2.0)


func _process(delta: float) -> void:
	# Long press keeps pupils out of the editor without a password to forget.
	if _guru_hold > 0.0:
		_guru_hold += delta
		_guru.modulate = Color(1, 1, 1).lerp(Color(1.4, 1.4, 0.6), clampf(_guru_hold / 1.5, 0, 1))
		if _guru_hold >= 1.5:
			_guru_hold = 0.0
			Audio.sfx("unlock")
			JksUI.go("editor")


func _tap_overlay() -> void:
	var o := ColorRect.new()
	o.color = Color(0.1, 0.08, 0.2, 0.75)
	o.set_anchors_preset(Control.PRESET_FULL_RECT)
	var l := JksUI.title(GameState.tr2("Ketik untuk bermula", "Tap to start"))
	l.set_anchors_preset(Control.PRESET_CENTER)
	l.position = Vector2(-500, -60)
	l.size = Vector2(1000, 120)
	o.add_child(l)
	var tw := l.create_tween().set_loops()
	tw.tween_property(l, "modulate:a", 0.4, 0.6)
	tw.tween_property(l, "modulate:a", 1.0, 0.6)
	o.gui_input.connect(func(e):
		if (e is InputEventMouseButton or e is InputEventScreenTouch) and e.pressed:
			_tapped = true
			o.queue_free()
			Audio.music("menu_ceria")
			Audio.say("feedback", "welcome"))
	add_child(o)


func _build_settings() -> void:
	_settings.theme_type_variation = "PanelCream"
	_settings.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	_settings.custom_minimum_size = Vector2(760, 0)
	_settings.position = Vector2(580, 220)
	_settings.hide()
	add_child(_settings)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 16)
	_settings.add_child(v)
	var head := Label.new()
	head.text = GameState.tr2("Tetapan", "Settings")
	head.theme_type_variation = "LabelHeading"
	v.add_child(head)
	var lang := JksUI.button("Bahasa: BM" if GameState.lang == "ms" else "Language: EN", "ButtonYellow")
	lang.pressed.connect(func(): GameState.lang = "en" if GameState.lang == "ms" else "ms"; get_tree().reload_current_scene())
	v.add_child(lang)
	for bus in [["Music", "Muzik", "Music"], ["SFX", "Bunyi", "Sounds"], ["Voice", "Suara", "Voice"]]:
		var h := HBoxContainer.new()
		var l := Label.new()
		l.text = GameState.tr2(bus[1], bus[2])
		l.custom_minimum_size = Vector2(180, 0)
		h.add_child(l)
		var s := HSlider.new()
		s.min_value = 0
		s.max_value = 1
		s.step = 0.05
		s.value = GameState.volumes.get(bus[0], 1.0)
		s.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		s.value_changed.connect(func(x): GameState.set_volume(bus[0], x))
		h.add_child(s)
		v.add_child(h)
	var reset := JksUI.button(GameState.tr2("Padam semua kemajuan", "Reset all progress"), "ButtonRed")
	reset.pressed.connect(func():
		if reset.text.ends_with("?"):
			GameState.reset_all()
			reset.text = GameState.tr2("Kemajuan dipadam", "Progress cleared")
		else:
			reset.text = GameState.tr2("Pasti? Tekan sekali lagi?", "Sure? Press again?"))
	v.add_child(reset)
	var close := JksUI.button(GameState.tr2("Tutup", "Close"), "Button")
	close.pressed.connect(_settings.hide)
	v.add_child(close)
