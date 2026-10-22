## Mission 3: test objects with a magnet (drag the magnet onto a card: magnetic ones
## jump and click), then sort every object into "attracted" / "not attracted".
extends Mission2D

var _items := GridContainer.new()
var _bins := HBoxContainer.new()
var _placed := 0
var _total := 8


class Bin extends PanelContainer:
	signal sorted(ok: bool, ref: String)
	var attracted := true
	var flow := HFlowContainer.new()

	func _ready() -> void:
		theme_type_variation = "PanelCream"
		custom_minimum_size = Vector2(700, 330)
		var v := VBoxContainer.new()
		add_child(v)
		var l := Label.new()
		l.text = GameState.tr2("Ditarik oleh magnet", "Attracted") if attracted else GameState.tr2("Tidak ditarik", "Not attracted")
		l.theme_type_variation = "LabelHeading"
		l.add_theme_color_override("font_color", Color("2d936c") if attracted else Color("c1121f"))
		v.add_child(l)
		v.add_child(flow)

	func _can_drop_data(_at: Vector2, data: Variant) -> bool:
		return data is Dictionary and data.has("key") and data.node is PictureCard

	func _drop_data(_at: Vector2, data: Variant) -> void:
		var ref: String = data.key
		var truth := false
		for o in Makmal.MAGNET_OBJECTS:
			if o[0] == ref:
				truth = o[1]
		if truth == attracted:
			var card: PictureCard = data.node
			card.reparent(flow, false)
			card.custom_minimum_size = Vector2(120, 130)
			card.draggable = false
			Audio.sfx("snap")
			sorted.emit(true, ref)
		else:
			sorted.emit(false, ref)


func _ready() -> void:
	setup(2, GameState.tr2("Seret magnet ke atas objek untuk menguji. Kemudian seret objek ke kotak yang betul.", "Drag the magnet onto an object to test it. Then drag each object into the right box."), "lab_magnet")
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 30)
	body.add_child(row)
	var mag := MagnetTool.new()
	row.add_child(mag)
	_items.columns = 4
	_items.add_theme_constant_override("h_separation", 12)
	_items.add_theme_constant_override("v_separation", 12)
	row.add_child(_items)
	var pool := Makmal.MAGNET_OBJECTS.duplicate()
	pool.shuffle()
	var yes := pool.filter(func(o): return o[1]).slice(0, 4)
	var no := pool.filter(func(o): return not o[1]).slice(0, 4)
	var pick := yes + no
	pick.shuffle()
	for o in pick:
		var c := PictureCard.new()
		c.ref = o[0]
		c.draggable = true
		c.set_meta("magnetic", o[1])
		c.custom_minimum_size = Vector2(170, 190)
		_items.add_child(c)
	_bins.add_theme_constant_override("separation", 30)
	body.add_child(_bins)
	for a in [true, false]:
		var b := Bin.new()
		b.attracted = a
		b.sorted.connect(_on_sorted)
		_bins.add_child(b)
	KitUtil.maybe_shot(self, "makmal_magnet", 2.0)


func _on_sorted(ok: bool, _ref: String) -> void:
	if not ok:
		wrong(GameState.tr2("Cuba uji dengan magnet dahulu!", "Test it with the magnet first!"))
		return
	_placed += 1
	if _placed >= _total:
		say(GameState.tr2("Bagus! Magnet menarik objek yang diperbuat daripada besi dan keluli.", "Well done! Magnets attract things made of iron and steel."), "happy")
		finish()


## A draggable magnet; dropping it on a PictureCard shows whether the object is magnetic.
class MagnetTool extends TextureRect:
	func _init() -> void:
		texture = EduAssets.texture("sains/magnet")
		expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		custom_minimum_size = Vector2(260, 300)
		tooltip_text = "Magnet"

	var _dragging := false

	func _get_drag_data(_at: Vector2) -> Variant:
		_dragging = true
		var p := TextureRect.new()
		p.texture = texture
		p.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		p.size = Vector2(140, 140)
		p.position = -p.size / 2
		var h := Control.new()
		h.add_child(p)
		set_drag_preview(h)
		return {"magnet": true}

	func _notification(what: int) -> void:
		if what == NOTIFICATION_DRAG_END and _dragging:  # every Control hears DRAG_END; only react to our own drag
			_dragging = false
			var hovered := get_viewport().gui_get_hovered_control()
			while hovered and not hovered is PictureCard:
				hovered = hovered.get_parent() as Control
			if hovered:
				call_deferred("test", hovered)

	func test(card: PictureCard) -> void:
		card.pivot_offset = card.size / 2
		var tw := card.create_tween()
		if card.get_meta("magnetic", false):
			Audio.sfx("snap")
			tw.tween_property(card, "rotation", -0.12, 0.06)
			tw.tween_property(card, "rotation", 0.12, 0.06)
			tw.tween_property(card, "rotation", 0.0, 0.06)
			card.modulate = Color(0.8, 1.15, 0.8)
		else:
			Audio.sfx("ui_back")
			tw.tween_property(card, "modulate", Color(1, 0.8, 0.8), 0.1)
			tw.tween_property(card, "modulate", Color.WHITE, 0.4)
