## EduKit browser: every asset by KSSR subject, characters, audio, 3D props and
## live components, plus launchers for the demo games.
## Screenshot mode (docs): godot --path . -- --shot   -> docs/screens/*.png
extends Control

const DEMOS := [["Kuiz", "Quiz", "res://demo/demo_quiz.tscn", "ButtonGreen"],
	["Seret & Padan", "Drag & Match", "res://demo/demo_dragdrop.tscn", "ButtonOrange"],
	["Platform", "Platformer", "res://demo/demo_platformer.tscn", "ButtonPurple"],
	["Kelas 3D", "3D Class", "res://demo/demo_classroom3d.tscn", "ButtonTeal"]]
const SHARED := ["icons", "characters", "backgrounds", "ui", "fx", "tiles"]

var tabs := TabContainer.new()
var _grid := GridContainer.new()
var _cat_list := ItemList.new()
var _preview := TextureRect.new()
var _preview_name := Label.new()
var _model_view: Prop3D
var _model_list := ItemList.new()
var _char := Character2D.new()
var _categories: Array = []


func _ready() -> void:
	var bg := TextureRect.new()
	bg.texture = EduAssets.texture("backgrounds/pattern_dots")
	bg.stretch_mode = TextureRect.STRETCH_TILE
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	var root := VBoxContainer.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.offset_left = 24; root.offset_top = 16; root.offset_right = -24; root.offset_bottom = -16
	root.add_theme_constant_override("separation", 12)
	add_child(root)
	root.add_child(_top_bar())
	tabs.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(tabs)
	tabs.add_child(_art_tab())
	tabs.add_child(_char_tab())
	tabs.add_child(_audio_tab())
	tabs.add_child(_model_tab())
	tabs.add_child(_components_tab())
	_retitle()
	GameState.lang_changed.connect(func(_l): _retitle(); _show_category(_cat_list.get_selected_items()[0] if _cat_list.is_anything_selected() else 0))
	Audio.music("menu_ceria")
	if "--shot" in OS.get_cmdline_user_args():
		_screenshots.call_deferred()


func _retitle() -> void:
	var names := [["Gambar", "Art"], ["Watak", "Characters"], ["Audio", "Audio"], ["Model 3D", "3D Models"], ["Komponen", "Components"]]
	for i in names.size():
		tabs.set_tab_title(i, names[i][0 if GameState.lang == "ms" else 1])
	_cat_list.clear()
	for c in _categories:
		_cat_list.add_item(c[1] if GameState.lang == "ms" else c[2])


func _top_bar() -> Control:
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 14)
	var logo := TextureRect.new()
	logo.texture = EduAssets.texture("icons/grad_cap")
	logo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	logo.custom_minimum_size = Vector2(72, 72)
	h.add_child(logo)
	var title := Label.new()
	title.text = "EduKit"
	title.theme_type_variation = "LabelTitle"
	h.add_child(title)
	var sub := Label.new()
	sub.text = "  %d art · %d 3D · 983 voice · KSSR" % [EduAssets.refs().size(), EduAssets.model_refs().size()]
	sub.theme_type_variation = "LabelSmall"
	sub.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sub.clip_text = true
	h.add_child(sub)
	for d in DEMOS:
		var b := Button.new()
		b.text = d[0]
		b.theme_type_variation = d[3]
		b.pressed.connect(func(): Audio.sfx("ui_click"); Fader.go(d[2]))
		h.add_child(b)
	var lang := Button.new()
	lang.text = "BM / EN"
	lang.theme_type_variation = "ButtonYellow"
	lang.pressed.connect(func(): GameState.lang = "en" if GameState.lang == "ms" else "ms"; Audio.sfx("ui_toggle"))
	h.add_child(lang)
	return h


# ---------------- art ----------------
func _art_tab() -> Control:
	var h := HSplitContainer.new()
	h.name = "art"
	for s in EduAssets.SUBJECTS:
		_categories.append(["subject", EduAssets.subject_name(s, "ms"), EduAssets.subject_name(s, "en"), s])
	for c in SHARED:
		_categories.append(["category", c.capitalize(), c.capitalize(), c])
	_cat_list.custom_minimum_size = Vector2(380, 0)
	_cat_list.add_theme_font_size_override("font_size", 26)
	_cat_list.item_selected.connect(_show_category)
	h.add_child(_cat_list)
	var right := HBoxContainer.new()
	var scroll := ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_grid.columns = 6
	_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_grid.add_theme_constant_override("h_separation", 10)
	_grid.add_theme_constant_override("v_separation", 10)
	scroll.add_child(_grid)
	right.add_child(scroll)
	var pv := VBoxContainer.new()
	pv.custom_minimum_size = Vector2(380, 0)
	_preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_preview.custom_minimum_size = Vector2(360, 420)
	pv.add_child(_preview)
	_preview_name.theme_type_variation = "LabelHeading"
	_preview_name.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_preview_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	pv.add_child(_preview_name)
	right.add_child(pv)
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	h.add_child(right)
	_show_category.call_deferred(0)
	return h


func _show_category(i: int) -> void:
	if _categories.is_empty():
		return
	_cat_list.select(i)
	for c in _grid.get_children():
		c.queue_free()
	var cat: Array = _categories[i]
	var refs := EduAssets.by_subject(cat[3]) if cat[0] == "subject" else EduAssets.by_category(cat[3])
	if cat[3] == "characters":
		refs = refs.filter(func(r): return r.ends_with("_neutral") or r.ends_with("_happy"))
	for r in refs:
		var card := PictureCard.new()
		card.ref = r
		card.custom_minimum_size = Vector2(170, 200)
		card.pressed.connect(_select.bind(r))
		_grid.add_child(card)
	if not refs.is_empty():
		_select(refs[0], false)


func _select(r: String, speak := true) -> void:
	_preview.texture = EduAssets.texture(r)
	var e := EduAssets.entry(r)
	_preview_name.text = "%s\n%s" % [e.get("bm", ""), e.get("en", "")]
	if not speak:
		return


# ---------------- characters ----------------
func _char_tab() -> Control:
	var h := HBoxContainer.new()
	h.name = "chars"
	var stage := Control.new()
	stage.custom_minimum_size = Vector2(700, 0)
	stage.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var bg := TextureRect.new()
	bg.texture = EduAssets.texture("backgrounds/classroom")
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	stage.add_child(bg)
	_char.position = Vector2(350, 690)
	_char.height_px = 560
	stage.add_child(_char)
	h.add_child(stage)
	var v := VBoxContainer.new()
	v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	h.add_child(v)
	var chars := HFlowContainer.new()
	for c in Character2D.CHARS:
		var b := TextureButton.new()
		b.texture_normal = EduAssets.character(c, "happy")
		b.ignore_texture_size = true
		b.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
		b.custom_minimum_size = Vector2(110, 160)
		b.pressed.connect(func(): _char.char_id = c; _char.expression = "happy"; Audio.sfx("pop"))
		chars.add_child(b)
	v.add_child(chars)
	var exprs := HFlowContainer.new()
	for e in Character2D.EXPRESSIONS:
		var b := Button.new()
		b.text = e
		b.pressed.connect(func(): _char.expression = e; Audio.sfx("ui_click"))
		exprs.add_child(b)
	for a in [["react ✓", func(): _char.react(true); Audio.sfx("correct")], ["react ✗", func(): _char.react(false); Audio.sfx("wrong")],
			["talk", func(): _char.talk(2.0); Audio.say("feedback", "welcome")], ["cheer", func(): _char.cheer(); Audio.sfx("win_fanfare")]]:
		var b := Button.new()
		b.text = a[0]
		b.theme_type_variation = "ButtonOrange"
		b.pressed.connect(a[1])
		exprs.add_child(b)
	v.add_child(exprs)
	var dlg_btn := Button.new()
	dlg_btn.text = GameState.tr2("Contoh dialog", "Dialogue sample")
	dlg_btn.theme_type_variation = "ButtonPurple"
	var dlg := DialogueBox.new()
	dlg_btn.pressed.connect(func(): dlg.play([
		{"char": "nurul", "expr": "talk", "text": GameState.tr2("Selamat datang ke kelas, murid-murid!", "Welcome to class, everyone!"), "voice": ["feedback", "welcome"]},
		{"char": "aiman", "expr": "cheer", "text": GameState.tr2("Hore! Mari kita mulakan!", "Hooray! Let's start!"), "voice": ["feedback", "lets_start"]},
		{"char": "robo", "expr": "talk", "text": GameState.tr2("Saya Robo. Saya akan bantu kamu belajar.", "I am Robo. I will help you learn.")}]))
	v.add_child(dlg_btn)
	add_child(dlg)
	return h


# ---------------- audio ----------------
func _audio_tab() -> Control:
	var scroll := ScrollContainer.new()
	scroll.name = "audio"
	var v := VBoxContainer.new()
	v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(v)
	var am = JSON.parse_string(FileAccess.get_file_as_string("res://assets/audio/audio_manifest.json"))
	var sections := [["SFX", am.sfx, func(n): Audio.sfx(n), "Button"], ["Muzik / Music", am.music, func(n): Audio.current_music = ""; Audio.music(n), "ButtonPurple"]]
	var vm = JSON.parse_string(FileAccess.get_file_as_string("res://assets/audio/voice/voice_manifest.json"))
	for grp in ["feedback", "numbers", "letters", "colours", "days"]:
		sections.append(["Suara / Voice: " + grp, vm.ms[grp].keys(), func(n): Audio.say(grp, n), "ButtonTeal"])
	sections.append(["Suku kata", vm.ms.syllables.keys(), func(n): Audio.say("syllables", n, "ms"), "ButtonOrange"])
	for s in sections:
		var l := Label.new()
		l.text = s[0]
		l.theme_type_variation = "LabelHeading"
		v.add_child(l)
		var f := HFlowContainer.new()
		f.add_theme_constant_override("h_separation", 8)
		f.add_theme_constant_override("v_separation", 8)
		for n in s[1]:
			var b := Button.new()
			b.text = n
			b.theme_type_variation = s[3]
			b.add_theme_font_size_override("font_size", 22)
			b.pressed.connect(s[2].bind(n))
			f.add_child(b)
		v.add_child(f)
	return scroll


# ---------------- 3D ----------------
func _model_tab() -> Control:
	var h := HBoxContainer.new()
	h.name = "models"
	_model_list.custom_minimum_size = Vector2(420, 0)
	_model_list.add_theme_font_size_override("font_size", 24)
	for m in EduAssets.model_refs():
		var e := EduAssets.model_entry(m)
		_model_list.add_item("%s — %s" % [e.bm, e.en])
	h.add_child(_model_list)
	var svc := SubViewportContainer.new()
	svc.stretch = true
	svc.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	h.add_child(svc)
	var vp := SubViewport.new()
	vp.own_world_3d = true
	vp.msaa_3d = Viewport.MSAA_4X
	svc.add_child(vp)
	vp.add_child(_studio_env())
	_model_view = Prop3D.new()
	_model_view.spin_speed = 0.6
	vp.add_child(_model_view)
	var cam := OrbitCamera3D.new()
	cam.auto_rotate = 0.0
	vp.add_child(cam)
	_model_list.item_selected.connect(func(i):
		_model_view.ref = EduAssets.model_refs()[i]
		await get_tree().process_frame
		var a := _model_view.aabb
		cam.target = a.get_center()
		cam.distance = maxf(a.get_longest_axis_size() * 2.2, 0.4)
		cam.min_distance = cam.distance * 0.3
		cam._apply())
	_model_list.select(0)
	_model_list.item_selected.emit(0)
	return h


static func _studio_env() -> Node3D:
	var n := Node3D.new()
	var we := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color("cfe6f2")
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.75, 0.8, 0.9)
	env.ambient_light_energy = 0.2
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	we.environment = env
	n.add_child(we)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-50, 35, 0)
	sun.light_energy = 0.55
	sun.shadow_enabled = true
	n.add_child(sun)
	var floor := MeshInstance3D.new()
	var pm := PlaneMesh.new()
	pm.size = Vector2(60, 60)
	floor.mesh = pm
	var fm := StandardMaterial3D.new()
	fm.albedo_color = Color("9fb8c4")
	fm.roughness = 1.0
	fm.metallic_specular = 0.0
	floor.material_override = fm
	n.add_child(floor)
	return n


# ---------------- components ----------------
func _components_tab() -> Control:
	var scroll := ScrollContainer.new()
	scroll.name = "components"
	var f := HFlowContainer.new()
	f.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	f.add_theme_constant_override("h_separation", 30)
	f.add_theme_constant_override("v_separation", 30)
	scroll.add_child(f)
	var tiles := HBoxContainer.new()
	for i in 5:
		var t := TextTile.new()
		t.text = ["ba", "bi", "bu", "be", "bo"][i]
		t.color = TextTile.COLORS[i]
		t.speak_group = "syllables"
		tiles.add_child(t)
	f.add_child(_boxed("TextTile (suku kata)", tiles))
	var pie := FractionPie.new()
	pie.denominator = 4
	pie.numerator = 3
	pie.interactive = true
	f.add_child(_boxed("FractionPie 3/4", pie))
	var clk := AnalogClock.new()
	clk.hour = 10
	clk.minute = 10
	clk.interactive = true
	f.add_child(_boxed("AnalogClock", clk))
	var nl := NumberLine.new()
	nl.max_value = 10
	nl.marker = 7
	nl.hops = [Vector2i(3, 7)]
	f.add_child(_boxed("NumberLine 3 + 4", nl))
	var money := HBoxContainer.new()
	for v in [10, 50, 100, 1000]:
		var m := MoneyItem.new()
		m.value_sen = v
		money.add_child(m)
	f.add_child(_boxed("MoneyItem", money))
	var stars := StarRating.new()
	f.add_child(_boxed("StarRating", stars))
	stars.ready.connect(func(): stars.set_stars(2, false))
	var levels := HBoxContainer.new()
	for i in 4:
		var lb := LevelButton.new()
		lb.game_id = "gallery_demo"
		lb.level = i + 1
		levels.add_child(lb)
	f.add_child(_boxed("LevelButton", levels))
	var btns := HFlowContainer.new()
	for v in ["Button", "ButtonGreen", "ButtonRed", "ButtonYellow", "ButtonPurple", "ButtonOrange", "ButtonTeal"]:
		var b := Button.new()
		b.text = v.trim_prefix("Button") if v != "Button" else "Blue"
		b.theme_type_variation = v
		btns.add_child(b)
	btns.custom_minimum_size = Vector2(700, 0)
	f.add_child(_boxed("Theme buttons", btns))
	var ans := VBoxContainer.new()
	for i in 2:
		var a := AnswerButton.new()
		a.index = i
		a.text = ["Bumi", "Marikh"][i]
		ans.add_child(a)
	f.add_child(_boxed("AnswerButton", ans))
	return scroll


func _boxed(title: String, c: Control) -> Control:
	var p := PanelContainer.new()
	var v := VBoxContainer.new()
	p.add_child(v)
	var l := Label.new()
	l.text = title
	l.theme_type_variation = "LabelSmall"
	v.add_child(l)
	v.add_child(c)
	return p


# ---------------- docs screenshots ----------------
func _screenshots() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://docs/screens"))
	var shots := [[0, 3, "gallery_art_sains"], [0, 1, "gallery_art_bi"], [1, -1, "gallery_characters"], [3, -1, "gallery_3d"], [4, -1, "gallery_components"]]
	for s in shots:
		tabs.current_tab = s[0]
		if s[1] >= 0:
			_show_category(s[1])
		if s[0] == 3:
			var i := EduAssets.model_refs().find("sejarah/rumah_kampung")
			_model_list.select(i)
			_model_list.item_selected.emit(i)
		await get_tree().create_timer(1.2).timeout
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("res://docs/screens/%s.png" % s[2])
		print("shot ", s[2])
	get_tree().quit()
