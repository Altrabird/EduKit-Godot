## A letter / syllable / number / word tile drawn with the bundled font on a blank
## tile skin, so one art set serves every language subject. Optional drag-and-drop:
## set `draggable` and `key`, then drop onto a DropSlot with the same key.
class_name TextTile
extends Control

signal pressed

const COLORS := ["red", "orange", "yellow", "green", "blue", "purple", "white", "wood"]
const FONT := preload("res://assets/fonts/Fredoka.ttf")

@export var text := "A":
	set(v):
		text = v
		if _label:
			_label.text = v
			_fit()
@export_enum("red", "orange", "yellow", "green", "blue", "purple", "white", "wood") var color := "blue":
	set(v):
		color = v
		if _bg:
			_apply_color()
@export var draggable := false
@export var key := ""  ## matched by DropSlot.accept_key; defaults to text
@export var speak_group := ""  ## e.g. "syllables" or "letters": plays voice on tap if set

var _bg := TextureRect.new()
var _label := Label.new()


func _init() -> void:
	custom_minimum_size = Vector2(128, 128)
	mouse_filter = Control.MOUSE_FILTER_STOP


func _ready() -> void:
	pivot_offset = size / 2
	_bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	_bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_bg.stretch_mode = TextureRect.STRETCH_SCALE
	_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_bg)
	_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	_label.offset_bottom = -size.y * 0.06
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_label.add_theme_font_override("font", FONT)
	_label.add_theme_constant_override("outline_size", 10)
	add_child(_label)
	_label.text = text
	_apply_color()
	resized.connect(_fit)
	_fit()


func _apply_color() -> void:
	_bg.texture = load("res://assets/art/ui/tile_%s.svg" % color)
	var dark := color in ["white", "yellow", "wood"]
	_label.add_theme_color_override("font_color", Color("2b2d42") if dark else Color.WHITE)
	_label.add_theme_color_override("font_outline_color", Color(1, 1, 1, 0.6) if dark else Color("2b2d42"))


func _fit() -> void:
	# Shrink long words so they stay on the tile.
	var by_height := size.y * 0.55
	var by_width := size.x * 1.45 / maxf(1.0, text.length())
	_label.add_theme_font_size_override("font_size", int(minf(by_height, by_width)))
	pivot_offset = size / 2


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		Audio.sfx("pop", 0.1)
		if speak_group != "":
			Audio.say(speak_group, (key if key != "" else text).to_lower())
		var tw := create_tween()
		tw.tween_property(self, "scale", Vector2(0.9, 0.9), 0.06)
		tw.tween_property(self, "scale", Vector2.ONE, 0.12).set_trans(Tween.TRANS_BACK)
		pressed.emit()


func _get_drag_data(_at: Vector2) -> Variant:
	if not draggable:
		return null
	Audio.sfx("pick_up")
	var preview := TextTile.new()
	preview.text = text
	preview.color = color
	preview.size = size
	preview.modulate.a = 0.85
	var holder := Control.new()
	holder.add_child(preview)
	preview.position = -size / 2
	set_drag_preview(holder)
	modulate.a = 0.35
	return {"key": key if key != "" else text, "node": self}


func _notification(what: int) -> void:
	if what == NOTIFICATION_DRAG_END:
		modulate.a = 1.0
