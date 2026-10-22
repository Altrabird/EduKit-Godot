## Score label with a coin icon that counts up smoothly.
class_name ScoreCounter
extends HBoxContainer

var score := 0
var _shown := 0.0
var _label := Label.new()


func _ready() -> void:
	var icon := TextureRect.new()
	icon.texture = load("res://assets/art/icons/coin.svg")
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.custom_minimum_size = Vector2(64, 64)
	add_child(icon)
	_label.theme_type_variation = "LabelHeading"
	_label.text = "0"
	add_child(_label)


func add(points: int) -> void:
	score += points
	var tw := create_tween()
	tw.tween_method(func(v: float): _shown = v; _label.text = str(int(v)), _shown, float(score), 0.5)
	pivot_offset = size / 2
	tw.parallel().tween_property(self, "scale", Vector2(1.15, 1.15), 0.1)
	tw.tween_property(self, "scale", Vector2.ONE, 0.15)
	if points > 0:
		Audio.sfx("coin", 0.05)


func reset() -> void:
	score = 0
	_shown = 0
	_label.text = "0"
