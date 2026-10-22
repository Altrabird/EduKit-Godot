## Mission 1 (3D): click a planet in the tray, then click its orbit ring around the Sun.
## Right order -> it starts orbiting. Drag to look around, wheel to zoom.
extends Node3D

var selected := ""
var placed := {}
var mistakes := 0
var _planets := {}           # id -> Prop3D
var _orbit := {}             # id -> angle
var _labels := {}            # id -> Label3D (siblings, so planet scale doesn't stretch the text)
var _cam := OrbitCamera3D.new()
var _say := Label.new()
var _results := ResultsPanel.new()
var _press := Vector2.ZERO


func _ready() -> void:
	Makmal.mission = 0
	var we := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color("0b1026")
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.7, 0.75, 1.0)
	env.ambient_light_energy = 0.35
	we.environment = env
	add_child(we)
	var sunlight := OmniLight3D.new()
	sunlight.omni_range = 40
	sunlight.light_energy = 1.6
	sunlight.position = Vector3(0, 1.2, 0)
	add_child(sunlight)
	var sun := Prop3D.new()
	sun.ref = "sains/planet_sun"
	sun.spin_speed = 0.2
	sun.input_ray_pickable = false
	add_child(sun)
	for i in Makmal.PLANETS.size():
		var ring := MeshInstance3D.new()
		var t := TorusMesh.new()
		t.inner_radius = Makmal.ring_radius(i) - 0.03
		t.outer_radius = Makmal.ring_radius(i) + 0.03
		t.rings = 96
		ring.mesh = t
		var m := StandardMaterial3D.new()
		m.albedo_color = Color(0.7, 0.8, 1.0, 0.55)
		m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		ring.material_override = m
		ring.position.y = 0.6
		add_child(ring)
	var order := Makmal.PLANETS.duplicate()
	order.shuffle()
	for k in order.size():
		var id: String = order[k]
		var p := Prop3D.new()
		p.ref = "sains/planet_" + id
		p.position = Vector3(-6.3 + k * 1.8, 0.0, 9.4)
		var diameter: float = EduAssets.model_entry(p.ref).size_m[0]
		p.scale = Vector3.ONE * clampf(0.9 / diameter, 1.0, 6.0)  # every planet ~0.9 m wide so it's easy to click
		add_child(p)
		_planets[id] = p
		var l := Label3D.new()
		l.text = EduAssets.name_of("sains/planet_" + id)
		l.font = preload("res://assets/fonts/Fredoka.ttf")
		l.font_size = 56
		l.outline_size = 14
		l.pixel_size = 0.005
		l.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		add_child(l)
		_labels[id] = l
	_cam.target = Vector3(0, 0.3, 3.6)
	_cam.distance = 13.0
	_cam.pitch = -0.85
	_cam.yaw = 0.0
	_cam.auto_rotate = 0.0
	add_child(_cam)
	_ui()
	_tell(GameState.tr2("Klik satu planet, kemudian klik orbitnya. Mula dengan planet paling dekat dengan Matahari!", "Click a planet, then click its orbit. Start with the planet closest to the Sun!"))
	Audio.say("feedback", "lab_solar")
	Audio.music("quiz_berfikir")
	KitUtil.maybe_shot(self, "makmal_solar", 3.0)


func _ui() -> void:
	var ui := CanvasLayer.new()
	add_child(ui)
	var back := Button.new()
	back.icon = EduAssets.texture("icons/back")
	back.expand_icon = true
	back.custom_minimum_size = Vector2(88, 88)
	back.position = Vector2(24, 20)
	back.theme_type_variation = "ButtonYellow"
	back.pressed.connect(func(): Fader.go(Makmal.HUB))
	ui.add_child(back)
	var p := PanelContainer.new()
	p.theme_type_variation = "PanelCream"
	p.position = Vector2(130, 20)
	p.custom_minimum_size = Vector2(1100, 0)
	_say.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_say.theme_type_variation = "LabelHeading"
	_say.custom_minimum_size = Vector2(1060, 0)
	p.add_child(_say)
	ui.add_child(p)
	_results.retry.connect(func(): get_tree().reload_current_scene())
	_results.next.connect(func(): Fader.go(Makmal.HUB))
	_results.menu.connect(func(): Fader.go(Makmal.HUB))
	ui.add_child(_results)


func _tell(t: String) -> void:
	_say.text = t


func _process(delta: float) -> void:
	for id in _labels:
		_labels[id].visible = not id in placed
		_labels[id].position = _planets[id].position + Vector3(0, -0.35, 0.75)
	for id in placed:
		var i := Makmal.PLANETS.find(id)
		_orbit[id] = _orbit.get(id, 0.0) + delta * 0.9 / pow(Makmal.ring_radius(i), 1.5)
		var r := Makmal.ring_radius(i)
		_planets[id].position = Vector3(cos(_orbit[id]) * r, 0.6 - 0.3, sin(_orbit[id]) * r)


func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT):
		return
	if event.pressed:
		_press = event.position
		return
	if event.position.distance_to(_press) > 12:  # it was a camera drag, not a click
		return
	var from := _cam.project_ray_origin(event.position)
	var dir := _cam.project_ray_normal(event.position)
	var hit := get_world_3d().direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(from, from + dir * 100))
	if hit and hit.collider is Prop3D and hit.collider.ref.begins_with("sains/planet_"):
		_select(hit.collider.ref.trim_prefix("sains/planet_"))
		return
	if selected == "" or absf(dir.y) < 0.001:
		return
	var t := (0.6 - from.y) / dir.y
	var p := from + dir * t
	var ring := Makmal.ring_at(Vector2(p.x, p.z).length())
	if ring >= 0:
		_place(selected, ring)


func select_planet(id: String) -> void:
	_select(id)


func _select(id: String) -> void:
	if id in placed:
		return
	if selected != "":
		_planets[selected].position.y = 0.0
	selected = id
	_planets[id].position.y = 0.6
	Audio.sfx("pick_up")
	Audio.say_vocab("sains", "planet_" + id)
	_tell(GameState.tr2("%s dipilih. Klik orbitnya.", "%s selected. Click its orbit.") % EduAssets.name_of("sains/planet_" + id))


func _place(id: String, ring: int) -> void:
	var want := Makmal.PLANETS.find(id)
	if ring != want:
		mistakes += 1
		Audio.sfx("wrong")
		_tell(GameState.tr2("Bukan orbit itu. %s ialah planet ke-%d dari Matahari.", "Not that orbit. %s is planet number %d from the Sun.") % [EduAssets.name_of("sains/planet_" + id), want + 1])
		return
	placed[id] = true
	_orbit[id] = randf() * TAU
	selected = ""
	Audio.sfx("correct")
	if placed.size() == Makmal.PLANETS.size():
		_tell(GameState.tr2("Hebat! Utarid, Zuhrah, Bumi, Marikh, Musytari, Zuhal, Uranus, Neptun.", "Amazing! Mercury, Venus, Earth, Mars, Jupiter, Saturn, Uranus, Neptune."))
		Audio.sfx("win_fanfare")
		_cam.auto_rotate = 0.2
		var s := Makmal.stars(mistakes)
		GameState.record_level(Makmal.GAME, 1, s, 8 - mini(mistakes, 8))
		await get_tree().create_timer(2.5).timeout
		_results.open(3 if s == 3 else (2 if s == 2 else 1), 3)
	else:
		_tell(GameState.tr2("Betul! %d/8 planet di orbit.", "Correct! %d/8 planets in orbit.") % placed.size())
