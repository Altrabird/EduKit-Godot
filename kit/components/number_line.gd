## Drawn number line with ticks, labels and a draggable/settable marker.
class_name NumberLine
extends Control

signal value_picked(value: int)

@export var min_value := 0
@export var max_value := 10
@export var step := 1
@export var marker := 0:
	set(v):
		marker = clampi(v, min_value, max_value)
		queue_redraw()
@export var interactive := true
@export var hops: Array[Vector2i] = []  ## arcs drawn from x to y (e.g. 3 -> 7 for "3 + 4")

const INK := Color("2b2d42")
var _font: Font = preload("res://assets/fonts/Fredoka.ttf")


func _init() -> void:
	custom_minimum_size = Vector2(800, 180)


func x_of(v: float) -> float:
	return lerpf(40, size.x - 40, (v - min_value) / float(max_value - min_value))


func _draw() -> void:
	var y := size.y * 0.55
	draw_line(Vector2(20, y), Vector2(size.x - 20, y), INK, 6, true)
	for v in range(min_value, max_value + 1, step):
		var x := x_of(v)
		draw_line(Vector2(x, y - 16), Vector2(x, y + 16), INK, 4, true)
		var s := str(v)
		var w := _font.get_string_size(s, HORIZONTAL_ALIGNMENT_LEFT, -1, 28).x
		draw_string(_font, Vector2(x - w / 2, y + 52), s, HORIZONTAL_ALIGNMENT_LEFT, -1, 28, INK)
	for h in hops:
		var a := x_of(h.x)
		var b := x_of(h.y)
		var mid := Vector2((a + b) / 2, y - 10)
		var r := absf(b - a) / 2
		if r > 0:  # blue arcs count up, red arcs count down
			draw_arc(mid, r, PI, TAU, 32, Color("3a86ff") if b > a else Color("ef476f"), 5, true)
	var mx := x_of(marker)
	draw_colored_polygon(PackedVector2Array([Vector2(mx, y - 22), Vector2(mx - 18, y - 58), Vector2(mx + 18, y - 58)]), Color("ef476f"))
	draw_circle(Vector2(mx, y), 10, Color("ef476f"))


func _gui_input(event: InputEvent) -> void:
	if not interactive:
		return
	if (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT) or (event is InputEventMouseMotion and event.button_mask & MOUSE_BUTTON_MASK_LEFT):
		var f := inverse_lerp(40, size.x - 40, event.position.x)
		var v := min_value + int(round(f * (max_value - min_value) / step)) * step
		if v != marker:
			marker = v
			Audio.sfx("countdown_tick", 0.0, -8.0)
		if event is InputEventMouseButton:
			value_picked.emit(marker)
