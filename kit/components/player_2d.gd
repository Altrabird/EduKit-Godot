## Side-scroller player using any character art. Works with kit/tiles/platformer_tileset.tres
## (one-way platforms, hazard tiles report via `hurt`). Uses the built-in ui_left /
## ui_right / ui_accept / ui_up actions so it needs no InputMap setup; touch games can
## call press_jump() / set_move() from on-screen buttons.
class_name Player2D
extends CharacterBody2D

signal hurt
signal landed

@export var char_id := "aiman"
@export var sprite_ref := ""  ## any manifest picture instead of a character (e.g. "bahasa_melayu/sang_kancil")
@export var speed := 520.0
@export var jump_velocity := -1050.0
@export var gravity := 2600.0
@export var coyote_time := 0.1
@export var jump_buffer := 0.12
@export var height_px := 150.0

var _sprite := Sprite2D.new()
var _coyote := 0.0
var _buffer := 0.0
var _touch_move := 0.0
var _was_on_floor := true
var _base := Vector2.ONE


func _ready() -> void:
	var tex := _tex("neutral")
	_sprite.texture = tex
	_base = Vector2.ONE * height_px / tex.get_height()
	_sprite.scale = _base
	_sprite.offset = Vector2(0, -tex.get_height() / 2.0)
	add_child(_sprite)
	var shape := CollisionShape2D.new()
	var cap := CapsuleShape2D.new()
	cap.radius = height_px * 0.2
	cap.height = height_px * 0.85
	shape.shape = cap
	shape.position.y = -height_px * 0.43
	add_child(shape)
	floor_snap_length = 8


func set_move(dir: float) -> void:
	_touch_move = clampf(dir, -1, 1)


func press_jump() -> void:
	_buffer = jump_buffer


func _physics_process(delta: float) -> void:
	var dir := clampf(Input.get_axis("ui_left", "ui_right") + _touch_move, -1, 1)
	velocity.x = move_toward(velocity.x, dir * speed, speed * delta * 10)
	if Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("ui_up"):
		_buffer = jump_buffer
	_buffer -= delta
	_coyote = coyote_time if is_on_floor() else _coyote - delta
	if not is_on_floor():
		velocity.y += gravity * delta
		if velocity.y < 0 and not (Input.is_action_pressed("ui_accept") or Input.is_action_pressed("ui_up")) and _touch_move == 0:
			velocity.y += gravity * delta  # short hop when the button is released
	if _buffer > 0 and _coyote > 0:
		velocity.y = jump_velocity
		_buffer = 0
		_coyote = 0
		Audio.sfx("jump", 0.05)
		_squash(Vector2(0.8, 1.2))
	move_and_slide()
	if is_on_floor() and not _was_on_floor:
		Audio.sfx("land", 0.1, -6)
		_squash(Vector2(1.2, 0.8))
		landed.emit()
	_was_on_floor = is_on_floor()
	if dir != 0:
		_sprite.flip_h = dir < 0
		_sprite.rotation = sin(Time.get_ticks_msec() / 70.0) * 0.06 if is_on_floor() else 0.0
	else:
		_sprite.rotation = 0.0
	_check_hazards()


func _squash(s: Vector2) -> void:
	var tw := create_tween()
	tw.tween_property(_sprite, "scale", _base * s, 0.06)
	tw.tween_property(_sprite, "scale", _base, 0.14)


func _check_hazards() -> void:
	for i in get_slide_collision_count():
		var c := get_slide_collision(i)
		var tm := c.get_collider() as TileMapLayer
		if tm:
			var cell := tm.local_to_map(tm.to_local(c.get_position() - c.get_normal() * 4))
			var td := tm.get_cell_tile_data(cell)
			if td and td.get_custom_data("kind") == "hazard":
				_on_hurt()


func _on_hurt() -> void:
	bump(-signf(velocity.x) if velocity.x != 0 else -1.0)


## Knock back (dir = -1 left / 1 right), flash, and emit `hurt`. Enemies call this.
func bump(dir: float) -> void:
	Audio.sfx("hurt")
	velocity = Vector2(dir * speed * 0.8, jump_velocity * 0.6)
	set_expression("sad")
	var tw := create_tween()
	for k in 3:
		tw.tween_property(_sprite, "modulate:a", 0.3, 0.08)
		tw.tween_property(_sprite, "modulate:a", 1.0, 0.08)
	get_tree().create_timer(0.6).timeout.connect(func(): set_expression("neutral"))
	hurt.emit()


func _tex(expr: String) -> Texture2D:
	return EduAssets.texture(sprite_ref) if sprite_ref != "" else EduAssets.character(char_id, expr)


func set_expression(expr: String) -> void:
	_sprite.texture = _tex(expr)
