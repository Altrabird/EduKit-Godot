## Mission 2: order three life cycles (frog, butterfly, plant) by dragging stage cards.
extends Mission2D

var _round := 0
var _keys: Array = []
var _slots: Array[DropSlot] = []
var _row_slots := HBoxContainer.new()
var _row_cards := HBoxContainer.new()
var _label := Label.new()


func _ready() -> void:
	setup(1, GameState.tr2("Seret gambar ke dalam kotak mengikut urutan kitaran hidup: 1 → 4.", "Drag the pictures into the boxes in life-cycle order: 1 → 4."), "lab_lifecycle")
	_keys = Makmal.LIFECYCLES.keys()
	_label.theme_type_variation = "LabelTitle"
	body.add_child(_label)
	for r in [_row_slots, _row_cards]:
		r.add_theme_constant_override("separation", 24)
		body.add_child(r)
	_start_round()
	KitUtil.maybe_shot(self, "makmal_lifecycle", 2.0)


func _start_round() -> void:
	for c in _row_slots.get_children() + _row_cards.get_children():
		c.get_parent().remove_child(c)
		c.queue_free()
	_slots.clear()
	var lc: Array = Makmal.LIFECYCLES[_keys[_round]]
	_label.text = "%s (%d/3)" % [lc[1] if GameState.lang == "ms" else lc[2], _round + 1]
	for i in 4:
		var col := VBoxContainer.new()
		var n := Label.new()
		n.text = str(i + 1)
		n.theme_type_variation = "LabelHeading"
		n.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		col.add_child(n)
		var s := DropSlot.new()
		s.accept_key = lc[0][i]
		s.custom_minimum_size = Vector2(250, 250)
		s.dropped.connect(_on_drop)
		col.add_child(s)
		_slots.append(s)
		_row_slots.add_child(col)
		if i < 3:
			var arrow := TextureRect.new()
			arrow.texture = EduAssets.texture("icons/next")
			arrow.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			arrow.custom_minimum_size = Vector2(70, 70)
			arrow.size_flags_vertical = Control.SIZE_SHRINK_CENTER
			_row_slots.add_child(arrow)
	var refs: Array = lc[0].duplicate()
	refs.shuffle()
	for r in refs:
		var c := PictureCard.new()
		c.ref = r
		c.draggable = true
		c.custom_minimum_size = Vector2(230, 260)
		_row_cards.add_child(c)


func _on_drop(ok: bool, key: String, _item: Control) -> void:
	if not ok:
		wrong(GameState.tr2("Belum tepat. Fikir: apa yang berlaku dahulu?", "Not yet. Think: what happens first?"))
		return
	var e := EduAssets.entry(key)
	if e.has("subject"):
		Audio.say_vocab(e.subject, e.id)
	if _slots.all(func(s): return s.filled):
		Feedback.result(self, true, false)
		await get_tree().create_timer(1.4).timeout
		_round += 1
		if _round >= _keys.size():
			say(GameState.tr2("Hebat! Semua kitaran hidup betul.", "Great! All the life cycles are correct."), "happy")
			finish()
		else:
			_start_round()
