## Demo: drag the word to its picture (BM or EN, follows GameState.lang).
## Uses PictureCard (tap to hear the word), DropSlot and draggable TextTiles.
extends Control

const GAME_ID := "demo_dragdrop"
const ROUND := 4

var _slots: Array[DropSlot] = []
var _row_pics := HBoxContainer.new()
var _row_words := HBoxContainer.new()
var _results := ResultsPanel.new()
var _done := 0
var _mistakes := 0
var _pool: Array[String] = []


func _ready() -> void:
	KitUtil.background(self, "backgrounds/classroom")
	var col := VBoxContainer.new()
	col.set_anchors_preset(Control.PRESET_FULL_RECT)
	col.offset_top = 130
	col.offset_bottom = -60
	col.add_theme_constant_override("separation", 30)
	add_child(col)
	var title := Label.new()
	title.text = GameState.tr2("Padankan gambar dengan perkataan", "Match the picture with the word")
	title.theme_type_variation = "LabelTitle"
	title.add_theme_color_override("font_color", Color.WHITE)
	title.add_theme_color_override("font_outline_color", Color("2b2d42"))
	title.add_theme_constant_override("outline_size", 14)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(title)
	for r in [_row_pics, _row_words]:
		r.alignment = BoxContainer.ALIGNMENT_CENTER
		r.add_theme_constant_override("separation", 40)
		col.add_child(r)
		if r == _row_pics:
			var spacer := Control.new()
			spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
			col.add_child(spacer)
	_results.game_id = GAME_ID
	_results.retry.connect(_start)
	_results.next.connect(_start)
	_results.menu.connect(func(): Fader.go("res://demo/gallery.tscn"))
	add_child(_results)
	KitUtil.home_button(self)
	_pool = EduAssets.by_tag("fruit") + EduAssets.by_tag("animal").filter(func(r): return r.begins_with("bahasa_inggeris"))
	Audio.music("jelajah_santai")
	_start()
	KitUtil.maybe_shot(self, "demo_dragdrop", 2.0)


func _start() -> void:
	for c in _row_pics.get_children() + _row_words.get_children():
		c.queue_free()
	_slots.clear()
	_done = 0
	_mistakes = 0
	var pick := _pool.duplicate()
	pick.shuffle()
	pick = pick.slice(0, ROUND)
	for r in pick:
		var col := VBoxContainer.new()
		col.add_theme_constant_override("separation", 12)
		var card := PictureCard.new()
		card.ref = r
		card.show_name = false
		card.custom_minimum_size = Vector2(300, 280)
		col.add_child(card)
		var slot := DropSlot.new()
		slot.accept_key = r
		slot.custom_minimum_size = Vector2(300, 120)
		slot.dropped.connect(_on_dropped)
		col.add_child(slot)
		_slots.append(slot)
		_row_pics.add_child(col)
	var words := pick.duplicate()
	words.shuffle()
	for i in words.size():
		var t := TextTile.new()
		t.text = EduAssets.name_of(words[i])
		t.key = words[i]
		t.draggable = true
		t.color = TextTile.COLORS[i % 6]
		t.custom_minimum_size = Vector2(300, 110)
		_row_words.add_child(t)
	Audio.say("feedback", "match")


func _on_dropped(correct: bool, key: String, _item: Control) -> void:
	if correct:
		_done += 1
		var e := EduAssets.entry(key)
		Audio.say_vocab(e.subject, e.id)
		if _done == ROUND:
			await get_tree().create_timer(0.8).timeout
			_results.open(maxi(ROUND - _mistakes, 0), ROUND)
	else:
		_mistakes += 1
