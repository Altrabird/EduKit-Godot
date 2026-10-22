## Shared reward/feedback effects so every game reacts the same way.
##   Feedback.result(node, correct)           # sound + voice + popup icon + confetti
##   Feedback.confetti(node, global_pos)
##   Feedback.float_text(node, "+10", pos)
class_name Feedback
extends RefCounted

const PRAISE := ["correct", "great", "good", "well_done", "excellent"]
const CONFETTI_COLORS := [Color("ef476f"), Color("ffd166"), Color("6bcb77"), Color("3a86ff"), Color("9b5de5"), Color("ff9f1c")]


static func result(anchor: CanvasItem, correct: bool, speak := true) -> void:
	Audio.sfx("correct" if correct else "wrong")
	if speak:
		Audio.say("feedback", PRAISE.pick_random() if correct else "try_again")
	var layer := _overlay(anchor)
	var icon := TextureRect.new()
	icon.texture = load("res://assets/art/icons/%s.svg" % ("check" if correct else "cross"))
	icon.size = Vector2(220, 220)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var vp := anchor.get_viewport_rect().size
	icon.position = vp / 2 - icon.size / 2
	icon.pivot_offset = icon.size / 2
	icon.scale = Vector2(0.2, 0.2)
	layer.add_child(icon)
	var tw := icon.create_tween()
	tw.tween_property(icon, "scale", Vector2.ONE, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_interval(0.5)
	tw.tween_property(icon, "modulate:a", 0.0, 0.25)
	tw.tween_callback(icon.queue_free)
	if correct:
		confetti(anchor, vp / 2, 60)


static func _overlay(anchor: CanvasItem) -> CanvasLayer:
	var root := anchor.get_tree().root
	var layer: CanvasLayer = root.get_node_or_null("FeedbackLayer")
	if layer == null:
		layer = CanvasLayer.new()
		layer.name = "FeedbackLayer"
		layer.layer = 50
		root.add_child(layer)
	return layer


static func confetti(anchor: CanvasItem, pos: Vector2, amount := 50) -> void:
	var layer := _overlay(anchor)
	for tex_name in ["fx_confetti_rect", "fx_confetti_circle", "fx_star"]:
		var p := CPUParticles2D.new()
		p.texture = load("res://assets/art/fx/%s.svg" % tex_name)
		p.position = pos
		p.amount = amount / 3
		p.one_shot = true
		p.explosiveness = 0.95
		p.lifetime = 1.6
		p.direction = Vector2.UP
		p.spread = 70
		p.initial_velocity_min = 450
		p.initial_velocity_max = 900
		p.gravity = Vector2(0, 1100)
		p.angular_velocity_min = -400
		p.angular_velocity_max = 400
		p.scale_amount_min = 0.25
		p.scale_amount_max = 0.5
		var g := Gradient.new()
		g.colors = PackedColorArray(CONFETTI_COLORS)
		g.offsets = PackedFloat32Array(range(CONFETTI_COLORS.size()).map(func(i): return float(i) / (CONFETTI_COLORS.size() - 1)))
		p.color_initial_ramp = g
		layer.add_child(p)
		p.emitting = true
		p.finished.connect(p.queue_free)


static func float_text(anchor: CanvasItem, text: String, pos: Vector2, color := Color("ffd166")) -> void:
	var l := Label.new()
	l.text = text
	l.theme_type_variation = "LabelHeading"
	l.add_theme_color_override("font_color", color)
	l.add_theme_color_override("font_outline_color", Color("2b2d42"))
	l.add_theme_constant_override("outline_size", 10)
	l.position = pos
	_overlay(anchor).add_child(l)
	var tw := l.create_tween().set_parallel()
	tw.tween_property(l, "position:y", pos.y - 90, 0.8).set_ease(Tween.EASE_OUT)
	tw.tween_property(l, "modulate:a", 0.0, 0.8).set_delay(0.3)
	tw.chain().tween_callback(l.queue_free)
