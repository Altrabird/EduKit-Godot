## Scene transitions with a fade: Fader.go("res://demo/demo_quiz.tscn")
extends CanvasLayer

var _rect := ColorRect.new()
var busy := false


func _ready() -> void:
	layer = 100
	process_mode = Node.PROCESS_MODE_ALWAYS
	_rect.color = Color("2b2d42")
	_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_rect.modulate.a = 0.0
	add_child(_rect)


func go(scene_path: String, time := 0.35) -> void:
	if busy:
		return
	busy = true
	_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	await create_tween().tween_property(_rect, "modulate:a", 1.0, time).finished
	get_tree().paused = false
	get_tree().change_scene_to_file(scene_path)
	await get_tree().process_frame
	await create_tween().tween_property(_rect, "modulate:a", 0.0, time).finished
	_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	busy = false
