## End-of-round screen: stars, score, praise line, and Retry / Next / Menu.
##   results.open(score, total)   # computes stars, records progress if game_id is set
class_name ResultsPanel
extends PanelContainer

signal retry
signal next
signal menu

@export var game_id := ""
@export var level := 1

var _title := Label.new()
var _stars := StarRating.new()
var _score := Label.new()


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	custom_minimum_size = Vector2(720, 560)
	var v := VBoxContainer.new()
	v.alignment = BoxContainer.ALIGNMENT_CENTER
	v.add_theme_constant_override("separation", 22)
	add_child(v)
	var ribbon := TextureRect.new()
	ribbon.texture = load("res://assets/art/ui/ribbon_banner.svg")
	ribbon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	ribbon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	ribbon.custom_minimum_size = Vector2(640, 150)
	v.add_child(ribbon)
	_title.theme_type_variation = "LabelTitle"
	_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title.add_theme_color_override("font_color", Color.WHITE)
	_title.set_anchors_preset(Control.PRESET_FULL_RECT)
	_title.offset_top = 10
	_title.offset_bottom = -40
	_title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	ribbon.add_child(_title)
	v.add_child(_stars)
	_score.theme_type_variation = "LabelHeading"
	_score.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(_score)
	var h := HBoxContainer.new()
	h.alignment = BoxContainer.ALIGNMENT_CENTER
	h.add_theme_constant_override("separation", 20)
	v.add_child(h)
	for b in [["icons/restart", "ButtonOrange", retry], ["icons/next", "ButtonGreen", next], ["icons/home", "ButtonBlue", menu]]:
		var btn := Button.new()
		btn.icon = EduAssets.texture(b[0])
		btn.expand_icon = true
		btn.custom_minimum_size = Vector2(130, 110)
		btn.theme_type_variation = b[1]
		var sig: Signal = b[2]
		btn.pressed.connect(func(): Audio.sfx("ui_click"); hide(); sig.emit())
		h.add_child(btn)
	hide()


func open(score: int, total: int) -> int:
	var n := StarRating.stars_for(score, total)
	_title.text = GameState.tr2("Tahniah!", "Well done!") if n >= 2 else (GameState.tr2("Bagus!", "Good try!") if n == 1 else GameState.tr2("Cuba lagi!", "Try again!"))
	_score.text = "%d / %d" % [score, total]
	show()
	pivot_offset = size / 2
	scale = Vector2(0.6, 0.6)
	create_tween().tween_property(self, "scale", Vector2.ONE, 0.3).set_trans(Tween.TRANS_BACK)
	if game_id != "":
		if GameState.record_level(game_id, level, n, score) and n > 0:
			Audio.say("feedback", "new_record")
	Audio.music("jingle_menang" if n >= 2 else "jingle_cuba_lagi", 0.2)
	if n == 3:
		Feedback.confetti(self, get_viewport_rect().size / 2, 90)
	_stars.set_stars(n)
	return n
