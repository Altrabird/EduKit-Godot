## Shared frame for Kampungku Sihat activities: background, title, guide pupil with a
## speech panel, mistakes, results back to the village map.
class_name KampungActivity
extends Control

var mistakes := 0
var index := 0
var body := VBoxContainer.new()
var guide := Character2D.new()
var _say := Label.new()
var _results := ResultsPanel.new()


func setup(i: int, background: String, instruction: String, voice_id := "", guide_id := "aisyah") -> void:
	index = i
	KitUtil.background(self, background)
	var dim := ColorRect.new()
	dim.color = Color(1, 1, 1, 0.22)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(dim)
	guide.char_id = guide_id
	guide.height_px = 400
	guide.position = Vector2(1760, 1070)
	add_child(guide)
	var top := HBoxContainer.new()
	top.position = Vector2(24, 20)
	top.add_theme_constant_override("separation", 18)
	add_child(top)
	var back := Button.new()
	back.icon = EduAssets.texture("icons/back")
	back.expand_icon = true
	back.custom_minimum_size = Vector2(88, 88)
	back.theme_type_variation = "ButtonYellow"
	back.pressed.connect(func(): Audio.sfx("ui_back"); Fader.go(Kampung.MAP))
	top.add_child(back)
	var t := Label.new()
	t.text = Kampung.name_of(i)
	t.theme_type_variation = "LabelTitle"
	t.add_theme_color_override("font_color", Color("2d936c"))
	t.add_theme_color_override("font_outline_color", Color.WHITE)
	t.add_theme_constant_override("outline_size", 14)
	top.add_child(t)
	var bubble := PanelContainer.new()
	bubble.theme_type_variation = "PanelCream"
	bubble.position = Vector2(1160, 30)
	bubble.custom_minimum_size = Vector2(730, 0)
	_say.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_say.theme_type_variation = "LabelHeading"
	_say.add_theme_font_size_override("font_size", 32)
	_say.custom_minimum_size = Vector2(690, 0)
	bubble.add_child(_say)
	add_child(bubble)
	body.position = Vector2(40, 150)
	body.size = Vector2(1560, 900)
	body.add_theme_constant_override("separation", 18)
	add_child(body)
	_results.retry.connect(func(): get_tree().reload_current_scene())
	_results.next.connect(func(): Fader.go(Kampung.MAP))
	_results.menu.connect(func(): Fader.go(Kampung.MAP))
	add_child(_results)
	say(instruction)
	if voice_id != "":
		Audio.say("feedback", voice_id)
	Audio.music("santai_kampung")


func say(text: String, expr := "talk") -> void:
	_say.text = text
	guide.expression = expr
	guide.talk(1.2)


func wrong(text := "") -> void:
	mistakes += 1
	Audio.sfx("wrong")
	guide.react(false)
	if text != "":
		say(text, "sad")


func finish() -> void:
	var s := Kampung.stars(mistakes)
	GameState.record_level(Kampung.GAME, index + 1, s, 3 - mini(mistakes, 3))
	guide.cheer()
	_results.open(s, 3)


## Drop target that takes many PictureCards whose category matches `category`.
class Zone extends PanelContainer:
	signal sorted(ok: bool, ref: String)
	var category := ""
	var title := ""
	var answers := {}  ## ref -> category
	var tint := Color("fdfcf7")
	var flow := HFlowContainer.new()
	var icon_ref := ""

	func _ready() -> void:
		var sb := StyleBoxFlat.new()
		sb.bg_color = tint
		sb.set_corner_radius_all(24)
		sb.set_border_width_all(5)
		sb.border_color = Color("2b2d42")
		sb.content_margin_left = 14
		sb.content_margin_right = 14
		sb.content_margin_top = 10
		sb.content_margin_bottom = 10
		add_theme_stylebox_override("panel", sb)
		var v := VBoxContainer.new()
		add_child(v)
		var h := HBoxContainer.new()
		v.add_child(h)
		if icon_ref != "":
			var ic := TextureRect.new()
			ic.texture = EduAssets.texture(icon_ref)
			ic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			ic.custom_minimum_size = Vector2(90, 90)
			h.add_child(ic)
		var l := Label.new()
		l.text = title
		l.theme_type_variation = "LabelHeading"
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		h.add_child(l)
		flow.add_theme_constant_override("h_separation", 6)
		v.add_child(flow)

	func _can_drop_data(_at: Vector2, data: Variant) -> bool:
		return data is Dictionary and data.has("key") and data.get("node") is PictureCard

	func _drop_data(_at: Vector2, data: Variant) -> void:
		var ref: String = data.key
		if answers.get(ref, "") == category:
			var card: PictureCard = data.node
			card.reparent(flow, false)
			card.custom_minimum_size = Vector2(100, 110)
			card.show_name = false
			card._refresh()
			card.draggable = false
			Audio.sfx("snap")
			sorted.emit(true, ref)
		else:
			sorted.emit(false, ref)
