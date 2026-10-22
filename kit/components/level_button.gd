## Level-map node: locked / open / done art, level number and earned stars,
## read from GameState so a map is just a row of these.
class_name LevelButton
extends TextureButton

signal chosen(level: int)

@export var game_id := "demo"
@export var level := 1
@export var always_open := false  ## e.g. class/team mode where the teacher picks any level

var _num := Label.new()
var _stars := HBoxContainer.new()


func _init() -> void:
	ignore_texture_size = true
	stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	custom_minimum_size = Vector2(140, 140)


func _ready() -> void:
	_num.set_anchors_preset(Control.PRESET_FULL_RECT)
	_num.offset_bottom = -12
	_num.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_num.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_num.theme_type_variation = "LabelHeading"
	_num.add_theme_color_override("font_color", Color.WHITE)
	_num.add_theme_color_override("font_outline_color", Color("2b2d42"))
	_num.add_theme_constant_override("outline_size", 10)
	_num.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_num)
	_stars.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	_stars.position.y = custom_minimum_size.y - 18
	_stars.alignment = BoxContainer.ALIGNMENT_CENTER
	_stars.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_stars)
	pressed.connect(_on_pressed)
	GameState.progress_changed.connect(refresh)
	refresh()


func refresh() -> void:
	var open := always_open or GameState.is_unlocked(game_id, level)
	var n := GameState.stars_for(game_id, level)
	texture_normal = load("res://assets/art/ui/level_node_%s.svg" % ("locked" if not open else ("done" if n > 0 else "open")))
	_num.text = str(level) if open else ""
	disabled = not open
	for c in _stars.get_children():
		c.queue_free()
	if open:
		for i in 3:
			var s := TextureRect.new()
			s.texture = load("res://assets/art/icons/%s.svg" % ("star" if i < n else "star_empty"))
			s.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			s.custom_minimum_size = Vector2(36, 36)
			_stars.add_child(s)
		_stars.position.x = (custom_minimum_size.x - 3 * 36) / 2


func _on_pressed() -> void:
	Audio.sfx("ui_click")
	chosen.emit(level)
