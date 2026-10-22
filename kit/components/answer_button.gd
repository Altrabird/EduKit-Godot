## A/B/C/D answer button skinned with assets/art/ui/answer_card_*.svg (9-slice).
class_name AnswerButton
extends Button

const LETTERS := ["a", "b", "c", "d"]

@export_range(0, 3) var index := 0:
	set(v):
		index = v
		_skin()


func _init() -> void:
	custom_minimum_size = Vector2(420, 120)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	alignment = HORIZONTAL_ALIGNMENT_CENTER
	_skin()


func _skin() -> void:
	var tex: Texture2D = load("res://assets/art/ui/answer_card_%s.svg" % LETTERS[index])
	for state in ["normal", "hover", "pressed", "disabled", "focus"]:
		var sb := StyleBoxTexture.new()
		sb.texture = tex
		sb.texture_margin_left = 150
		sb.texture_margin_right = 40
		sb.texture_margin_top = 40
		sb.texture_margin_bottom = 50
		sb.content_margin_left = 110
		sb.content_margin_right = 24
		sb.content_margin_top = 10
		sb.content_margin_bottom = 18
		if state == "hover":
			sb.modulate_color = Color(1.12, 1.12, 1.12)
		elif state == "pressed":
			sb.modulate_color = Color(0.85, 0.85, 0.85)
		elif state == "focus":
			sb.draw_center = false
		add_theme_stylebox_override(state, sb)
	for c in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color", "font_disabled_color", "font_hover_pressed_color"]:
		add_theme_color_override(c, Color.WHITE)
	add_theme_color_override("font_outline_color", Color("2b2d42"))
	add_theme_constant_override("outline_size", 8)
	add_theme_font_size_override("font_size", 36)


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
