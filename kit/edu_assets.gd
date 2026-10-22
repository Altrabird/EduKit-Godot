## Lookup for every generated asset, driven by the manifests the generators write.
## A "ref" is "<subject or category>/<id>", e.g. "sains/planet_earth", "icons/star",
## "characters/aiman_happy", "ui/tile_blue", "backgrounds/classroom".
##   EduAssets.texture("sains/planet_earth")
##   EduAssets.name_of("sains/planet_earth")            # in GameState.lang
##   EduAssets.refs(func(e): return e.get("subject") == "matematik" and "shape" in e.tags)
##   EduAssets.model("sains/planet_saturn")              # PackedScene of the GLB
class_name EduAssets
extends RefCounted

const ART_MANIFEST := "res://assets/art/manifest.json"
const MODEL_MANIFEST := "res://assets/models/models_manifest.json"
const SUBJECTS := ["bahasa_melayu", "bahasa_inggeris", "matematik", "sains", "pendidikan_islam", "pendidikan_moral",
	"pjpk", "seni_visual", "muzik", "sejarah", "rbt"]
const SUBJECT_NAMES := {
	"bahasa_melayu": ["Bahasa Melayu", "Malay Language"], "bahasa_inggeris": ["Bahasa Inggeris", "English"],
	"matematik": ["Matematik", "Mathematics"], "sains": ["Sains", "Science"], "pendidikan_islam": ["Pendidikan Islam", "Islamic Education"],
	"pendidikan_moral": ["Pendidikan Moral", "Moral Education"], "pjpk": ["Pendidikan Jasmani & Kesihatan", "Physical & Health Education"],
	"seni_visual": ["Pendidikan Seni Visual", "Visual Arts"], "muzik": ["Pendidikan Muzik", "Music"], "sejarah": ["Sejarah", "History"],
	"rbt": ["Reka Bentuk & Teknologi", "Design & Technology"],
}

static var _art := {}
static var _models := {}


static func _load_json(path: String, optional := false) -> Array:
	if not FileAccess.file_exists(path):
		if not optional:  # games that ship without 3D drop the model manifest on purpose
			push_error("EduAssets: missing " + path)
		return []
	var data = JSON.parse_string(FileAccess.get_file_as_string(path))
	return data if data is Array else []


static func _ensure() -> void:
	if _art.is_empty():
		for e in _load_json(ART_MANIFEST):
			_art[e.get("subject", e.category) + "/" + e.id] = e
		for e in _load_json(MODEL_MANIFEST, true):
			_models[e.folder + "/" + e.id] = e


static func entry(ref: String) -> Dictionary:
	_ensure()
	return _art.get(ref, {})


static func has(ref: String) -> bool:
	_ensure()
	return _art.has(ref)


static func texture(ref: String) -> Texture2D:
	var e := entry(ref)
	if e.is_empty():
		push_warning("EduAssets: unknown ref " + ref)
		return null
	return load(e.path)


static func name_of(ref: String, lang := "") -> String:
	var e := entry(ref)
	if lang == "":
		lang = GameState.lang if Engine.get_main_loop() and Engine.get_main_loop().root.has_node("GameState") else "ms"
	return e.get("bm" if lang == "ms" else "en", ref)


## All refs matching a predicate on the manifest entry (or all refs when null).
static func refs(filter: Callable = Callable()) -> Array[String]:
	_ensure()
	var out: Array[String] = []
	for r in _art:
		if not filter.is_valid() or filter.call(_art[r]):
			out.append(r)
	out.sort()
	return out


static func by_subject(subject: String) -> Array[String]:
	return refs(func(e): return e.get("subject", "") == subject)


static func by_category(category: String) -> Array[String]:
	return refs(func(e): return e.category == category)


static func by_tag(tag: String) -> Array[String]:
	return refs(func(e): return tag in e.tags)


static func subject_name(subject: String, lang := "ms") -> String:
	return SUBJECT_NAMES.get(subject, [subject, subject])[0 if lang == "ms" else 1]


static func character(char_id: String, expression := "neutral") -> Texture2D:
	return texture("characters/%s_%s" % [char_id, expression])


static func model_refs() -> Array:
	_ensure()
	var k := _models.keys()
	k.sort()
	return k


static func model_entry(ref: String) -> Dictionary:
	_ensure()
	return _models.get(ref, {})


static func model(ref: String) -> PackedScene:
	var e := model_entry(ref)
	return load(e.path) if not e.is_empty() else null
