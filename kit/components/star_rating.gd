## 0-3 stars that pop in one by one.
class_name StarRating
extends HBoxContainer

@export var star_size := 96.0
var _stars: Array[TextureRect] = []
const FULL := preload("res://assets/art/icons/star.svg")
const EMPTY := preload("res://assets/art/icons/star_empty.svg")


func _ready() -> void:
	alignment = BoxContainer.ALIGNMENT_CENTER
	for i in 3:
		var t := TextureRect.new()
		t.texture = EMPTY
		t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		t.custom_minimum_size = Vector2.ONE * star_size * (1.25 if i == 1 else 1.0)
		t.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		add_child(t)
		_stars.append(t)


func set_stars(n: int, animate := true) -> void:
	for i in 3:
		_stars[i].texture = EMPTY
	for i in clampi(n, 0, 3):
		if animate:
			await get_tree().create_timer(0.35).timeout
			Audio.sfx("star", 0.05)
		_stars[i].texture = FULL
		_stars[i].pivot_offset = _stars[i].size / 2
		if animate:
			_stars[i].scale = Vector2(1.6, 1.6)
			create_tween().tween_property(_stars[i], "scale", Vector2.ONE, 0.25).set_trans(Tween.TRANS_BACK)


## Common rule: 3 stars = 100 %, 2 = 70 %+, 1 = 40 %+.
static func stars_for(score: int, total: int) -> int:
	if total <= 0:
		return 0
	var f := float(score) / total
	return 3 if f >= 0.999 else (2 if f >= 0.7 else (1 if f >= 0.4 else 0))
