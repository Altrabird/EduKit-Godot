## Kitar Semula: Malaysia's bin colours (blue paper, brown glass, orange plastic & cans).
extends KampungSorting


func _ready() -> void:
	setup(1, "backgrounds/kampung", GameState.tr2("Seret setiap barang ke dalam tong yang betul.", "Drag each item into the right bin."), "kg_recycle", "arjun")
	var zones := []
	for b in Kampung.BINS:
		zones.append({"id": b[0], "title": b[2] if GameState.lang == "ms" else b[3], "icon": b[1], "w": 375})
	build(Kampung.RECYCLE, zones, GameState.tr2("Syabas! Kitar semula menjaga alam sekitar kita.", "Well done! Recycling looks after our environment."))
	KitUtil.maybe_shot(self, "kampung_recycle", 2.0)
