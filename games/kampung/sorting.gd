## Shared sorting activity (Pinggan Sihat, Kitar Semula): drag every picture into its zone.
class_name KampungSorting
extends KampungActivity

var _cards := HFlowContainer.new()
var _zones := HBoxContainer.new()
var _left := 0


func build(answers: Dictionary, zones: Array, praise: String) -> void:
	_zones.add_theme_constant_override("separation", 16)
	body.add_child(_zones)
	for z in zones:
		var zone := KampungActivity.Zone.new()
		zone.category = z.id
		zone.title = z.title
		zone.answers = answers
		zone.tint = z.get("tint", Color("fdfcf7"))
		zone.icon_ref = z.get("icon", "")
		zone.custom_minimum_size = Vector2(z.get("w", 370), 360)
		zone.sorted.connect(func(ok, ref):
			if ok:
				var e := EduAssets.entry(ref)
				if e.has("subject"):
					Audio.say_vocab(e.subject, e.id)
				_left -= 1
				if _left == 0:
					say(praise, "happy")
					finish()
			else:
				wrong(GameState.tr2("Cuba kotak lain.", "Try another box.")))
		_zones.add_child(zone)
	_cards.add_theme_constant_override("h_separation", 12)
	_cards.add_theme_constant_override("v_separation", 12)
	body.add_child(_cards)
	var refs := answers.keys()
	refs.shuffle()
	for r in refs:
		var c := PictureCard.new()
		c.ref = r
		var cap: Array = Kampung.CAPTIONS.get(r, [])
		var bin_game := answers == Kampung.RECYCLE  # banana/apple mean peel/core only in the bin game
		if not cap.is_empty() and (bin_game or not r in ["bahasa_melayu/pisang", "bahasa_melayu/epal"]):
			c.caption = cap[0 if GameState.lang == "ms" else 1]
		c.draggable = true
		c.custom_minimum_size = Vector2(160, 185)
		_cards.add_child(c)
	_left = refs.size()
