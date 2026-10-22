## Basuh Tangan: tap the six steps in order; for the scrubbing steps keep tapping the
## soap for 20 seconds (the timer only runs while you keep scrubbing).
extends KampungActivity

var _next := 0
var _steps := HFlowContainer.new()
var _scrub := Button.new()
var _bar := ProgressBar.new()
var _scrubbed := 0.0
var _last_tap := -10.0
var _scrubbing := false


func _ready() -> void:
	setup(2, "backgrounds/kampung", GameState.tr2("Ketik langkah membasuh tangan mengikut urutan.", "Tap the hand-washing steps in order."), "kg_wash")
	var pic := TextureRect.new()
	pic.texture = EduAssets.texture("pjpk/basuh_tangan")
	pic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	pic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	pic.custom_minimum_size = Vector2(0, 260)
	body.add_child(pic)
	_steps.add_theme_constant_override("h_separation", 14)
	_steps.add_theme_constant_override("v_separation", 14)
	body.add_child(_steps)
	var order := range(Kampung.WASH_STEPS.size())
	order.shuffle()
	for i in order:
		var b := Button.new()
		b.text = Kampung.WASH_STEPS[i][0 if GameState.lang == "ms" else 1]
		b.custom_minimum_size = Vector2(480, 96)
		b.theme_type_variation = "ButtonTeal"
		b.pressed.connect(_tap_step.bind(i, b))
		_steps.add_child(b)
	_scrub.icon = EduAssets.texture("pjpk/sabun")
	_scrub.expand_icon = true
	_scrub.text = GameState.tr2("Gosok! Gosok!", "Scrub! Scrub!")
	_scrub.custom_minimum_size = Vector2(520, 160)
	_scrub.theme_type_variation = "ButtonYellow"
	_scrub.hide()
	_scrub.pressed.connect(func(): _last_tap = Time.get_ticks_msec() / 1000.0; Audio.sfx("bubble", 0.2); Feedback.confetti(self, _scrub.global_position + _scrub.size / 2, 6))
	body.add_child(_scrub)
	_bar.max_value = Kampung.SCRUB_SECONDS
	_bar.custom_minimum_size = Vector2(1000, 40)
	_bar.show_percentage = false
	_bar.hide()
	body.add_child(_bar)
	KitUtil.maybe_shot(self, "kampung_wash", 2.0)


func _tap_step(i: int, b: Button) -> void:
	if _scrubbing:
		return
	if i != _next:
		wrong(GameState.tr2("Bukan langkah itu. Apa yang kita buat dahulu?", "Not that step. What do we do first?"))
		return
	Audio.sfx("pop")
	b.disabled = true
	b.theme_type_variation = "ButtonGreen"
	_next += 1
	if _next == 3:  # rubbing palms starts the 20-second scrub
		_scrubbing = true
		_scrub.show()
		_bar.show()
		say(GameState.tr2("Gosok selama 20 saat! Teruskan ketik sabun.", "Scrub for 20 seconds! Keep tapping the soap."), "cheer")
	elif _next == Kampung.WASH_STEPS.size():
		say(GameState.tr2("Tangan bersih! Kuman sudah hilang.", "Clean hands! The germs are gone."), "happy")
		finish()


func _process(delta: float) -> void:
	if not _scrubbing:
		return
	if Time.get_ticks_msec() / 1000.0 - _last_tap < 1.5:  # keeps counting only while scrubbing
		_scrubbed += delta
		_bar.value = _scrubbed
	if _scrubbed >= Kampung.SCRUB_SECONDS:
		_scrubbing = false
		_scrub.hide()
		Audio.sfx("correct")
		# step 4 (between fingers) is part of the same 20 seconds
		for b in _steps.get_children():
			if b.text == Kampung.WASH_STEPS[3][0 if GameState.lang == "ms" else 1]:
				_tap_step(3, b)
		say(GameState.tr2("Bagus! Sekarang bilas dan lap.", "Good! Now rinse and dry."))


## Test hook: finish the 20-second scrub immediately.
func skip_scrub() -> void:
	_scrubbed = Kampung.SCRUB_SECONDS
	_last_tap = Time.get_ticks_msec() / 1000.0
