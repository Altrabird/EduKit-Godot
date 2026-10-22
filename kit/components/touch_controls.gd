## On-screen left / right / jump for tablets and phones. Uses multitouch
## TouchScreenButtons bound to the built-in ui_* actions, so Player2D needs no changes.
## Shown only on touch screens (desktop browsers keep the keyboard).
class_name TouchControls
extends CanvasLayer

@export var size_px := 170.0


func _ready() -> void:
	layer = 30
	var vp := get_viewport().get_visible_rect().size
	_add("icons/back", "ui_left", Vector2(40, vp.y - size_px - 40))
	_add("icons/next", "ui_right", Vector2(60 + size_px, vp.y - size_px - 40))
	_add("icons/up", "ui_accept", Vector2(vp.x - size_px - 50, vp.y - size_px - 40))


func _add(icon_ref: String, action: String, pos: Vector2) -> void:
	var b := TouchScreenButton.new()
	var tex := EduAssets.texture(icon_ref)
	b.texture_normal = tex
	b.action = action
	b.visibility_mode = TouchScreenButton.VISIBILITY_TOUCHSCREEN_ONLY
	b.scale = Vector2.ONE * size_px / tex.get_width()
	b.position = pos
	b.modulate.a = 0.75
	b.passby_press = true
	add_child(b)
