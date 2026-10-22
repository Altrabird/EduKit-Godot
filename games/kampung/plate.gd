## Pinggan Sihat Malaysia: half vegetables & fruit, a quarter grains, a quarter protein.
extends KampungSorting


func _ready() -> void:
	setup(0, "backgrounds/kampung", GameState.tr2("Seret makanan ke bahagian pinggan yang betul. Makanan tidak sihat letak di 'Kurangkan'.", "Drag each food to the right part of the plate. Unhealthy food goes to 'Eat less'."), "kg_plate")
	var zones := []
	for z in Kampung.PLATE_ZONES:
		zones.append({"id": z[0], "title": z[1] if GameState.lang == "ms" else z[2], "tint": z[3].lightened(0.45), "w": 520 if z[0] == "sayur" else 330})
	build(Kampung.PLATE, zones, GameState.tr2("Hebat! Separuh sayur dan buah, suku bijirin, suku protein.", "Great! Half vegetables and fruit, a quarter grains, a quarter protein."))
	KitUtil.maybe_shot(self, "kampung_plate", 2.0)
