## Demo: a 3D classroom assembled from the GLB props. Drag to orbit, wheel to zoom,
## click a prop to hear and see its BM/EN name.
extends Node3D

var _cam := OrbitCamera3D.new()
var _label := Label.new()


func _ready() -> void:
	_env()
	_room()
	var p := Vector3.ZERO
	for row in 3:
		for col in 4:
			p = Vector3(-2.4 + col * 1.6, 0, -0.6 + row * 1.4)
			_prop("classroom/desk", p)
			_prop("classroom/chair", p + Vector3(0, 0, 0.45), 180)
			if (row + col) % 3 == 0:
				_prop("classroom/book", p + Vector3(0.1, 0.74, 0), 15)
			if (row * 4 + col) % 5 == 1:
				_prop("classroom/apple", p + Vector3(-0.2, 0.74, 0.05))
			if (row * 4 + col) % 4 == 2:
				_prop("classroom/school_bag", p + Vector3(0.3, 0, 0.55))
	_prop("classroom/chalkboard", Vector3(0, 0, -3.35))
	_prop("classroom/teacher_desk", Vector3(1.8, 0, -2.3))
	_prop("classroom/laptop", Vector3(1.6, 0.79, -2.3), 160)
	_prop("sains/planet_earth", Vector3(2.15, 0.79, -2.3))
	_prop("classroom/globe", Vector3(-3.6, 0, -2.6))
	_prop("classroom/bookshelf", Vector3(-4.4, 0, 0.6), 90)
	_prop("classroom/wall_clock", Vector3(0, 2.25, -3.42))
	_prop("sains/potted_plant", Vector3(4.2, 0, -2.8))
	_prop("classroom/trophy", Vector3(2.3, 0.79, -2.1))
	_prop("sejarah/flag_pole", Vector3(-4.3, 0, -3.0))
	_prop("matematik/sempoa", Vector3(1.2, 0.79, -2.2))
	_cam.target = Vector3(0, 0.7, -0.6)
	_cam.distance = 6.8
	_cam.pitch = -0.45
	_cam.yaw = 0.35
	_cam.max_distance = 16
	add_child(_cam)
	var ui := CanvasLayer.new()
	add_child(ui)
	KitUtil.home_button(ui)
	_label.theme_type_variation = "LabelTitle"
	_label.add_theme_color_override("font_outline_color", Color.WHITE)
	_label.add_theme_constant_override("outline_size", 16)
	_label.set_anchors_preset(Control.PRESET_CENTER_TOP)
	_label.position = Vector2(-600, 40)
	_label.size = Vector2(1200, 90)
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.text = GameState.tr2("Klik objek untuk mengenalinya", "Click an object to learn its name")
	ui.add_child(_label)
	Audio.music("santai_kampung")
	KitUtil.maybe_shot(self, "demo_classroom3d", 3.0)


func _prop(ref: String, pos: Vector3, yaw_deg := 0.0) -> Prop3D:
	var p := Prop3D.new()
	p.ref = ref
	p.position = pos
	p.rotation_degrees.y = yaw_deg
	p.clicked.connect(_on_click)
	add_child(p)
	return p


func _on_click(ref: String) -> void:
	var e := EduAssets.model_entry(ref)
	_label.text = "%s  ·  %s" % [e.bm, e.en]
	var art := ref.replace("classroom/", "bahasa_melayu/")  # speak if a matching vocab picture exists
	var sub := ref.get_slice("/", 0)
	if EduAssets.has(art):
		Audio.say_vocab("bahasa_melayu", ref.get_slice("/", 1))
	elif EduAssets.has(sub + "/" + ref.get_slice("/", 1)) and sub != "classroom":
		Audio.say_vocab(sub, ref.get_slice("/", 1))


func _env() -> void:
	var we := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color("9fd3f0")
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.9, 0.85, 0.8)
	env.ambient_light_energy = 0.2  # calibrated: sun 0.8 alone already gives true albedo
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	we.environment = env
	add_child(we)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-55, 30, 0)
	sun.light_energy = 0.55
	sun.shadow_enabled = true
	add_child(sun)


func _room() -> void:
	var mk := func(size: Vector3, pos: Vector3, col: Color):
		var m := MeshInstance3D.new()
		var b := BoxMesh.new()
		b.size = size
		m.mesh = b
		var mat := StandardMaterial3D.new()
		mat.albedo_color = col
		mat.roughness = 1.0
		mat.metallic_specular = 0.1
		m.material_override = mat
		m.position = pos
		add_child(m)
	mk.call(Vector3(10, 0.1, 8), Vector3(0, -0.05, 0), Color("c9a27a"))
	mk.call(Vector3(10, 3.5, 0.1), Vector3(0, 1.75, -3.5), Color("fbe7c6"))
	mk.call(Vector3(0.1, 3.5, 8), Vector3(-5, 1.75, 0), Color("f3d3a0"))
	mk.call(Vector3(10, 0.9, 0.12), Vector3(0, 0.45, -3.44), Color("e9b97f"))
