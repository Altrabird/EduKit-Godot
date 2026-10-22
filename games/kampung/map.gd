## Village map: starts grey; every activity with a star brings colour back.
extends Control

static var _tapped := false

const DESAT := "shader_type canvas_item;\nuniform float sat = 1.0;\nvoid fragment() {\n\tvec4 c = texture(TEXTURE, UV);\n\tfloat g = dot(c.rgb, vec3(0.299, 0.587, 0.114));\n\tCOLOR = vec4(mix(vec3(g), c.rgb, sat), c.a);\n}\n"


func _ready() -> void:
	var bg := KitUtil.background(self, "backgrounds/kampung")
	var mat := ShaderMaterial.new()
	var sh := Shader.new()
	sh.code = DESAT
	mat.shader = sh
	mat.set_shader_parameter("sat", Kampung.saturation())
	bg.material = mat
	var title := Label.new()
	title.text = "Kampungku Sihat"
	title.theme_type_variation = "LabelTitle"
	title.add_theme_font_size_override("font_size", 88)
	title.add_theme_color_override("font_color", Color("6bcb77"))
	title.add_theme_color_override("font_outline_color", Color("2b2d42"))
	title.add_theme_constant_override("outline_size", 18)
	title.position = Vector2(40, 20)
	add_child(title)
	var prog := Label.new()
	prog.text = GameState.tr2("Kampung ceria: %d / %d", "Village brightness: %d / %d") % [Kampung.done_count(), Kampung.ACTIVITIES.size()]
	prog.theme_type_variation = "LabelHeading"
	prog.add_theme_color_override("font_color", Color.WHITE)
	prog.add_theme_color_override("font_outline_color", Color("2b2d42"))
	prog.add_theme_constant_override("outline_size", 10)
	prog.position = Vector2(46, 140)
	add_child(prog)
	var lang := Button.new()
	lang.text = "BM / EN"
	lang.theme_type_variation = "ButtonTeal"
	lang.position = Vector2(1720, 30)
	lang.pressed.connect(func(): GameState.lang = "en" if GameState.lang == "ms" else "ms"; get_tree().reload_current_scene())
	add_child(lang)
	for i in Kampung.ACTIVITIES.size():
		add_child(_marker(i))
	if Kampung.done_count() == Kampung.ACTIVITIES.size():
		Audio.say("feedback", "kg_done")
		Feedback.confetti(self, Vector2(960, 300), 120)
	if not _tapped:
		var o := ColorRect.new()
		o.color = Color(0.05, 0.12, 0.08, 0.6)
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
				Audio.music("santai_kampung")
				Audio.say("feedback", "kg_welcome"))
		add_child(o)
	else:
		Audio.music("santai_kampung")
	KitUtil.maybe_shot(self, "kampung_map", 1.5)


func _marker(i: int) -> Control:
	var a: Array = Kampung.ACTIVITIES[i]
	var b := Button.new()
	b.position = a[5] - Vector2(130, 130)
	b.custom_minimum_size = Vector2(260, 290)
	b.theme_type_variation = "ButtonYellow" if GameState.stars_for(Kampung.GAME, i + 1) > 0 else "Button"
	var v := VBoxContainer.new()
	v.set_anchors_preset(Control.PRESET_FULL_RECT)
	v.offset_top = 10
	v.offset_bottom = -10
	v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	b.add_child(v)
	var ic := TextureRect.new()
	ic.texture = EduAssets.texture(a[4])
	ic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	ic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	ic.size_flags_vertical = Control.SIZE_EXPAND_FILL
	ic.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v.add_child(ic)
	var n := Label.new()
	n.text = Kampung.name_of(i)
	n.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	n.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	n.add_theme_font_size_override("font_size", 26)
	n.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v.add_child(n)
	var s := GameState.stars_for(Kampung.GAME, i + 1)
	var st := Label.new()
	st.text = "★".repeat(s) + "☆".repeat(3 - s) + "  " + a[6]
	st.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	st.add_theme_font_size_override("font_size", 20)
	st.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v.add_child(st)
	b.pressed.connect(func(): Audio.sfx("ui_click"); Fader.go(a[1]))
	return b
