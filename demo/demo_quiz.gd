## Demo: 8-question mixed round (maths generator + picture naming + Sains bank)
## on the school-hall stage, with Robo reacting, timer, score and results.
extends Control

const GAME_ID := "demo_quiz"

var _card := QuizCard.new()
var _score := ScoreCounter.new()
var _robo := Character2D.new()
var _results := ResultsPanel.new()
var _progress := Label.new()
var _qs: Array = []
var _i := 0
var _right := 0


func _ready() -> void:
	DemoUtil.background(self, "backgrounds/stage_hall")
	_robo.char_id = "robo"
	_robo.height_px = 520
	_robo.position = Vector2(230, 1040)
	add_child(_robo)
	var kenny := Character2D.new()
	kenny.char_id = "kenyalang"
	kenny.height_px = 420
	kenny.position = Vector2(1720, 1040)
	add_child(kenny)
	_card.time_limit = 20.0
	_card.position = Vector2(440, 150)
	_card.custom_minimum_size = Vector2(1040, 0)
	_card.answered.connect(_on_answered)
	add_child(_card)
	_score.position = Vector2(1650, 30)
	add_child(_score)
	_progress.position = Vector2(160, 40)
	_progress.theme_type_variation = "LabelHeading"
	_progress.add_theme_color_override("font_color", Color.WHITE)
	add_child(_progress)
	_results.game_id = GAME_ID
	_results.retry.connect(_start)
	_results.next.connect(_start)
	_results.menu.connect(func(): Fader.go("res://demo/gallery.tscn"))
	add_child(_results)
	DemoUtil.home_button(self)
	Audio.music("quiz_berfikir")
	_start()
	DemoUtil.maybe_shot(self, "demo_quiz", 2.5)


func _start() -> void:
	_qs = [Questions.math("+", 2), Questions.math("×", 3)]
	_qs += Questions.picture("bahasa_melayu", 3, "", "fruit")
	_qs += Questions.from_bank("sains", 3)
	_i = 0
	_right = 0
	_score.reset()
	Audio.music("quiz_berfikir")
	_card.show()
	_next()


func _next() -> void:
	if _i >= _qs.size():
		_card.hide()
		_robo.cheer() if _right >= 6 else _robo.react(false)
		_results.open(_right, _qs.size())
		return
	_progress.text = "%s %d / %d" % [GameState.tr2("Soalan", "Question"), _i + 1, _qs.size()]
	_robo.expression = "thinking"
	_card.show_question(_qs[_i])


func _on_answered(correct: bool, _idx: int) -> void:
	_robo.react(correct)
	if correct:
		_right += 1
		_score.add(10)
	_i += 1
	_next()
