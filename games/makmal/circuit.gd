## Mission 4 (Sains + RBT): build a closed loop from parts, avoid insulators, flip the
## switch. Three levels: bulb, motor, LED + resistor.
extends Mission2D

var level := 0
var placed: Array = []
var switch_on := false
var _board := Control.new()
var _slots: Array[DropSlot] = []
var _palette := HBoxContainer.new()
var _toggle := Button.new()
var _goal := Label.new()
var _load_sprite: TextureRect

const SLOT_POS := [[Vector2(140, 200), Vector2(620, 40), Vector2(1100, 200)], [Vector2(140, 200), Vector2(620, 40), Vector2(1100, 200), Vector2(620, 360)]]


func _ready() -> void:
	setup(3, GameState.tr2("Seret komponen ke dalam litar, kemudian hidupkan suis.", "Drag parts into the circuit, then turn on the switch."), "lab_circuit")
	_goal.theme_type_variation = "LabelHeading"
	body.add_child(_goal)
	_board.custom_minimum_size = Vector2(1400, 520)
	body.add_child(_board)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 20)
	body.add_child(row)
	_palette.add_theme_constant_override("separation", 10)
	row.add_child(_palette)
	_toggle.custom_minimum_size = Vector2(260, 110)
	_toggle.pressed.connect(_flip)
	row.add_child(_toggle)
	_start()
	KitUtil.maybe_shot(self, "makmal_circuit", 2.0)


func _start() -> void:
	for c in _board.get_children() + _palette.get_children():
		c.get_parent().remove_child(c)
		c.queue_free()
	_slots.clear()
	placed = []
	switch_on = false
	var spec: Dictionary = Makmal.CIRCUITS[level]
	_goal.text = "%s %d/3: %s" % [GameState.tr2("Litar", "Circuit"), level + 1, spec.goal[0 if GameState.lang == "ms" else 1]]
	var pos: Array = SLOT_POS[0 if spec.slots == 3 else 1]
	var wire := Line2D.new()
	wire.width = 14
	wire.default_color = Color("2b2d42")
	for p in pos:
		wire.add_point(p + Vector2(80, 80))
	wire.add_point(pos[0] + Vector2(80, 80))
	_board.add_child(wire)
	for i in pos.size():
		var s := DropSlot.new()
		s.accept_key = ""
		s.custom_minimum_size = Vector2(160, 160)
		s.size = Vector2(160, 160)
		s.position = pos[i]
		s.dropped.connect(func(_ok, key, _item): _on_placed(i, key))
		_board.add_child(s)
		_slots.append(s)
		placed.append("")
	var parts := Makmal.PARTS.keys()
	parts.shuffle()
	for r in parts:
		var c := PictureCard.new()
		c.ref = r
		c.draggable = true
		c.custom_minimum_size = Vector2(150, 175)
		_palette.add_child(c)
	_refresh_toggle()


func _on_placed(i: int, key: String) -> void:
	placed[i] = key
	if Makmal.PARTS.get(key) == "insulator":
		Audio.say("feedback", "lab_insulator")
		say(GameState.tr2("%s ialah penebat — elektrik tidak boleh mengalir melaluinya!", "%s is an insulator — electricity can't flow through it!") % EduAssets.name_of(key), "surprised")


func _flip() -> void:
	switch_on = not switch_on
	Audio.sfx("ui_toggle")
	_refresh_toggle()
	if not switch_on:
		return
	var res := Makmal.circuit_result(level, placed, switch_on)
	if res == "":
		_success()
		return
	var why: String = {"open": GameState.tr2("Litar belum lengkap — isi semua kotak.", "The circuit has a gap — fill every box."),
		"insulator": GameState.tr2("Ada penebat dalam litar. Keluarkan dan cuba lagi.", "There's an insulator in the circuit. Take it out and try again."),
		"missing_source": GameState.tr2("Litar perlukan sumber tenaga: bateri.", "The circuit needs a power source: a battery."),
		"missing_switch": GameState.tr2("Tambah suis untuk mengawal litar.", "Add a switch to control the circuit."),
		"missing_resistor": GameState.tr2("LED perlukan perintang supaya tidak rosak.", "An LED needs a resistor so it doesn't burn out."),
	}.get(res, GameState.tr2("Komponen itu tidak sesuai untuk matlamat ini.", "That part doesn't match this goal."))
	wrong(why)
	switch_on = false
	_refresh_toggle()
	if res == "insulator" or res.begins_with("missing"):
		for i in _slots.size():
			_slots[i].clear()
		placed.fill("")
		_restock()


func _restock() -> void:
	for c in _palette.get_children():
		c.queue_free()
	var parts := Makmal.PARTS.keys()
	parts.shuffle()
	for r in parts:
		var c := PictureCard.new()
		c.ref = r
		c.draggable = true
		c.custom_minimum_size = Vector2(150, 175)
		_palette.add_child(c)


func _refresh_toggle() -> void:
	_toggle.text = GameState.tr2("Suis: HIDUP", "Switch: ON") if switch_on else GameState.tr2("Suis: MATI", "Switch: OFF")
	_toggle.theme_type_variation = "ButtonGreen" if switch_on else "ButtonRed"


func _success() -> void:
	Audio.say("feedback", "lab_lit")
	for s in _slots:
		for c in s.get_children():
			if c is PictureCard and Makmal.PARTS.get(c.ref) in ["bulb", "led", "motor"]:
				var tw := c.create_tween().set_loops(4)
				if Makmal.PARTS[c.ref] == "motor":
					c.pivot_offset = c.size / 2
					tw.tween_property(c, "rotation", TAU, 0.4).from(0.0)
				else:
					tw.tween_property(c, "modulate", Color(1.6, 1.6, 0.9), 0.2)
					tw.tween_property(c, "modulate", Color(1.2, 1.2, 1.0), 0.2)
	Feedback.result(self, true, false)
	await get_tree().create_timer(2.2).timeout
	level += 1
	if level >= Makmal.CIRCUITS.size():
		say(GameState.tr2("Syabas, jurutera muda! Litar lengkap perlukan sumber, suis dan beban.", "Well done, young engineer! A complete circuit needs a source, a switch and a load."), "happy")
		finish()
	else:
		_start()
