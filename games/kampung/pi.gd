## Sudut Ibadah (Pendidikan Islam): order the rukun of wudhu, then pick the things
## that belong to Hari Raya Aidilfitri. Objects only — no figures are drawn.
extends KampungActivity

var _next := 0
var _row := HFlowContainer.new()
var _phase := "wudhu"
var _picked := {}


func _ready() -> void:
	setup(4, "backgrounds/kampung", GameState.tr2("Ketik langkah wuduk (rukun) mengikut urutan.", "Tap the steps of wudhu in order."), "kg_wudhu", "aisyah")
	var pic := TextureRect.new()
	pic.texture = EduAssets.texture("pendidikan_islam/paip_air_wuduk")
	pic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	pic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	pic.custom_minimum_size = Vector2(0, 260)
	body.add_child(pic)
	_row.add_theme_constant_override("h_separation", 14)
	_row.add_theme_constant_override("v_separation", 14)
	body.add_child(_row)
	var order := range(Kampung.WUDHU.size())
	order.shuffle()
	for i in order:
		var b := Button.new()
		b.text = Kampung.WUDHU[i][0 if GameState.lang == "ms" else 1]
		b.custom_minimum_size = Vector2(600, 100)
		b.theme_type_variation = "ButtonTeal"
		b.pressed.connect(_tap.bind(i, b))
		_row.add_child(b)
	KitUtil.maybe_shot(self, "kampung_pi", 2.0)


func _tap(i: int, b: Button) -> void:
	if i != _next:
		wrong(GameState.tr2("Belum betul. Langkah manakah yang pertama?", "Not yet. Which step comes first?"))
		return
	Audio.sfx("pop")
	b.disabled = true
	b.text = "%d. %s" % [i + 1, b.text]
	b.theme_type_variation = "ButtonGreen"
	_next += 1
	if _next == Kampung.WUDHU.size():
		Audio.sfx("correct")
		await get_tree().create_timer(1.0).timeout
		_raya()


func _raya() -> void:
	_phase = "raya"
	for c in _row.get_children():
		c.queue_free()
	say(GameState.tr2("Pilih semua barang untuk Hari Raya Aidilfitri, kemudian tekan Semak.", "Pick everything that belongs to Hari Raya Aidilfitri, then press Check."))
	var items := Kampung.RAYA_YES + Kampung.RAYA_NO
	items.shuffle()
	for r in items:
		var c := PictureCard.new()
		c.ref = r
		c.custom_minimum_size = Vector2(220, 240)
		c.pressed.connect(func():
			_picked[r] = not _picked.get(r, false)
			c.modulate = Color(0.75, 1.2, 0.75) if _picked[r] else Color.WHITE)
		_row.add_child(c)
	var check := Button.new()
	check.text = GameState.tr2("Semak", "Check")
	check.theme_type_variation = "ButtonGreen"
	check.custom_minimum_size = Vector2(300, 100)
	check.pressed.connect(check_raya)
	_row.add_child(check)


func check_raya() -> void:
	var chosen := _picked.keys().filter(func(k): return _picked[k])
	chosen.sort()
	var want := Kampung.RAYA_YES.duplicate()
	want.sort()
	if chosen == want:
		say(GameState.tr2("Betul! Ketupat, pelita dan sampul duit raya. Selamat Hari Raya!", "Correct! Ketupat, oil lamps and money packets. Selamat Hari Raya!"), "happy")
		finish()
	else:
		wrong(GameState.tr2("Hampir! Semak semula pilihan kamu.", "Almost! Check your choices again."))
