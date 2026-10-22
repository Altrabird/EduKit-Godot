## A character from assets/art/characters with expressions and simple life:
## idle breathing, talking (mouth flaps), happy hop, sad droop, wave/cheer.
##   $Aiman.char_id = "aiman"; $Aiman.react(true); $Aiman.talk(2.0)
## Feet are at the node origin, so place it on the ground line.
class_name Character2D
extends Node2D

const CHARS := ["aiman", "aisyah", "meiling", "weijie", "kavitha", "arjun", "jaiden", "nurul", "rahman", "kenyalang", "robo"]
const EXPRESSIONS := ["neutral", "happy", "sad", "surprised", "thinking", "talk", "cheer"]

@export_enum("aiman", "aisyah", "meiling", "weijie", "kavitha", "arjun", "jaiden", "nurul", "rahman", "kenyalang", "robo") var char_id := "aiman":
	set(v):
		char_id = v
		_apply()
@export var expression := "neutral":
	set(v):
		expression = v
		_apply()
@export var height_px := 384.0  ## on-screen height
@export var idle := true

var _sprite := Sprite2D.new()
var _t := 0.0
var _talk_left := 0.0
var _base_scale := 1.0


func _ready() -> void:
	_sprite.centered = false
	add_child(_sprite)
	_apply()


func _apply() -> void:
	if not is_inside_tree():
		return
	var tex := EduAssets.character(char_id, expression)
	if tex == null:
		return
	_sprite.texture = tex
	_base_scale = height_px / tex.get_height()
	_sprite.scale = Vector2.ONE * _base_scale
	_sprite.offset = Vector2(-tex.get_width() / 2.0, -tex.get_height())


func _process(delta: float) -> void:
	_t += delta
	if idle:
		var s := 1.0 + 0.015 * sin(_t * 2.4)
		_sprite.scale = Vector2(_base_scale * (2.0 - s), _base_scale * s)
	if _talk_left > 0:
		_talk_left -= delta
		var open := int(_t * 8) % 2 == 0 and _talk_left > 0
		var want := "talk" if open else "neutral"
		if _sprite.texture != EduAssets.character(char_id, want):
			_sprite.texture = EduAssets.character(char_id, want)


func talk(seconds: float) -> void:
	_talk_left = seconds


func react(correct: bool) -> void:
	expression = "happy" if correct else "sad"
	var tw := create_tween()
	if correct:
		tw.tween_property(self, "position:y", position.y - 40, 0.15).set_ease(Tween.EASE_OUT)
		tw.tween_property(self, "position:y", position.y, 0.2).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BOUNCE)
	else:
		tw.tween_property(self, "rotation", -0.05, 0.15)
		tw.tween_property(self, "rotation", 0.0, 0.3)
	tw.tween_interval(0.8)
	tw.tween_callback(func(): expression = "neutral")


func cheer() -> void:
	expression = "cheer"
	var tw := create_tween().set_loops(3)
	tw.tween_property(self, "position:y", position.y - 30, 0.15)
	tw.tween_property(self, "position:y", position.y, 0.15)
