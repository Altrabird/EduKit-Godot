## Mission 5: a fair-test experiment. Predict which pot grows best (A: water + light,
## B: no water, C: no light), run a 7-day time-lapse, then answer what plants need.
extends Mission2D

const POTS := [[true, true], [false, true], [true, false]]  # water, light

var _pots: Array[TextureRect] = []
var _day := Label.new()
var _row := HBoxContainer.new()
var _ask := HBoxContainer.new()
var _phase := "predict"


func _ready() -> void:
	setup(4, GameState.tr2("Tiga pasu: A ada air dan cahaya, B tiada air, C tiada cahaya. Pokok manakah akan tumbuh paling subur?", "Three pots: A has water and light, B has no water, C has no light. Which plant will grow best?"), "lab_plant")
	_day.theme_type_variation = "LabelTitle"
	body.add_child(_day)
	_row.add_theme_constant_override("separation", 60)
	body.add_child(_row)
	for i in 3:
		var v := VBoxContainer.new()
		var t := TextureRect.new()
		t.texture = EduAssets.texture("sains/plant_seed")
		t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		t.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		t.custom_minimum_size = Vector2(320, 320)
		v.add_child(t)
		_pots.append(t)
		var l := Label.new()
		var water := GameState.tr2("Air ✓", "Water ✓") if POTS[i][0] else GameState.tr2("Air ✗", "Water ✗")
		var light := GameState.tr2("Cahaya ✓", "Light ✓") if POTS[i][1] else GameState.tr2("Cahaya ✗", "Light ✗")
		l.text = "%s\n%s  %s" % ["ABC"[i], water, light]
		l.theme_type_variation = "LabelHeading"
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		v.add_child(l)
		_row.add_child(v)
	_ask.add_theme_constant_override("separation", 20)
	body.add_child(_ask)
	_choices(["A", "B", "C"], 0, _after_predict)
	KitUtil.maybe_shot(self, "makmal_plant", 2.0)


func _choices(opts: Array, correct: int, done: Callable) -> void:
	for c in _ask.get_children():
		c.queue_free()
	for i in opts.size():
		var b := AnswerButton.new()
		b.index = i % 4
		b.text = opts[i]
		b.custom_minimum_size = Vector2(340, 110)
		b.pressed.connect(func():
			if i == correct:
				b.mark(true)
				Audio.sfx("correct")
				done.call()
			else:
				b.mark(false)
				wrong())
		_ask.add_child(b)


func _after_predict() -> void:
	for c in _ask.get_children():
		c.queue_free()
	say(GameState.tr2("Mari perhatikan selama 7 hari...", "Let's watch for 7 days..."))
	var stages := ["sains/plant_seed", "sains/plant_sprout", "sains/plant_young", "sains/plant_young", "sains/plant_flower", "sains/plant_flower", "sains/plant_fruit"]
	for d in range(1, 8):
		_day.text = GameState.tr2("Hari %d", "Day %d") % d
		Audio.sfx("countdown_tick")
		for i in 3:
			var how := Makmal.plant_grows(POTS[i][0], POTS[i][1])
			var stage: String = stages[d - 1] if how == "healthy" else stages[mini(d - 1, 2)]
			_pots[i].texture = EduAssets.texture(stage)
			if how == "wilted" and d >= 4:
				_pots[i].modulate = Color(0.75, 0.6, 0.35)
			elif how == "pale" and d >= 3:
				_pots[i].modulate = Color(1.0, 1.0, 0.55)
		await get_tree().create_timer(0.7).timeout
	say(GameState.tr2("Pokok A tumbuh subur. B layu kerana tiada air. C pucat kerana tiada cahaya. Apakah keperluan asas tumbuhan?", "Plant A grew well. B wilted with no water. C turned pale with no light. What do plants need?"))
	_choices([GameState.tr2("Air dan cahaya matahari", "Water and sunlight"), GameState.tr2("Gula dan garam", "Sugar and salt"), GameState.tr2("Plastik dan kertas", "Plastic and paper")], 0, func():
		say(GameState.tr2("Betul! Tumbuhan memerlukan air, cahaya matahari dan udara.", "Correct! Plants need water, sunlight and air."), "happy")
		finish())
