## Bantu Jiran: six everyday moral choices; the neighbour reacts to each answer.
extends KampungActivity

var _i := 0
var _pic := TextureRect.new()
var _text := Label.new()
var _choices := VBoxContainer.new()
var _neighbour := Character2D.new()


func _ready() -> void:
	setup(3, "backgrounds/kampung", GameState.tr2("Apakah yang patut kamu lakukan?", "What should you do?"), "kg_help", "arjun")
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 30)
	body.add_child(row)
	_pic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_pic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_pic.custom_minimum_size = Vector2(300, 300)
	row.add_child(_pic)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 16)
	row.add_child(v)
	_text.theme_type_variation = "LabelTitle"
	_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_text.custom_minimum_size = Vector2(1000, 0)
	v.add_child(_text)
	_choices.add_theme_constant_override("separation", 14)
	v.add_child(_choices)
	_neighbour.char_id = "rahman"
	_neighbour.height_px = 380
	_neighbour.position = Vector2(1440, 1070)
	add_child(_neighbour)
	_show()
	KitUtil.maybe_shot(self, "kampung_help", 2.0)


func _show() -> void:
	for c in _choices.get_children():
		c.queue_free()
	var h: Array = Kampung.HELP[_i]
	var l := 0 if GameState.lang == "ms" else 1
	_text.text = "%d/%d  %s" % [_i + 1, Kampung.HELP.size(), h[0][l]]
	_pic.texture = EduAssets.texture(h[2])
	_neighbour.char_id = ["rahman", "nurul", "kavitha", "rahman", "meiling", "nurul"][_i]
	_neighbour.expression = "thinking"
	var order := [0, 1, 2]
	order.shuffle()
	for k in order.size():
		var b := AnswerButton.new()
		b.index = k
		b.text = h[1][order[k]][l]
		b.custom_minimum_size = Vector2(1000, 110)
		var right: bool = order[k] == 0
		b.pressed.connect(func():
			if right:
				b.mark(true)
				Audio.sfx("correct")
				_neighbour.react(true)
				await get_tree().create_timer(1.0).timeout
				_i += 1
				if _i >= Kampung.HELP.size():
					say(GameState.tr2("Kamu jiran yang baik hati!", "You are a kind neighbour!"), "happy")
					finish()
				else:
					_show()
			else:
				b.mark(false)
				_neighbour.react(false)
				wrong(GameState.tr2("Fikir semula. Apakah tindakan yang baik?", "Think again. What is the kind thing to do?")))
		_choices.add_child(b)
