## Title + level map. Mode: BM suku kata (Tahun 1–2) or English letters (phonics mode).
extends Control

static var _tapped := false

var _grid := GridContainer.new()
var _mode_btns: Array[Button] = []
var _dialog := DialogueBox.new()


func _ready() -> void:
	KitUtil.background(self, "backgrounds/kampung")
	var kancil := TextureRect.new()
	kancil.texture = EduAssets.texture("bahasa_melayu/sang_kancil")
	kancil.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	kancil.position = Vector2(1420, 520)
	kancil.size = Vector2(440, 440)
	add_child(kancil)
	var croc := TextureRect.new()
	croc.texture = EduAssets.texture("bahasa_melayu/buaya")
	croc.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	croc.position = Vector2(40, 760)
	croc.size = Vector2(340, 340)
	add_child(croc)
	var v := VBoxContainer.new()
	v.set_anchors_preset(Control.PRESET_FULL_RECT)
	v.offset_left = 60; v.offset_top = 30; v.offset_right = -60; v.offset_bottom = -40
	v.add_theme_constant_override("separation", 20)
	add_child(v)
	var t := Label.new()
	t.text = "Kancil & Suku Kata"
	t.theme_type_variation = "LabelTitle"
	t.add_theme_font_size_override("font_size", 92)
	t.add_theme_color_override("font_color", Color("ffd166"))
	t.add_theme_color_override("font_outline_color", Color("2b2d42"))
	t.add_theme_constant_override("outline_size", 18)
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(t)
	var modes := HBoxContainer.new()
	modes.alignment = BoxContainer.ALIGNMENT_CENTER
	modes.add_theme_constant_override("separation", 20)
	v.add_child(modes)
	for m in [["ms", "Suku Kata (BM)"], ["en", "Letters (English)"]]:
		var b := Button.new()
		b.text = m[1]
		b.custom_minimum_size = Vector2(420, 96)
		b.pressed.connect(func(): Audio.sfx("ui_click"); Kancil.mode = m[0]; _refresh())
		modes.add_child(b)
		_mode_btns.append(b)
	_grid.columns = 6
	_grid.add_theme_constant_override("h_separation", 26)
	_grid.add_theme_constant_override("v_separation", 26)
	var cc := CenterContainer.new()
	cc.size_flags_vertical = Control.SIZE_EXPAND_FILL
	cc.add_child(_grid)
	v.add_child(cc)
	var story := Button.new()
	story.text = GameState.tr2("Cerita", "Story")
	story.icon = EduAssets.texture("icons/book")
	story.expand_icon = true
	story.theme_type_variation = "ButtonPurple"
	story.custom_minimum_size = Vector2(260, 88)
	story.position = Vector2(40, 40)
	story.pressed.connect(_story)
	add_child(story)
	add_child(_dialog)
	_refresh()
	if not _tapped:
		_tap_overlay()
	else:
		Audio.music("santai_kampung")
	KitUtil.maybe_shot(self, "kancil_menu", 1.5)


func _refresh() -> void:
	for i in _mode_btns.size():
		_mode_btns[i].theme_type_variation = "ButtonYellow" if ["ms", "en"][i] == Kancil.mode else "ButtonTeal"
	for c in _grid.get_children():
		c.queue_free()
	for lv in range(1, Kancil.level_count() + 1):
		var col := VBoxContainer.new()
		var b := LevelButton.new()
		b.game_id = Kancil.game_id()
		b.level = lv
		b.chosen.connect(func(l): Kancil.level = l; Fader.go(Kancil.SCENES.level))
		col.add_child(b)
		var words := Kancil.level_words(lv)
		var pics := HBoxContainer.new()
		pics.alignment = BoxContainer.ALIGNMENT_CENTER
		for w in words:
			var p := TextureRect.new()
			p.texture = EduAssets.texture(w.img)
			p.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			p.custom_minimum_size = Vector2(56, 56)
			p.modulate.a = 1.0 if GameState.is_unlocked(Kancil.game_id(), lv) else 0.35
			pics.add_child(p)
		col.add_child(pics)
		_grid.add_child(col)


func _story() -> void:
	Kancil.seen_intro = true
	if Kancil.mode == "en":
		_dialog.play([
			{"portrait": "bahasa_melayu/sang_kancil", "name": "Sang Kancil", "text": "Hello! I am Sang Kancil. I want to cross the river to find yummy fruit."},
			{"portrait": "bahasa_melayu/buaya", "name": "Buaya", "text": "Hmm... the crocodiles block the way!"},
			{"portrait": "bahasa_melayu/sang_kancil", "name": "Sang Kancil", "text": "Help me collect the letters and spell each word to open the gates!"}])
	else:
		_dialog.play([
			{"portrait": "bahasa_melayu/sang_kancil", "name": "Sang Kancil", "text": "Hai! Saya Sang Kancil. Saya mahu menyeberang sungai untuk mencari buah-buahan."},
			{"portrait": "bahasa_melayu/buaya", "name": "Sang Buaya", "text": "Ha ha! Sungai ini kami yang jaga!"},
			{"portrait": "bahasa_melayu/harimau", "name": "Sang Harimau", "text": "Hutan ini pula tempat saya meronda!"},
			{"portrait": "bahasa_melayu/sang_kancil", "name": "Sang Kancil", "text": "Bantu saya kutip suku kata dan susun perkataan untuk membuka pintu!"}])


func _tap_overlay() -> void:
	var o := ColorRect.new()
	o.color = Color(0.05, 0.12, 0.08, 0.7)
	o.set_anchors_preset(Control.PRESET_FULL_RECT)
	var l := Label.new()
	l.text = GameState.tr2("Ketik untuk bermula", "Tap to start")
	l.theme_type_variation = "LabelTitle"
	l.add_theme_color_override("font_color", Color.WHITE)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.set_anchors_preset(Control.PRESET_CENTER)
	l.position = Vector2(-500, -60)
	l.size = Vector2(1000, 120)
	o.add_child(l)
	o.gui_input.connect(func(e):
		if (e is InputEventMouseButton or e is InputEventScreenTouch) and e.pressed:
			_tapped = true
			o.queue_free()
			Audio.music("santai_kampung")
			if not Kancil.seen_intro:
				_story())
	add_child(o)
