## A/B/C/D answer button: colour + shape coded (triangle / diamond / circle / square)
## so colour-blind players can still tell answers apart. Shape is drawn, so it stays
## crisp at any size; the matching card art is assets/art/ui/answer_card_*.svg.
class_name AnswerButton
extends Button

const COLORS := [Color("ef476f"), Color("3a86ff"), Color("f4a100"), Color("6bcb77")]

@export_range(0, 3) var index := 0:
	set(v):
		index = v
		_skin()


func _init() -> void:
	custom_minimum_size = Vector2(420, 130)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	alignment = HORIZONTAL_ALIGNMENT_CENTER
	_skin()


func _box(col: Color, shadow := 8) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = col
	s.set_corner_radius_all(26)
	s.set_border_width_all(5)
	s.border_color = Color("2b2d42")
	s.shadow_color = col.darkened(0.45)
	s.shadow_offset = Vector2(0, shadow)
	s.shadow_size = 1 if shadow > 0 else 0
	s.content_margin_left = 110
	s.content_margin_right = 24
	s.content_margin_top = 12
	s.content_margin_bottom = 16
	s.anti_aliasing = true
	return s


func _skin() -> void:
	var col: Color = COLORS[index]
	add_theme_stylebox_override("normal", _box(col))
	add_theme_stylebox_override("hover", _box(col.lightened(0.12)))
	add_theme_stylebox_override("pressed", _box(col.darkened(0.1), 2))
	add_theme_stylebox_override("disabled", _box(col))
	var focus := _box(Color.TRANSPARENT, 0)
	focus.draw_center = false
	focus.border_color = Color("ffd166")
	add_theme_stylebox_override("focus", focus)
	for c in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color", "font_disabled_color", "font_hover_pressed_color"]:
		add_theme_color_override(c, Color.WHITE)
	add_theme_color_override("font_outline_color", Color("2b2d42"))
	add_theme_constant_override("outline_size", 8)
	add_theme_font_size_override("font_size", 38)
	queue_redraw()


func _draw() -> void:
	var c := Vector2(60, size.y / 2)
	var r := minf(30.0, size.y * 0.25)
	var pts: PackedVector2Array
	match index:
		0: pts = PackedVector2Array([c + Vector2(0, -r), c + Vector2(r, r * 0.8), c + Vector2(-r, r * 0.8)])
		1: pts = PackedVector2Array([c + Vector2(0, -r), c + Vector2(r, 0), c + Vector2(0, r), c + Vector2(-r, 0)])
		3: pts = PackedVector2Array([c + Vector2(-r, -r) * 0.85, c + Vector2(r, -r) * 0.85, c + Vector2(r, r) * 0.85, c + Vector2(-r, r) * 0.85])
	if index == 2:
		draw_circle(c, r * 0.9, Color.WHITE)
	else:
		draw_colored_polygon(pts, Color.WHITE)


func reset(t: String) -> void:
	text = t
	disabled = false
	modulate = Color.WHITE
	scale = Vector2.ONE


## Called by QuizCard after a pick. `reveal` = this is the right answer being shown.
func mark(correct: bool, reveal := false) -> void:
	disabled = true
	pivot_offset = size / 2
	var tw := create_tween()
	if correct:
		modulate = Color(0.75, 1.25, 0.75) if not reveal else Color(0.85, 1.15, 0.85)
		tw.tween_property(self, "scale", Vector2(1.06, 1.06), 0.1)
		tw.tween_property(self, "scale", Vector2.ONE, 0.15)
	else:
		modulate = Color(1.0, 0.55, 0.55)
		var x := position.x
		for d in [14, -14, 9, -9, 0]:
			tw.tween_property(self, "position:x", x + d, 0.045)
