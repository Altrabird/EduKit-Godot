## Shared frame for the 2D lab missions: lab background, header with back button,
## Cikgu Nurul's instruction line, mistake counter and the results panel.
class_name Mission2D
extends Control

var mistakes := 0
var body := VBoxContainer.new()
var _say := Label.new()
var _results := ResultsPanel.new()
var _nurul := Character2D.new()


func setup(index: int, instruction: String, voice_id := "") -> void:
	Makmal.mission = index
	KitUtil.background(self, "backgrounds/science_lab")
	var dim := ColorRect.new()
	dim.color = Color(1, 1, 1, 0.25)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(dim)
	_nurul.char_id = "nurul"
	_nurul.height_px = 440
	_nurul.position = Vector2(1720, 1070)
	add_child(_nurul)
	var top := HBoxContainer.new()
	top.position = Vector2(24, 20)
	top.add_theme_constant_override("separation", 18)
	add_child(top)
	var back := Button.new()
	back.icon = EduAssets.texture("icons/back")
	back.expand_icon = true
	back.custom_minimum_size = Vector2(88, 88)
	back.theme_type_variation = "ButtonYellow"
	back.pressed.connect(func(): Audio.sfx("ui_back"); Fader.go(Makmal.HUB))
	top.add_child(back)
	var t := Label.new()
	t.text = Makmal.name_of(index)
	t.theme_type_variation = "LabelTitle"
	t.add_theme_color_override("font_color", Color("3a86ff"))
	t.add_theme_color_override("font_outline_color", Color.WHITE)
	t.add_theme_constant_override("outline_size", 14)
	top.add_child(t)
	var bubble := PanelContainer.new()
	bubble.theme_type_variation = "PanelCream"
	bubble.position = Vector2(1180, 30)
	bubble.custom_minimum_size = Vector2(700, 0)
	_say.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_say.theme_type_variation = "LabelHeading"
	_say.add_theme_font_size_override("font_size", 32)
	_say.custom_minimum_size = Vector2(660, 0)
	bubble.add_child(_say)
	add_child(bubble)
	body.position = Vector2(40, 140)
	body.size = Vector2(1500, 900)
	body.add_theme_constant_override("separation", 20)
	add_child(body)
	_results.retry.connect(func(): get_tree().reload_current_scene())
	_results.next.connect(func(): Fader.go(Makmal.HUB))
	_results.menu.connect(func(): Fader.go(Makmal.HUB))
	add_child(_results)
	say(instruction)
	if voice_id != "":
		Audio.say("feedback", voice_id)
	Audio.music("jelajah_santai")


func say(text: String, expr := "talk") -> void:
	_say.text = text
	_nurul.expression = expr
	_nurul.talk(1.2)


func wrong(text := "") -> void:
	mistakes += 1
	Audio.sfx("wrong")
	_nurul.react(false)
	if text != "":
		say(text, "sad")


func finish() -> void:
	var s := Makmal.stars(mistakes)
	GameState.record_level(Makmal.GAME, Makmal.mission + 1, s, 3 - mini(mistakes, 3))
	_nurul.cheer()
	_results.open(3 - mini(mistakes, 2) if s < 3 else 3, 3)
