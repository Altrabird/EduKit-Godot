## 3D lab hub: five benches, each with a prop. Click a bench prop to start its mission.
## Stars float above each bench. Drag to orbit, wheel to zoom.
extends Node3D

static var _tapped := false

var _cam := OrbitCamera3D.new()
var _ui := CanvasLayer.new()
var _dialog := DialogueBox.new()


func _ready() -> void:
	_env()
	_room()
	for i in Makmal.MISSIONS.size():
		var pos := Vector3((i - 2) * 2.3, 0, -0.6 - absf(i - 2) * 0.4)
		var table := Prop3D.new()
		table.ref = "sains/lab_table"
		table.position = pos
		table.scale = Vector3.ONE * 0.9
		table.clicked.connect(_open.bind(i))
		add_child(table)
		var prop := Prop3D.new()
		prop.ref = Makmal.MISSIONS[i][4]
		prop.position = pos + Vector3(0, 0.84, 0)
		prop.scale = Vector3.ONE * 1.6
		prop.spin_speed = 0.5
		prop.clicked.connect(_open.bind(i))
		add_child(prop)
		if Makmal.MISSIONS[i][4] == "sains/planet_saturn":
			prop.scale = Vector3.ONE * 0.85
		var lbl := Label3D.new()
		var n := GameState.stars_for(Makmal.GAME, i + 1)
		lbl.text = "%s\n%s" % [Makmal.name_of(i), "★".repeat(n) + "☆".repeat(3 - n)]
		lbl.font = preload("res://assets/fonts/Fredoka.ttf")
		lbl.font_size = 48
		lbl.outline_size = 16
		lbl.modulate = Color("2b2d42")
		lbl.outline_modulate = Color.WHITE
		lbl.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		lbl.position = pos + Vector3(0, 2.0 + (i % 2) * 0.55, 0)
		lbl.pixel_size = 0.006
		add_child(lbl)
	_prop("sains/microscope", Vector3(-4.4, 0.0, -2.6), 0.0, 2.2)
	_prop("sains/telescope", Vector3(4.6, 0, -2.4), -30.0, 1.0)
	_prop("classroom/bookshelf", Vector3(-5.6, 0, 0.6), 90.0, 1.0)
	_prop("sains/test_tube_rack", Vector3(4.3, 0, 1.4), 0.0, 3.0)
	_cam.target = Vector3(0, 1.0, -0.9)
	_cam.distance = 6.4
	_cam.pitch = -0.32
	_cam.yaw = 0.0
	_cam.auto_rotate = 0.0
	_cam.max_distance = 14
	add_child(_cam)
	add_child(_ui)
	var title := Label.new()
	title.text = "Makmal Sains Ajaib"
	title.theme_type_variation = "LabelTitle"
	title.add_theme_font_size_override("font_size", 80)
	title.add_theme_color_override("font_color", Color("3a86ff"))
	title.add_theme_color_override("font_outline_color", Color.WHITE)
	title.add_theme_constant_override("outline_size", 18)
	title.position = Vector2(40, 24)
	_ui.add_child(title)
	var hint := Label.new()
	hint.text = GameState.tr2("Klik satu meja untuk memulakan misi · seret untuk memusing", "Click a table to start a mission · drag to look around")
	hint.theme_type_variation = "LabelHeading"
	hint.add_theme_color_override("font_outline_color", Color.WHITE)
	hint.add_theme_constant_override("outline_size", 10)
	hint.position = Vector2(44, 130)
	_ui.add_child(hint)
	var lang := Button.new()
	lang.text = "BM / EN"
	lang.theme_type_variation = "ButtonTeal"
	lang.position = Vector2(1720, 30)
	lang.pressed.connect(func(): GameState.lang = "en" if GameState.lang == "ms" else "ms"; get_tree().reload_current_scene())
	_ui.add_child(lang)
	_ui.add_child(_dialog)
	if not _tapped:
		var o := ColorRect.new()
		o.color = Color(0.05, 0.1, 0.2, 0.6)
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
				Audio.music("jelajah_santai")
				_dialog.play([{"char": "nurul", "expr": "talk", "voice": ["feedback", "lab_welcome"],
					"text": GameState.tr2("Selamat datang ke Makmal Sains Ajaib! Klik satu meja untuk memulakan misi.", "Welcome to the Magic Science Lab! Click a table to start a mission.")}]))
		_ui.add_child(o)
	else:
		Audio.music("jelajah_santai")
	KitUtil.maybe_shot(self, "makmal_hub", 3.0)


func _open(_ref: String, i: int) -> void:
	Audio.sfx("whoosh")
	Fader.go(Makmal.MISSIONS[i][1])


func _prop(ref: String, pos: Vector3, yaw := 0.0, s := 1.0) -> void:
	var p := Prop3D.new()
	p.ref = ref
	p.position = pos
	p.rotation_degrees.y = yaw
	p.scale = Vector3.ONE * s
	add_child(p)


func _env() -> void:
	var we := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color("cfe9f2")
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.85, 0.9, 1.0)
	env.ambient_light_energy = 0.2
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	we.environment = env
	add_child(we)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-55, 25, 0)
	sun.light_energy = 0.6
	sun.shadow_enabled = true
	add_child(sun)


func _room() -> void:
	for spec in [[Vector3(16, 0.1, 10), Vector3(0, -0.05, 0), Color("a9c6c9")], [Vector3(16, 4, 0.1), Vector3(0, 2, -3.6), Color("e3f2f1")],
			[Vector3(0.1, 4, 10), Vector3(-7, 2, 0), Color("d3ecea")], [Vector3(16, 1.0, 0.12), Vector3(0, 0.5, -3.53), Color("9dbcc0")]]:
		var m := MeshInstance3D.new()
		var b := BoxMesh.new()
		b.size = spec[0]
		m.mesh = b
		var mat := StandardMaterial3D.new()
		mat.albedo_color = spec[2]
		mat.roughness = 1.0
		mat.metallic_specular = 0.1
		m.material_override = mat
		m.position = spec[1]
		add_child(m)
