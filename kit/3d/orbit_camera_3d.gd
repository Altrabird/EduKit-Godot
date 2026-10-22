## Mouse/touch orbit camera: drag to rotate, wheel/pinch to zoom, auto-rotate when idle.
class_name OrbitCamera3D
extends Camera3D

@export var target := Vector3(0, 0.8, 0)
@export var distance := 6.0
@export var min_distance := 1.0
@export var max_distance := 30.0
@export var yaw := 0.6
@export var pitch := -0.35
@export var auto_rotate := 0.15  ## rad/s while idle, 0 = off

var _idle := 0.0


func _ready() -> void:
	_apply()


func _process(delta: float) -> void:
	_idle += delta
	if auto_rotate != 0.0 and _idle > 2.0:
		yaw += auto_rotate * delta
		_apply()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and event.button_mask & (MOUSE_BUTTON_MASK_LEFT | MOUSE_BUTTON_MASK_RIGHT):
		yaw -= event.relative.x * 0.008
		pitch = clampf(pitch - event.relative.y * 0.006, -1.45, 0.2)
		_idle = 0.0
	elif event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			distance = maxf(min_distance, distance * 0.9)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			distance = minf(max_distance, distance * 1.1)
		_idle = 0.0
	elif event is InputEventMagnifyGesture:
		distance = clampf(distance / event.factor, min_distance, max_distance)
		_idle = 0.0
	_apply()


func _apply() -> void:
	var off := Vector3(0, 0, distance).rotated(Vector3.RIGHT, pitch).rotated(Vector3.UP, yaw)
	global_position = target + off
	look_at(target)


## Smoothly re-aim at a new point (e.g. the prop the player clicked).
func focus(point: Vector3, dist := -1.0) -> void:
	var tw := create_tween().set_parallel()
	tw.tween_property(self, "target", point, 0.5).set_trans(Tween.TRANS_SINE)
	if dist > 0:
		tw.tween_property(self, "distance", dist, 0.5).set_trans(Tween.TRANS_SINE)
	tw.tween_method(func(_v): _apply(), 0.0, 1.0, 0.5)
