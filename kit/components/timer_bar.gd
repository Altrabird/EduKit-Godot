## Countdown bar: green -> yellow -> red, tick sounds in the last 3 seconds.
class_name TimerBar
extends ProgressBar

signal timeout

var running := false
var _left := 0.0
var _total := 1.0
var _last_tick := -1
var _fill := StyleBoxFlat.new()


func _init() -> void:
	custom_minimum_size = Vector2(0, 30)
	show_percentage = false
	max_value = 1.0
	step = 0.0
	_fill.set_corner_radius_all(999)
	_fill.set_border_width_all(4)
	_fill.border_color = Color("2b2d42")
	add_theme_stylebox_override("fill", _fill)


func start(seconds: float) -> void:
	_total = maxf(seconds, 0.01)
	_left = _total
	_last_tick = -1
	running = true
	set_process(true)


func stop() -> void:
	running = false


func time_left() -> float:
	return _left


func _process(delta: float) -> void:
	if not running:
		return
	_left = maxf(_left - delta, 0.0)
	var f := _left / _total
	value = f
	_fill.bg_color = Color("6bcb77") if f > 0.5 else (Color("ffd166") if f > 0.25 else Color("ef476f"))
	var s := ceili(_left)
	if s <= 3 and s != _last_tick and _left > 0:
		_last_tick = s
		Audio.sfx("countdown_tick")
	if _left <= 0.0:
		running = false
		timeout.emit()
