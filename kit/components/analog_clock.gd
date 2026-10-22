## Teaching clock built from matematik/clock_face + hand SVGs.
## interactive = drag the minute hand; the hour hand follows like a real clock.
class_name AnalogClock
extends Control

signal time_changed(hour: int, minute: int)

@export_range(0, 23) var hour := 3:
	set(v):
		hour = v
		_update()
@export_range(0, 59) var minute := 0:
	set(v):
		minute = v
		_update()
@export var interactive := false
@export var snap_minutes := 5

var _face := TextureRect.new()
var _h := TextureRect.new()
var _m := TextureRect.new()
var _dragging := false


func _init() -> void:
	custom_minimum_size = Vector2(320, 320)


func _ready() -> void:
	for p in [[_face, "clock_face"], [_h, "clock_hand_hour"], [_m, "clock_hand_minute"]]:
		var t: TextureRect = p[0]
		t.texture = EduAssets.texture("matematik/" + p[1])
		t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		t.set_anchors_preset(Control.PRESET_FULL_RECT)
		t.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(t)
	resized.connect(_update)
	_update()


func _update() -> void:
	if not is_inside_tree():
		return
	for t in [_h, _m]:
		t.pivot_offset = size / 2
	_m.rotation = TAU * minute / 60.0
	_h.rotation = TAU * ((hour % 12) + minute / 60.0) / 12.0


## "3:05" style text (digital form for answers).
func as_text() -> String:
	return "%d:%02d" % [hour, minute]


func _gui_input(event: InputEvent) -> void:
	if not interactive:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		_dragging = event.pressed
		if not event.pressed:
			Audio.sfx("snap")
			time_changed.emit(hour, minute)
	elif event is InputEventMouseMotion and _dragging:
		var v: Vector2 = event.position - size / 2
		var m := int(round(fposmod(v.angle() + PI / 2, TAU) / TAU * 60.0 / snap_minutes)) * snap_minutes % 60
		if minute > 45 and m < 15:
			hour = (hour + 1) % 24
		elif minute < 15 and m > 45:
			hour = (hour + 23) % 24
		if m != minute:
			Audio.sfx("countdown_tick", 0.0, -10.0)
		minute = m
