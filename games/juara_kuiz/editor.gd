## Teacher editor: add / edit / delete own questions per subject. They are stored in
## user://questions (browser storage on the web) and merged into every round.
## Share with other teachers: Download JSON, then Import by pasting it.
extends Control

var _subject := OptionButton.new()
var _list := ItemList.new()
var _year := SpinBox.new()
var _q := {"ms": LineEdit.new(), "en": LineEdit.new()}
var _ans := {"ms": [], "en": []}
var _image := OptionButton.new()
var _preview := TextureRect.new()
var _status := Label.new()
var _import_box := PanelContainer.new()
var _import_text := TextEdit.new()
var _items: Array = []
var _editing := -1
var _image_refs: Array[String] = []


func _ready() -> void:
	KitUtil.background(self, "backgrounds/pattern_graph").stretch_mode = TextureRect.STRETCH_TILE
	var root := HBoxContainer.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.offset_left = 30; root.offset_top = 24; root.offset_right = -30; root.offset_bottom = -24
	root.add_theme_constant_override("separation", 24)
	add_child(root)
	# ---- left: subject + list ----
	var left := VBoxContainer.new()
	left.custom_minimum_size = Vector2(620, 0)
	left.add_theme_constant_override("separation", 12)
	root.add_child(left)
	var top := HBoxContainer.new()
	var back := JksUI.icon_button("icons/back", "ButtonYellow", 80)
	back.pressed.connect(func(): JksUI.go("menu"))
	top.add_child(back)
	top.add_child(JksUI.title(GameState.tr2("Soalan Guru", "Teacher Questions"), "LabelTitle", Color("2b2d42")))
	left.add_child(top)
	for s in EduAssets.SUBJECTS:
		_subject.add_item(EduAssets.subject_name(s, GameState.lang))
	_subject.custom_minimum_size = Vector2(0, 72)
	_subject.item_selected.connect(func(_i): _load_subject())
	left.add_child(_subject)
	_list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_list.add_theme_font_size_override("font_size", 24)
	_list.item_selected.connect(_edit)
	left.add_child(_list)
	var lb := HBoxContainer.new()
	lb.add_theme_constant_override("separation", 10)
	for b in [[GameState.tr2("Baharu", "New"), "ButtonGreen", _new], [GameState.tr2("Padam", "Delete"), "ButtonRed", _delete],
			[GameState.tr2("Muat turun", "Download"), "ButtonBlue", _export], [GameState.tr2("Import", "Import"), "ButtonPurple", func(): _import_box.show()]]:
		var btn := JksUI.button(b[0], b[1], "", Vector2(140, 72))
		btn.add_theme_font_size_override("font_size", 26)
		btn.pressed.connect(b[2])
		lb.add_child(btn)
	left.add_child(lb)
	# ---- right: form ----
	var form := PanelContainer.new()
	form.theme_type_variation = "PanelCream"
	form.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root.add_child(form)
	var f := VBoxContainer.new()
	f.add_theme_constant_override("separation", 10)
	form.add_child(f)
	var yr := HBoxContainer.new()
	yr.add_child(_lbl(GameState.tr2("Tahun", "Year")))
	_year.min_value = 1
	_year.max_value = 6
	_year.value = 1
	yr.add_child(_year)
	f.add_child(yr)
	for lang in ["ms", "en"]:
		f.add_child(_lbl(GameState.tr2("Soalan (BM)", "Question (BM)") if lang == "ms" else GameState.tr2("Soalan (BI) — kosong = sama seperti BM", "Question (EN) — empty = same as BM")))
		_q[lang].custom_minimum_size = Vector2(0, 56)
		f.add_child(_q[lang])
	var grid := GridContainer.new()
	grid.columns = 3
	grid.add_theme_constant_override("h_separation", 10)
	grid.add_child(_lbl(""))
	grid.add_child(_lbl("BM"))
	grid.add_child(_lbl("EN"))
	for k in 4:
		var tag := _lbl(GameState.tr2("✓ Betul", "✓ Correct") if k == 0 else GameState.tr2("Salah %d", "Wrong %d") % k)
		tag.add_theme_color_override("font_color", Color("2d936c") if k == 0 else Color("c1121f"))
		grid.add_child(tag)
		for lang in ["ms", "en"]:
			var e := LineEdit.new()
			e.custom_minimum_size = Vector2(380, 52)
			e.add_theme_font_size_override("font_size", 26)
			grid.add_child(e)
			_ans[lang].append(e)
	f.add_child(grid)
	var ir := HBoxContainer.new()
	ir.add_theme_constant_override("separation", 12)
	ir.add_child(_lbl(GameState.tr2("Gambar", "Picture")))
	_image.custom_minimum_size = Vector2(420, 60)
	_image.item_selected.connect(func(i): _preview.texture = EduAssets.texture(_image_refs[i]) if i > 0 else null)
	ir.add_child(_image)
	_preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_preview.custom_minimum_size = Vector2(110, 110)
	ir.add_child(_preview)
	f.add_child(ir)
	var save := JksUI.button(GameState.tr2("Simpan", "Save"), "ButtonGreen", "icons/check", Vector2(0, 90))
	save.pressed.connect(_save)
	f.add_child(save)
	_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	f.add_child(_status)
	_build_import()
	_load_subject()
	KitUtil.maybe_shot(self, "jks_editor", 1.5)


func _lbl(t: String) -> Label:
	var l := Label.new()
	l.text = t
	l.add_theme_font_size_override("font_size", 24)
	return l


func _subj() -> String:
	return EduAssets.SUBJECTS[_subject.selected]


func _load_subject() -> void:
	_items = Questions.user_bank(_subj())
	_list.clear()
	for q in _items:
		_list.add_item("T%d  %s" % [int(q.get("year", 1)), q.q.ms])
	_image.clear()
	_image_refs = [""]
	_image.add_item(GameState.tr2("(tiada)", "(none)"))
	for r in EduAssets.by_subject(_subj()):
		_image_refs.append(r)
		_image.add_item(EduAssets.name_of(r))
	_new()
	_status.text = GameState.tr2("%d soalan guru untuk subjek ini.", "%d teacher questions for this subject.") % _items.size()


func _new() -> void:
	_editing = -1
	_list.deselect_all()
	for lang in _q:
		_q[lang].text = ""
		for e in _ans[lang]:
			e.text = ""
	_image.select(0)
	_preview.texture = null


func _edit(idx: int) -> void:
	_editing = idx
	var q: Dictionary = _items[idx]
	_year.value = int(q.get("year", 1))
	for lang in ["ms", "en"]:
		_q[lang].text = q.q[lang]
		for k in 4:
			_ans[lang][k].text = q.choices[lang][k]
	var ii := _image_refs.find(q.get("image", ""))
	_image.select(maxi(ii, 0))
	_preview.texture = EduAssets.texture(q.image) if ii > 0 else null


func _form() -> Dictionary:
	var q := {"year": int(_year.value), "q": {}, "choices": {"ms": [], "en": []}, "answer": 0, "image": _image_refs[_image.selected]}
	q.q["ms"] = _q.ms.text.strip_edges()
	q.q["en"] = _q.en.text.strip_edges() if _q.en.text.strip_edges() != "" else q.q.ms
	for k in 4:
		var m: String = _ans.ms[k].text.strip_edges()
		var e: String = _ans.en[k].text.strip_edges()
		q.choices.ms.append(m)
		q.choices.en.append(e if e != "" else m)
	return q


func _save() -> void:
	var q := _form()
	var err := Questions.validate(q)
	if err != "":
		_status.text = "✗ " + err
		Audio.sfx("error_buzz")
		return
	q["uid"] = _items[_editing].get("uid", "") if _editing >= 0 else "u%d" % Time.get_ticks_usec()
	if _editing >= 0:
		_items[_editing] = q
	else:
		_items.append(q)
	if Questions.save_user_bank(_subj(), _items):
		Audio.sfx("correct")
		_load_subject()
		_status.text = GameState.tr2("✓ Disimpan. Soalan ini akan muncul dalam kuiz.", "✓ Saved. This question will appear in quizzes.")


func _delete() -> void:
	if _editing < 0:
		return
	_items.remove_at(_editing)
	Questions.save_user_bank(_subj(), _items)
	Audio.sfx("drop")
	_load_subject()


func _export() -> void:
	var text := JSON.stringify(_items, " ")
	DisplayServer.clipboard_set(text)
	var file := "juara_kuiz_%s.json" % _subj()
	if OS.has_feature("web"):
		JavaScriptBridge.download_buffer(text.to_utf8_buffer(), file, "application/json")
	else:
		var path := OS.get_system_dir(OS.SYSTEM_DIR_DOWNLOADS).path_join(file)
		var fa := FileAccess.open(path, FileAccess.WRITE)
		if fa:
			fa.store_string(text)
			fa.close()
			OS.shell_show_in_file_manager(path)
	_status.text = GameState.tr2("Dimuat turun sebagai %s (juga disalin ke papan klip).", "Downloaded as %s (also copied to clipboard).") % file


func _build_import() -> void:
	_import_box.theme_type_variation = "PanelCream"
	_import_box.position = Vector2(360, 160)
	_import_box.custom_minimum_size = Vector2(1200, 700)
	_import_box.hide()
	add_child(_import_box)
	var v := VBoxContainer.new()
	_import_box.add_child(v)
	v.add_child(_lbl(GameState.tr2("Tampal JSON soalan di sini (daripada butang Muat turun):", "Paste question JSON here (from the Download button):")))
	_import_text.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_import_text.custom_minimum_size = Vector2(0, 480)
	v.add_child(_import_text)
	var h := HBoxContainer.new()
	var ok := JksUI.button(GameState.tr2("Import ke subjek ini", "Import into this subject"), "ButtonGreen", "", Vector2(0, 80))
	ok.pressed.connect(_import)
	h.add_child(ok)
	var cancel := JksUI.button(GameState.tr2("Batal", "Cancel"), "ButtonRed", "", Vector2(0, 80))
	cancel.pressed.connect(_import_box.hide)
	h.add_child(cancel)
	v.add_child(h)


func _import() -> void:
	var data = JSON.parse_string(_import_text.text)
	if not data is Array:
		_status.text = GameState.tr2("✗ JSON tidak sah.", "✗ Not valid JSON.")
		_import_box.hide()
		return
	var added := 0
	for q in data:
		if q is Dictionary and Questions.validate(q) == "":
			q["uid"] = "u%d_%d" % [Time.get_ticks_usec(), added]
			q.erase("id")  # imported questions have no recorded voice
			_items.append(q)
			added += 1
	Questions.save_user_bank(_subj(), _items)
	_import_box.hide()
	_import_text.text = ""
	_load_subject()
	_status.text = GameState.tr2("%d soalan diimport (%d ditolak).", "%d questions imported (%d rejected).") % [added, data.size() - added]
