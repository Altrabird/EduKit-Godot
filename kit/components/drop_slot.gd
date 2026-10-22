## Target for TextTile / PictureCard drags. Correct drops snap the item in;
## wrong drops shake the slot and leave the item where it was.
class_name DropSlot
extends Control

signal dropped(correct: bool, key: String, item: Control)

@export var accept_key := ""
@export var label_text := ""  ## optional hint drawn in the empty slot
@export var snap_item := true

var filled := false
var _bg := TextureRect.new()
var _hint := Label.new()


func _init() -> void:
	custom_minimum_size = Vector2(140, 140)


func _ready() -> void:
	_bg.texture = load("res://assets/art/ui/tile_slot.svg")
	_bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	_bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_bg)
	_hint.text = label_text
	_hint.set_anchors_preset(Control.PRESET_FULL_RECT)
	_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_hint.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_hint.modulate.a = 0.45
	_hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_hint)


func _can_drop_data(_at: Vector2, data: Variant) -> bool:
	return not filled and data is Dictionary and data.has("key")


func _drop_data(_at: Vector2, data: Variant) -> void:
	var item: Control = data.get("node")
	var ok: bool = accept_key == "" or str(data.key) == accept_key
	if ok:
		filled = true
		Audio.sfx("snap")
		if snap_item and item:
			item.reparent(self, false)
			item.position = (size - item.size) / 2
			item.mouse_filter = Control.MOUSE_FILTER_IGNORE
			item.modulate.a = 1.0
		_hint.visible = false
		_bg.modulate = Color(0.6, 1, 0.6)
	else:
		Audio.sfx("wrong")
		var x := position.x
		var tw := create_tween()
		for d in [12, -12, 8, -8, 0]:
			tw.tween_property(self, "position:x", x + d, 0.04)
	dropped.emit(ok, str(data.key), item)


func clear() -> void:
	filled = false
	_hint.visible = true
	_bg.modulate = Color.WHITE
	for c in get_children():
		if c != _bg and c != _hint:
			c.queue_free()
