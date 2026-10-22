## Kompang & Warna (Seni + Muzik): copy three kompang rhythms (dum = centre, pak = edge),
## then mix two primary colours to make green, orange and purple.
extends KampungActivity

var _round := 0
var _input := ""
var _pattern := ""
var _area := VBoxContainer.new()
var _drum := TextureRect.new()
var _mix_pick: Array = []
var _target := ""


func _ready() -> void:
	setup(5, "backgrounds/kampung", GameState.tr2("Dengar rentak kompang, kemudian ketuk mengikut rentak yang sama.", "Listen to the kompang rhythm, then tap the same rhythm."), "kg_kompang", "jaiden")
	_area.add_theme_constant_override("separation", 20)
	body.add_child(_area)
	_rhythm_round()
	KitUtil.maybe_shot(self, "kampung_art", 2.0)


func _clear() -> void:
	for c in _area.get_children():
		_area.remove_child(c)
		c.queue_free()


# ---------------- kompang ----------------
func _rhythm_round() -> void:
	_clear()
	_pattern = Kampung.RHYTHMS[_round]
	_input = ""
	var l := Label.new()
	l.text = "%s %d/3: %s" % [GameState.tr2("Rentak", "Rhythm"), _round + 1, " ".join(Array(_pattern.split("")).map(func(c): return "DUM" if c == "D" else "pak"))]
	l.theme_type_variation = "LabelTitle"
	_area.add_child(l)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 40)
	_area.add_child(row)
	_drum = TextureRect.new()  # the previous round's drum was freed with its row
	_drum.texture = EduAssets.texture("muzik/kompang")
	_drum.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_drum.custom_minimum_size = Vector2(360, 360)
	row.add_child(_drum)
	var btns := VBoxContainer.new()
	btns.add_theme_constant_override("separation", 20)
	row.add_child(btns)
	for k in [["D", "DUM (tengah)", "DUM (centre)", "ButtonOrange"], ["P", "pak (tepi)", "pak (edge)", "ButtonYellow"]]:
		var b := Button.new()
		b.text = k[1] if GameState.lang == "ms" else k[2]
		b.theme_type_variation = k[3]
		b.custom_minimum_size = Vector2(420, 140)
		b.pressed.connect(hit.bind(k[0]))
		btns.add_child(b)
	var listen := Button.new()
	listen.text = GameState.tr2("Dengar semula", "Listen again")
	listen.icon = EduAssets.texture("icons/sound_on")
	listen.expand_icon = true
	listen.custom_minimum_size = Vector2(420, 100)
	listen.pressed.connect(_play_pattern)
	btns.add_child(listen)
	_play_pattern()


func _play_pattern() -> void:
	_input = ""
	var playing := _pattern
	for c in playing:
		if playing != _pattern or not is_inside_tree():  # round moved on while the demo was playing
			return
		_strike(c)
		await get_tree().create_timer(0.45).timeout


func _strike(c: String) -> void:
	Audio.sfx("kompang_dum" if c == "D" else "kompang_pak")
	if not is_instance_valid(_drum):
		return
	_drum.pivot_offset = _drum.size / 2
	var tw := _drum.create_tween()
	tw.tween_property(_drum, "scale", Vector2(0.92, 0.92) if c == "D" else Vector2(1.05, 0.95), 0.05)
	tw.tween_property(_drum, "scale", Vector2.ONE, 0.12)


func hit(c: String) -> void:
	_strike(c)
	_input += c
	if not _pattern.begins_with(_input):
		wrong(GameState.tr2("Rentak berbeza. Dengar sekali lagi.", "A different rhythm. Listen once more."))
		_input = ""
		return
	if _input == _pattern:
		Audio.sfx("correct")
		_round += 1
		await get_tree().create_timer(0.8).timeout
		if _round >= 3:
			_round = 0
			_colour_round()
		else:
			_rhythm_round()


# ---------------- colour mixing ----------------
func _colour_round() -> void:
	_clear()
	_target = Kampung.MIXES.keys()[_round]
	_mix_pick = []
	say(GameState.tr2("Campurkan dua warna untuk mendapatkan warna ini.", "Mix two colours to make this colour."))
	Audio.say("feedback", "kg_colour")
	var l := Label.new()
	l.text = "%s %d/3: %s" % [GameState.tr2("Warna", "Colour"), _round + 1, _target if GameState.lang == "ms" else Kampung.COLOUR_EN[_target]]
	l.theme_type_variation = "LabelTitle"
	_area.add_child(l)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 30)
	_area.add_child(row)
	var swatch := ColorRect.new()
	swatch.color = Kampung.COLOURS[_target]
	swatch.custom_minimum_size = Vector2(260, 260)
	row.add_child(swatch)
	for c in ["merah", "kuning", "biru"]:
		var b := Button.new()
		b.text = c if GameState.lang == "ms" else Kampung.COLOUR_EN[c]
		var sb := StyleBoxFlat.new()
		sb.bg_color = Kampung.COLOURS[c]
		sb.set_corner_radius_all(130)
		sb.set_border_width_all(6)
		sb.border_color = Color("2b2d42")
		b.add_theme_stylebox_override("normal", sb)
		b.add_theme_stylebox_override("hover", sb)
		b.add_theme_stylebox_override("pressed", sb)
		b.add_theme_color_override("font_color", Color("2b2d42"))
		b.custom_minimum_size = Vector2(220, 220)
		b.pressed.connect(pick_colour.bind(c, b))
		row.add_child(b)


func pick_colour(c: String, b: Button) -> void:
	if c in _mix_pick:
		return
	_mix_pick.append(c)
	b.modulate = Color(1, 1, 1, 0.5)
	Audio.sfx("drop")
	if _mix_pick.size() < 2:
		return
	if Kampung.mix_ok(_target, _mix_pick[0], _mix_pick[1]):
		Feedback.result(self, true, false)
		_round += 1
		await get_tree().create_timer(1.0).timeout
		if _round >= 3:
			say(GameState.tr2("Hebat! Kamu pemuzik dan pelukis yang bijak.", "Amazing! You are a clever musician and artist."), "happy")
			finish()
		else:
			_colour_round()
	else:
		wrong(GameState.tr2("Warna itu tidak menjadi %s. Cuba lagi." % _target, "Those don't make %s. Try again." % Kampung.COLOUR_EN[_target]))
		_colour_round()
