## One Kancil level built from Kancil.build(): run, collect the word's parts, jump over
## tigers and spikes, hop across crocodiles, then arrange the parts at each word gate.
extends Node2D

const TS := 64
const GRASS := [Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(3, 0)]
const DIRT := Vector2i(1, 1)
const BRICK := Vector2i(4, 1)
const PLANK := [Vector2i(4, 0), Vector2i(5, 0), Vector2i(6, 0)]
const SPIKE := Vector2i(6, 3)
const WATER_TOP := Vector2i(3, 3)
const WATER := Vector2i(4, 3)

var data := {}
var words: Array = []
var map := TileMapLayer.new()
var player := Player2D.new()
var collected: Array = []      # [{text, word, decoy}]
var solved: Array = []          # word indexes done
var errors := 0
var parts_total := 0
var checkpoint := Vector2.ZERO
var _hud := CanvasLayer.new()
var _inv := HBoxContainer.new()
var _targets := HBoxContainer.new()
var _panel := PanelContainer.new()
var _panel_word := -1
var _slots: Array[DropSlot] = []
var _results := ResultsPanel.new()
var _finished := false
var _gate_cells := {}           # word index -> Array[Vector2i]


func _ready() -> void:
	data = Kancil.build(Kancil.level)
	words = Kancil.level_words(Kancil.level)
	for w in words:
		parts_total += w.parts.size()
	_background()
	map.tile_set = load("res://kit/tiles/platformer_tileset.tres")
	add_child(map)
	_terrain()
	_items()
	player.sprite_ref = "bahasa_melayu/sang_kancil"
	player.height_px = 165
	player.position = checkpoint
	player.hurt.connect(func(): errors += 1)
	add_child(player)
	var cam := Camera2D.new()
	cam.limit_left = 0
	cam.limit_right = data.width * TS
	cam.limit_bottom = Kancil.ROWS * TS
	cam.limit_top = Kancil.ROWS * TS - 1080
	cam.position_smoothing_enabled = true
	player.add_child(cam)
	_build_hud()
	add_child(TouchControls.new())
	Audio.music("jelajah_santai" if Kancil.level % 2 else "santai_kampung")
	KitUtil.maybe_shot(self, "kancil_level", 2.0)


func _physics_process(_d: float) -> void:
	if player.position.y > (Kancil.ROWS + 2) * TS:
		errors += 1
		Audio.sfx("hurt")
		player.velocity = Vector2.ZERO
		player.position = checkpoint


# ---------------- world ----------------
func _background() -> void:
	var layer := CanvasLayer.new()
	layer.layer = -10
	add_child(layer)
	KitUtil.background(_wrap(layer), "backgrounds/" + ("kampung" if Kancil.mode == "ms" and Kancil.level <= 5 else ("rainforest" if Kancil.mode == "ms" else "school_field")))
	var pb := ParallaxBackground.new()
	add_child(pb)
	var pl := ParallaxLayer.new()
	pl.motion_scale = Vector2(0.4, 1.0)
	pl.motion_mirroring = Vector2(1920, 0)
	var s := Sprite2D.new()
	s.texture = EduAssets.texture("backgrounds/parallax_near")
	s.centered = false
	s.position.y = Kancil.ROWS * TS - 1080 + 140
	s.modulate = Color(1, 1, 1, 0.9)
	pl.add_child(s)
	pb.add_child(pl)


static func _wrap(layer: CanvasLayer) -> Control:
	var c := Control.new()
	c.set_anchors_preset(Control.PRESET_FULL_RECT)
	c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(c)
	return c


func _row(h: int) -> int:
	return Kancil.ROWS - 1 - h


func _terrain() -> void:
	var hs: Array = data.heights
	for x in hs.size():
		var h: int = hs[x]
		if h == -1:
			map.set_cell(Vector2i(x, Kancil.ROWS - 2), 0, WATER_TOP)
			map.set_cell(Vector2i(x, Kancil.ROWS - 1), 0, WATER)
			continue
		if h <= 0:
			continue
		var left: bool = x > 0 and hs[x - 1] >= h
		var right: bool = x < hs.size() - 1 and hs[x + 1] >= h
		map.set_cell(Vector2i(x, _row(h)), 0, GRASS[1 if left and right else (0 if right else (2 if left else 3))])
		for y in range(_row(h) + 1, Kancil.ROWS):
			map.set_cell(Vector2i(x, y), 0, DIRT)


func _items() -> void:
	for it in data.items:
		var px: float = it.x * TS + TS / 2.0
		match it.type:
			"start":
				checkpoint = Vector2(px, _row(it.h) * TS)
			"part", "decoy":
				_pickup(it, Vector2(px, (_row(it.h) - 1) * TS - 16))
			"plank":
				for k in it.w:
					map.set_cell(Vector2i(it.x + k, _row(it.h)), 0, PLANK[0 if k == 0 else (2 if k == it.w - 1 else 1)])
			"spike":
				map.set_cell(Vector2i(it.x, _row(it.h) - 1), 0, SPIKE)
			"tiger":
				_tiger(it)
			"croc":
				_croc(it)
			"gate":
				_gate(it)
			"flag":
				_flag(Vector2(px, _row(it.h) * TS))


func _area(pos: Vector2, shape: Shape2D) -> Area2D:
	var a := Area2D.new()
	a.position = pos
	var cs := CollisionShape2D.new()
	cs.shape = shape
	a.add_child(cs)
	add_child(a)
	return a


func _circle(r: float) -> CircleShape2D:
	var c := CircleShape2D.new()
	c.radius = r
	return c


func _pickup(it: Dictionary, pos: Vector2) -> void:
	var a := _area(pos, _circle(44))
	var tile := TextTile.new()
	tile.text = it.text if Kancil.mode == "ms" else it.text.to_upper()
	tile.color = "yellow" if it.type == "part" else "purple"
	tile.size = Vector2(84, 84)
	tile.custom_minimum_size = Vector2(84, 84)
	tile.position = Vector2(-42, -42)
	tile.mouse_filter = Control.MOUSE_FILTER_IGNORE
	a.add_child(tile)
	var tw := a.create_tween().set_loops()
	tw.tween_property(tile, "position:y", -54.0, 0.6).set_trans(Tween.TRANS_SINE)
	tw.tween_property(tile, "position:y", -42.0, 0.6).set_trans(Tween.TRANS_SINE)
	a.body_entered.connect(func(b):
		if b != player:
			return
		collected.append({"text": it.text, "word": it.word, "decoy": it.type == "decoy"})
		Audio.sfx("collect")
		Audio.say("syllables" if Kancil.mode == "ms" else "letters", it.text, Kancil.mode)
		_refresh_inventory()
		a.queue_free())


func _tiger(it: Dictionary) -> void:
	var y := _row(it.h) * TS
	var shape := RectangleShape2D.new()
	shape.size = Vector2(90, 80)
	var a := _area(Vector2(it.x * TS, y - 45), shape)
	var s := Sprite2D.new()
	s.texture = EduAssets.texture("bahasa_melayu/harimau")
	s.scale = Vector2.ONE * 120.0 / 512.0
	s.position.y = -14
	a.add_child(s)
	var tw := a.create_tween().set_loops()
	tw.tween_property(a, "position:x", (it.x + it.w) * TS, 2.2 + randf())
	tw.tween_callback(func(): s.flip_h = true)
	tw.tween_property(a, "position:x", it.x * TS, 2.2 + randf())
	tw.tween_callback(func(): s.flip_h = false)
	a.body_entered.connect(func(b):
		if b == player:
			player.bump(signf(player.position.x - a.position.x) if player.position.x != a.position.x else -1.0))


func _croc(it: Dictionary) -> void:
	var body := AnimatableBody2D.new()
	body.position = Vector2(it.x * TS + TS / 2.0, _row(it.h) * TS + 10)
	var cs := CollisionShape2D.new()
	var r := RectangleShape2D.new()
	r.size = Vector2(150, 22)
	cs.shape = r
	cs.one_way_collision = true
	body.add_child(cs)
	var s := Sprite2D.new()
	s.texture = EduAssets.texture("bahasa_melayu/buaya")
	s.scale = Vector2.ONE * 190.0 / 512.0
	s.position = Vector2(0, -6)
	body.add_child(s)
	add_child(body)
	var tw := body.create_tween().set_loops().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	tw.tween_property(body, "position:y", body.position.y + 10, 0.9).set_trans(Tween.TRANS_SINE)
	tw.tween_property(body, "position:y", body.position.y, 0.9).set_trans(Tween.TRANS_SINE)


func _gate(it: Dictionary) -> void:
	var cells: Array[Vector2i] = []
	for k in 4:
		var c := Vector2i(it.x, _row(it.h) - 1 - k)
		map.set_cell(c, 0, BRICK)
		cells.append(c)
	_gate_cells[it.word] = cells
	var board := Sprite2D.new()
	board.texture = EduAssets.texture(words[it.word].img)
	board.scale = Vector2.ONE * 110.0 / board.texture.get_width()
	board.position = Vector2(it.x * TS + TS / 2.0, (_row(it.h) - 5) * TS - 20)
	add_child(board)
	var shape := RectangleShape2D.new()
	shape.size = Vector2(60, 300)
	var a := _area(Vector2(it.x * TS - 30, (_row(it.h) - 2) * TS), shape)
	a.body_entered.connect(func(b):
		if b == player and not it.word in solved:
			_try_gate(it.word, Vector2(it.x * TS - TS * 2, _row(it.h) * TS)))


func _flag(pos: Vector2) -> void:
	var a := _area(pos + Vector2(0, -60), _circle(60))
	var s := Sprite2D.new()
	s.texture = EduAssets.texture("icons/flag")
	s.scale = Vector2.ONE * 0.6
	s.position.y = -50
	a.add_child(s)
	a.body_entered.connect(func(b):
		if b == player and not _finished and solved.size() == words.size():
			_finish())


# ---------------- HUD ----------------
func _build_hud() -> void:
	add_child(_hud)
	var top := HBoxContainer.new()
	top.position = Vector2(24, 20)
	top.add_theme_constant_override("separation", 18)
	_hud.add_child(top)
	var home := Button.new()
	home.icon = EduAssets.texture("icons/home")
	home.expand_icon = true
	home.custom_minimum_size = Vector2(88, 88)
	home.theme_type_variation = "ButtonYellow"
	home.process_mode = Node.PROCESS_MODE_ALWAYS
	home.pressed.connect(func(): get_tree().paused = false; Fader.go(Kancil.SCENES.menu))
	top.add_child(home)
	var lv := Label.new()
	lv.text = GameState.tr2("Tahap %d", "Level %d") % Kancil.level
	lv.theme_type_variation = "LabelHeading"
	lv.add_theme_color_override("font_color", Color.WHITE)
	lv.add_theme_color_override("font_outline_color", Color("2b2d42"))
	lv.add_theme_constant_override("outline_size", 10)
	top.add_child(lv)
	_targets.add_theme_constant_override("separation", 10)
	top.add_child(_targets)
	_inv.add_theme_constant_override("separation", 8)
	top.add_child(_inv)
	_refresh_targets()
	_build_panel()
	_results.process_mode = Node.PROCESS_MODE_ALWAYS
	_results.game_id = ""
	_results.retry.connect(func(): get_tree().paused = false; get_tree().reload_current_scene())
	_results.next.connect(_next_level)
	_results.menu.connect(func(): get_tree().paused = false; Fader.go(Kancil.SCENES.menu))
	_hud.add_child(_results)


func _refresh_targets() -> void:
	for c in _targets.get_children():
		c.queue_free()
	for wi in words.size():
		var t := TextureRect.new()
		t.texture = EduAssets.texture(words[wi].img)
		t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		t.custom_minimum_size = Vector2(80, 80)
		t.modulate = Color.WHITE if wi in solved else Color(1, 1, 1, 0.45)
		_targets.add_child(t)


func _refresh_inventory() -> void:
	for c in _inv.get_children():
		c.queue_free()
	for c in collected:
		var t := TextTile.new()
		t.text = c.text if Kancil.mode == "ms" else c.text.to_upper()
		t.color = "purple" if c.decoy else "yellow"
		t.custom_minimum_size = Vector2(70, 70)
		t.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_inv.add_child(t)


# ---------------- spelling at a gate ----------------
func _build_panel() -> void:
	_panel.theme_type_variation = "PanelCream"
	_panel.process_mode = Node.PROCESS_MODE_ALWAYS
	_panel.custom_minimum_size = Vector2(1100, 640)
	_panel.position = Vector2(410, 200)
	_panel.hide()
	_hud.add_child(_panel)


func _try_gate(wi: int, back_pos: Vector2) -> void:
	var word: Dictionary = words[wi]
	var have := collected.filter(func(c): return c.word == wi and not c.decoy).size()
	if have < word.parts.size():
		Audio.sfx("error_buzz")
		Feedback.float_text(self, GameState.tr2("Kutip semua suku kata dahulu!", "Collect all the letters first!") if Kancil.mode == "ms" else "Collect all the letters first!", Vector2(560, 300), Color("ef476f"))
		player.position = back_pos
		player.velocity = Vector2.ZERO
		return
	_open_panel(wi)


func _open_panel(wi: int) -> void:
	get_tree().paused = true
	_panel_word = wi
	for c in _panel.get_children():
		_panel.remove_child(c)  # detach now so the new tray is child 0 immediately
		c.queue_free()
	_slots.clear()
	var word: Dictionary = words[wi]
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 18)
	v.alignment = BoxContainer.ALIGNMENT_CENTER
	_panel.add_child(v)
	var l := Label.new()
	l.text = "Susun suku kata menjadi perkataan" if Kancil.mode == "ms" else "Put the letters in order"
	l.theme_type_variation = "LabelHeading"
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(l)
	var pic := PictureCard.new()
	pic.ref = word.img
	pic.show_name = false
	pic.custom_minimum_size = Vector2(240, 220)
	pic.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	pic.pressed.connect(func(): Audio.say("words", word.word, Kancil.mode))
	v.add_child(pic)
	var slots := HBoxContainer.new()
	slots.alignment = BoxContainer.ALIGNMENT_CENTER
	slots.add_theme_constant_override("separation", 12)
	v.add_child(slots)
	for p in word.parts:
		var s := DropSlot.new()
		s.accept_key = p
		s.custom_minimum_size = Vector2(130, 130)
		s.dropped.connect(_on_drop)
		slots.add_child(s)
		_slots.append(s)
	var tray := HBoxContainer.new()
	tray.alignment = BoxContainer.ALIGNMENT_CENTER
	tray.add_theme_constant_override("separation", 14)
	v.add_child(tray)
	var parts: Array = word.parts.duplicate()
	parts += collected.filter(func(c): return c.word == wi and c.decoy).map(func(c): return c.text)
	parts += Kancil.decoys(word, 1)
	parts.shuffle()
	for i in parts.size():
		var t := TextTile.new()
		t.text = parts[i] if Kancil.mode == "ms" else parts[i].to_upper()
		t.key = parts[i]
		t.draggable = true
		t.speak_group = "syllables" if Kancil.mode == "ms" else "letters"
		t.color = TextTile.COLORS[i % 6]
		t.custom_minimum_size = Vector2(120, 120)
		tray.add_child(t)
	_panel.show()
	Audio.say("words", word.word, Kancil.mode)


func _on_drop(ok: bool, _key: String, _item: Control) -> void:
	if not ok:
		errors += 1
		return
	if _slots.all(func(s): return s.filled):
		var wi := _panel_word
		Audio.say("words", words[wi].word, Kancil.mode)
		Feedback.result(self, true, false)
		await get_tree().create_timer(1.6).timeout
		_solve(wi)


func _solve(wi: int) -> void:
	solved.append(wi)
	for c in _gate_cells[wi]:
		map.erase_cell(c)
	collected = collected.filter(func(c): return c.word != wi)
	_refresh_inventory()
	_refresh_targets()
	_panel.hide()
	get_tree().paused = false
	checkpoint = player.position
	Audio.sfx("unlock")


func _finish() -> void:
	_finished = true
	get_tree().paused = true
	player.set_expression("cheer")
	var total := parts_total * 2
	var score := maxi(total - errors, 0)
	var stars := StarRating.stars_for(score, total)
	GameState.record_level(Kancil.game_id(), Kancil.level, maxi(stars, 1), score)
	_results.open(maxi(score, ceili(total * 0.4)), total)


func _next_level() -> void:
	get_tree().paused = false
	if Kancil.level < Kancil.level_count():
		Kancil.level += 1
		get_tree().reload_current_scene()
	else:
		Fader.go(Kancil.SCENES.menu)
