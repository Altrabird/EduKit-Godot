## Malaysian coin or note (stylised, value drawn on top) for money lessons.
## value_sen: 5, 10, 20, 50 (coins) or 100, 500, 1000, 2000, 5000, 10000 (RM1..RM100 notes).
class_name MoneyItem
extends TextureRect

const COINS := [5, 10, 20, 50]
const NOTES := [100, 500, 1000, 2000, 5000, 10000]

@export var value_sen := 50:
	set(v):
		value_sen = v
		_apply()
@export var draggable := true

var _label := Label.new()


func _init() -> void:
	expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED


func _ready() -> void:
	_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_label.add_theme_font_override("font", preload("res://assets/fonts/Fredoka.ttf"))
	_label.add_theme_color_override("font_color", Color("2b2d42"))
	_label.add_theme_color_override("font_outline_color", Color.WHITE)
	_label.add_theme_constant_override("outline_size", 8)
	_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_label)
	_apply()


func _apply() -> void:
	if not is_inside_tree():
		return
	if value_sen in COINS:
		texture = EduAssets.texture("matematik/coin_%dsen" % value_sen)
		custom_minimum_size = Vector2.ONE * (90 + COINS.find(value_sen) * 18)
		_label.text = "%d sen" % value_sen
		_label.add_theme_font_size_override("font_size", int(custom_minimum_size.x * 0.24))
		_label.offset_left = 0
	elif value_sen in NOTES:
		texture = EduAssets.texture("matematik/note_rm%d" % (value_sen / 100))
		custom_minimum_size = Vector2(300, 200)
		_label.text = "RM%d" % (value_sen / 100)
		_label.add_theme_font_size_override("font_size", 52)
		_label.offset_left = -110
	else:
		push_warning("MoneyItem: unsupported value %d sen" % value_sen)


static func format_rm(sen: int) -> String:
	return "RM%d.%02d" % [sen / 100, sen % 100]


func _get_drag_data(_at: Vector2) -> Variant:
	if not draggable:
		return null
	var p := MoneyItem.new()
	p.value_sen = value_sen
	p.size = size
	var h := Control.new()
	h.add_child(p)
	p.position = -size / 2
	set_drag_preview(h)
	return {"key": str(value_sen), "value_sen": value_sen, "node": self}
