## Bottom-of-screen dialogue with character portrait, name and typewriter text.
##   box.play([{"char": "nurul", "expr": "happy", "text": "Selamat datang!"},
##             {"char": "robo", "expr": "talk", "text": "Mari belajar!", "voice": ["feedback", "lets_start"]}])
## Click / Enter / Space: finish the line, then advance. Emits `finished`.
class_name DialogueBox
extends PanelContainer

signal line_started(index: int)
signal finished

const NAMES := {"aiman": "Aiman", "aisyah": "Aisyah", "meiling": "Mei Ling", "weijie": "Wei Jie", "kavitha": "Kavitha",
	"arjun": "Arjun", "jaiden": "Jaiden", "nurul": "Cikgu Nurul", "rahman": "Cikgu Rahman", "kenyalang": "Kenny", "robo": "Robo"}

@export var chars_per_second := 40.0

var _lines: Array = []
var _i := -1
var _portrait := TextureRect.new()
var _name := Label.new()
var _text := RichTextLabel.new()
var _next := Label.new()
var _typing := false
var _visible_f := 0.0


func _ready() -> void:
	theme_type_variation = "PanelCream"
	set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	offset_top = -300
	offset_left = 40
	offset_right = -40
	offset_bottom = -30
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 24)
	add_child(h)
	_portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	_portrait.custom_minimum_size = Vector2(220, 240)
	h.add_child(_portrait)
	var v := VBoxContainer.new()
	v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	h.add_child(v)
	_name.theme_type_variation = "LabelHeading"
	_name.add_theme_color_override("font_color", Color("3a86ff"))
	v.add_child(_name)
	_text.bbcode_enabled = true
	_text.fit_content = true
	_text.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_text.add_theme_color_override("default_color", Color("2b2d42"))
	_text.add_theme_font_size_override("normal_font_size", 34)
	_text.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v.add_child(_text)
	_next.text = "▶"
	_next.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	v.add_child(_next)
	hide()


func play(lines: Array) -> void:
	_lines = lines
	_i = -1
	show()
	_advance()


func _advance() -> void:
	_i += 1
	if _i >= _lines.size():
		hide()
		finished.emit()
		return
	var l: Dictionary = _lines[_i]
	var c: String = l.get("char", "robo")
	_portrait.texture = EduAssets.texture(l.portrait) if l.has("portrait") else EduAssets.character(c, l.get("expr", "talk"))
	_name.text = l.get("name", NAMES.get(c, c.capitalize()))
	_text.text = l.text
	_text.visible_ratio = 0.0
	_visible_f = 0.0
	_typing = true
	_next.modulate.a = 0
	if l.has("voice"):
		Audio.say(l.voice[0], l.voice[1])
	line_started.emit(_i)


func _process(delta: float) -> void:
	if not _typing:
		_next.modulate.a = 0.5 + 0.5 * sin(Time.get_ticks_msec() / 200.0)
		return
	var total := _text.get_total_character_count()
	var before := int(_visible_f)
	_visible_f += chars_per_second * delta
	_text.visible_characters = int(_visible_f)
	if int(_visible_f) != before and int(_visible_f) % 3 == 0:
		Audio.sfx("typing_blip", 0.15, -8.0)
	if _visible_f >= total:
		_finish_line()


func _finish_line() -> void:
	_typing = false
	_text.visible_ratio = 1.0
	if _i >= 0 and _i < _lines.size():
		if not _lines[_i].has("portrait"):
			_portrait.texture = EduAssets.character(_lines[_i].get("char", "robo"), _lines[_i].get("expr_after", "neutral"))


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_tap()


func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_accept"):
		_tap()
		get_viewport().set_input_as_handled()


func _tap() -> void:
	if _typing:
		_finish_line()
	else:
		Audio.sfx("ui_click")
		_advance()
