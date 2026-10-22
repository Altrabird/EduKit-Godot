## Demo: side-scroller on the platformer TileSet. Collect stars; "?" blocks ask a
## maths question (QuizCard pops up, game pauses); reach the flag to finish.
## Arrow keys / A-D move, Space / Up jump.
extends Node2D

const GAME_ID := "demo_platformer"
const TS := 64
## Level as text: G grass, D dirt, P one-way plank, B brick, ? quiz block, * star, ^ pencil spikes, F flag, @ player
const LEVEL := [
	"                                                                        ",
	"                                                                        ",
	"                         *  *                                F          ",
	"                        PPPPPP           ?        *  *  *    G          ",
	"               *                                 PPPPPPPP   GD          ",
	"         ?    PPPP          *     BBB                       GDD         ",
	"   @                  *    PPP          *       *          GDDD         ",
	"GGGGGGGGGGGGGGGG   GGGGGG        GGGGGGGGGG^^^GGGGGGGGGGGGGDDDDGGGGGGGG",
	"DDDDDDDDDDDDDDDD   DDDDDD        DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD",
	"DDDDDDDDDDDDDDDD   DDDDDD        DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD",
]
const TILE := {"G": Vector2i(1, 0), "D": Vector2i(1, 1), "P": Vector2i(5, 0), "B": Vector2i(4, 1), "?": Vector2i(6, 2), "^": Vector2i(6, 3), "F": Vector2i(0, 4)}

var _map := TileMapLayer.new()
var _player := Player2D.new()
var _ui := CanvasLayer.new()
var _score := ScoreCounter.new()
var _card := QuizCard.new()
var _results := ResultsPanel.new()
var _stars_total := 0
var _stars_got := 0
var _quiz_right := 0
var _quiz_total := 0
var _spawn := Vector2.ZERO
var _finished := false


func _ready() -> void:
	_parallax()
	_map.tile_set = load("res://kit/tiles/platformer_tileset.tres")
	add_child(_map)
	for y in LEVEL.size():
		for x in LEVEL[y].length():
			var ch: String = LEVEL[y][x]
			var pos := Vector2(x * TS + TS / 2.0, y * TS + TS / 2.0)
			if TILE.has(ch) and ch != "F" and ch != "?":
				var c: Vector2i = TILE[ch]
				# grass edges pick the left/right end pieces
				if ch == "G":
					var l: bool = x > 0 and LEVEL[y][x - 1] in "GD"
					var r: bool = x < LEVEL[y].length() - 1 and LEVEL[y][x + 1] in "GD"
					c = Vector2i(1 if l and r else (0 if r else (2 if l else 3)), 0)
				_map.set_cell(Vector2i(x, y), 0, c)
			match ch:
				"*":
					_make_star(pos)
				"?":
					_map.set_cell(Vector2i(x, y), 0, TILE["?"])
					_make_quiz_trigger(pos + Vector2(0, TS))
				"F":
					_make_flag(pos)
				"@":
					_spawn = pos
	_player.char_id = "jaiden"
	_player.position = _spawn
	_player.hurt.connect(func(): _player.position = _spawn)
	add_child(_player)
	var cam := Camera2D.new()
	cam.limit_left = 0
	cam.limit_top = -400
	cam.limit_bottom = LEVEL.size() * TS
	cam.limit_right = LEVEL[0].length() * TS
	cam.position_smoothing_enabled = true
	cam.zoom = Vector2(1.1, 1.1)
	_player.add_child(cam)
	add_child(_ui)
	_score.position = Vector2(1650, 30)
	_ui.add_child(_score)
	DemoUtil.home_button(_ui)
	_card.position = Vector2(440, 160)
	_card.custom_minimum_size = Vector2(1040, 0)
	_card.time_limit = 15
	_card.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	_card.hide()
	_card.answered.connect(_on_quiz)
	_ui.add_child(_card)
	_results.game_id = GAME_ID
	_results.process_mode = Node.PROCESS_MODE_ALWAYS
	_results.retry.connect(func(): get_tree().reload_current_scene())
	_results.next.connect(func(): get_tree().reload_current_scene())
	_results.menu.connect(func(): Fader.go("res://demo/gallery.tscn"))
	_ui.add_child(_results)
	Audio.music("arcade_laju")
	DemoUtil.maybe_shot(self, "demo_platformer", 2.0)


func _parallax() -> void:
	RenderingServer.set_default_clear_color(Color("6bbf59"))  # pits and edges read as grass
	var pb := ParallaxBackground.new()
	add_child(pb)
	for layer in [["parallax_sky", 0.05], ["parallax_far", 0.25], ["parallax_near", 0.5]]:
		var pl := ParallaxLayer.new()
		pl.motion_scale = Vector2(layer[1], 0.1)
		pl.motion_mirroring = Vector2(1920, 0)
		var s := Sprite2D.new()
		s.texture = EduAssets.texture("backgrounds/" + layer[0])
		s.centered = false
		s.position.y = -420
		pl.add_child(s)
		pb.add_child(pl)


func _area(pos: Vector2, radius: float) -> Area2D:
	var a := Area2D.new()
	a.position = pos
	var cs := CollisionShape2D.new()
	var sh := CircleShape2D.new()
	sh.radius = radius
	cs.shape = sh
	a.add_child(cs)
	add_child(a)
	return a


func _make_star(pos: Vector2) -> void:
	_stars_total += 1
	var a := _area(pos, 26)
	var s := Sprite2D.new()
	s.texture = EduAssets.texture("icons/star")
	s.scale = Vector2.ONE * 56 / 256.0
	a.add_child(s)
	var tw := a.create_tween().set_loops()
	tw.tween_property(s, "position:y", -8.0, 0.5).set_trans(Tween.TRANS_SINE)
	tw.tween_property(s, "position:y", 0.0, 0.5).set_trans(Tween.TRANS_SINE)
	a.body_entered.connect(func(b):
		if b == _player:
			_stars_got += 1
			_score.add(5)
			Audio.sfx("collect")
			a.queue_free())


func _make_quiz_trigger(pos: Vector2) -> void:
	# The block itself is solid; the trigger sits just under it so a head-bump fires it.
	var a := _area(pos - Vector2(0, TS * 0.55), 20)
	a.body_entered.connect(func(b):
		if b == _player and _player.velocity.y <= 0:
			a.queue_free()
			_quiz_total += 1
			get_tree().paused = true
			_card.show()
			_card.show_question(Questions.math(["+", "-", "×"].pick_random(), 3)))


func _on_quiz(correct: bool, _i: int) -> void:
	_card.hide()
	get_tree().paused = false
	if correct:
		_quiz_right += 1
		_score.add(20)
		Feedback.float_text(_player, "+20", get_viewport_rect().size / 2)


func _make_flag(pos: Vector2) -> void:
	var a := _area(pos + Vector2(0, TS), 40)
	var s := Sprite2D.new()
	s.texture = EduAssets.texture("icons/flag")
	s.scale = Vector2.ONE * 0.6
	s.position.y = -60
	a.add_child(s)
	a.body_entered.connect(func(b):
		if b == _player and not _finished:
			_finished = true
			_player.set_expression("cheer")
			Audio.sfx("win_fanfare")
			get_tree().paused = true
			_results.open(_stars_got + _quiz_right * 2, _stars_total + _quiz_total * 2))
