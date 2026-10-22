## Picture of any manifest asset with its name underneath (in the current language).
## Tap = speak the name (vocab voice). Can be dragged onto a DropSlot (key = ref).
class_name PictureCard
extends PanelContainer

signal pressed

@export var ref := "sains/planet_earth":
	set(v):
		ref = v
		if is_inside_tree():
			_refresh()
@export var show_name := true
@export var draggable := false
@export var key := ""

var _img := TextureRect.new()
var _name := Label.new()


func _init() -> void:
	custom_minimum_size = Vector2(220, 260)
	mouse_filter = Control.MOUSE_FILTER_STOP


func _ready() -> void:
	var v := VBoxContainer.new()
	v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(v)
	_img.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_img.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_img.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_img.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v.add_child(_img)
	_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_name.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_name.theme_type_variation = "LabelSmall"
	_name.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v.add_child(_name)
	GameState.lang_changed.connect(func(_l): _refresh())
	_refresh()


func _refresh() -> void:
	_img.texture = EduAssets.texture(ref)
	_name.text = EduAssets.name_of(ref)
	_name.visible = show_name


func speak() -> void:
	var e := EduAssets.entry(ref)
	if e.has("subject"):
		Audio.say_vocab(e.subject, e.id)


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		speak()
		pivot_offset = size / 2
		var tw := create_tween()
		tw.tween_property(self, "scale", Vector2(0.94, 0.94), 0.06)
		tw.tween_property(self, "scale", Vector2.ONE, 0.14).set_trans(Tween.TRANS_BACK)
		pressed.emit()


func _get_drag_data(_at: Vector2) -> Variant:
	if not draggable:
		return null
	Audio.sfx("pick_up")
	var p := TextureRect.new()
	p.texture = _img.texture
	p.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	p.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	p.size = Vector2(160, 160)
	p.position = -p.size / 2
	var holder := Control.new()
	holder.add_child(p)
	set_drag_preview(holder)
	modulate.a = 0.35
	return {"key": key if key != "" else ref, "node": self}


func _notification(what: int) -> void:
	if what == NOTIFICATION_DRAG_END:
		modulate.a = 1.0
