## Question + optional picture + four AnswerButtons (+ optional TimerBar).
## show_question(q) with a dict from the Questions autoload; listen to `answered`.
## Feedback (sound, voice, confetti) comes from Feedback so games stay consistent.
class_name QuizCard
extends PanelContainer

signal answered(correct: bool, index: int)

@export var time_limit := 0.0  ## seconds, 0 = untimed
@export var speak_feedback := true

var question := {}
var _q_label := Label.new()
var _img := TextureRect.new()
var _grid := GridContainer.new()
var _buttons: Array[AnswerButton] = []
var _timer: TimerBar
var _locked := false
var _speaker := Button.new()


func _ready() -> void:
	theme_type_variation = "PanelCream"
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 18)
	add_child(v)
	var qrow := HBoxContainer.new()
	v.add_child(qrow)
	_q_label.theme_type_variation = "LabelHeading"
	_q_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_q_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_q_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	qrow.add_child(_q_label)
	_speaker.icon = load("res://assets/art/icons/sound_on.svg")
	_speaker.expand_icon = true
	_speaker.theme_type_variation = "ButtonYellow"
	_speaker.custom_minimum_size = Vector2(88, 80)
	_speaker.tooltip_text = "Dengar / Listen"
	_speaker.pressed.connect(_speak_question)
	qrow.add_child(_speaker)
	_img.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_img.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_img.custom_minimum_size = Vector2(0, 240)
	_img.mouse_filter = Control.MOUSE_FILTER_STOP
	_img.gui_input.connect(func(e): if e is InputEventMouseButton and e.pressed: _speak_question())
	v.add_child(_img)
	if time_limit > 0:
		_timer = TimerBar.new()
		_timer.timeout.connect(_on_timeout)
		v.add_child(_timer)
	_grid.columns = 2
	_grid.add_theme_constant_override("h_separation", 18)
	_grid.add_theme_constant_override("v_separation", 18)
	v.add_child(_grid)
	for i in 4:
		var b := AnswerButton.new()
		b.index = i
		b.pressed.connect(_on_pick.bind(i))
		_grid.add_child(b)
		_buttons.append(b)


## q = {"text", "choices", "answer", "image"(ref, optional), "speak"(optional)}
func show_question(q: Dictionary) -> void:
	question = q
	_locked = false
	_q_label.text = q.text
	_speaker.visible = not q.get("speak", {}).is_empty()
	_img.visible = q.get("image", "") != ""
	if _img.visible:
		_img.texture = EduAssets.texture(q.image)
	for i in 4:
		_buttons[i].visible = i < q.choices.size()
		if i < q.choices.size():
			_buttons[i].reset(str(q.choices[i]))
	if _timer:
		_timer.start(time_limit)
	_speak_question()
	modulate.a = 0
	create_tween().tween_property(self, "modulate:a", 1.0, 0.25)


## Lifeline: hide `n` wrong answers (50:50 = 2). Returns how many were hidden.
func eliminate(n: int) -> int:
	var wrong := []
	for i in _buttons.size():
		if i != question.get("answer", -1) and _buttons[i].visible and not _buttons[i].disabled:
			wrong.append(i)
	wrong.shuffle()
	for i in wrong.slice(0, n):
		_buttons[i].disabled = true
		create_tween().tween_property(_buttons[i], "modulate:a", 0.15, 0.25)
	return mini(n, wrong.size())


func time_left() -> float:
	return _timer.time_left() if _timer else 0.0


func is_locked() -> bool:
	return _locked


## Stops the round without answering (used by skip): no signal is emitted.
func cancel() -> void:
	_locked = true
	if _timer:
		_timer.stop()


func _speak_question() -> void:
	var s: Dictionary = question.get("speak", {})
	if not s.is_empty():
		Audio.say(s.group, s.id)


func _on_pick(i: int) -> void:
	if _locked:
		return
	_locked = true
	if _timer:
		_timer.stop()
	var ok: bool = i == question.answer
	_buttons[i].mark(ok)
	if not ok and question.answer >= 0:
		_buttons[question.answer].mark(true, true)
	Feedback.result(self, ok, speak_feedback)
	await get_tree().create_timer(1.2).timeout
	answered.emit(ok, i)


func _on_timeout() -> void:
	if _locked:
		return
	_locked = true
	_buttons[question.answer].mark(true, true)
	Audio.sfx("time_up")
	if speak_feedback:
		Audio.say("feedback", "times_up")
	await get_tree().create_timer(1.4).timeout
	answered.emit(false, -1)
