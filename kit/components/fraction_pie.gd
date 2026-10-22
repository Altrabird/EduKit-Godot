## Drawn n/d fraction pie (crisp at any size). interactive = click slices to shade them.
class_name FractionPie
extends Control

signal changed(numerator: int, denominator: int)

@export_range(1, 12) var denominator := 4:
	set(v):
		denominator = maxi(v, 1)
		numerator = mini(numerator, denominator)
		queue_redraw()
@export_range(0, 12) var numerator := 1:
	set(v):
		numerator = clampi(v, 0, denominator)
		queue_redraw()
@export var fill_color := Color("ef476f")
@export var interactive := false  ## click a slice to toggle the count up to it

const INK := Color("2b2d42")


func _init() -> void:
	custom_minimum_size = Vector2(240, 240)


func _draw() -> void:
	var c := size / 2
	var r := minf(size.x, size.y) / 2 - 8
	draw_circle(c, r + 4, INK)
	draw_circle(c, r, Color.WHITE)
	for i in denominator:
		var a0 := -PI / 2 + TAU * i / denominator
		var a1 := -PI / 2 + TAU * (i + 1) / denominator
		if i < numerator:
			var pts := PackedVector2Array([c])
			for k in 25:
				var a := lerpf(a0, a1, k / 24.0)
				pts.append(c + Vector2(cos(a), sin(a)) * r)
			draw_colored_polygon(pts, fill_color)
		draw_line(c, c + Vector2(cos(a0), sin(a0)) * r, INK, 4, true)
	draw_arc(c, r, 0, TAU, 96, INK, 6, true)


func _gui_input(event: InputEvent) -> void:
	if interactive and event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var v: Vector2 = event.position - size / 2
		var a := fposmod(v.angle() + PI / 2, TAU)
		var slice := int(a / (TAU / denominator)) + 1
		numerator = slice - 1 if slice == numerator else slice
		Audio.sfx("pop", 0.1)
		changed.emit(numerator, denominator)
