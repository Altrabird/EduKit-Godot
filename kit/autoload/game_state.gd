## Player progress + settings, saved as JSON in user://. One profile per device,
## which fits shared school PCs; games namespace their data by game id.
##   GameState.lang = "en"
##   GameState.record_level("matematik_tambah", 3, 2)   # level 3 earned 2 stars
##   GameState.stars_for("matematik_tambah", 3)
extends Node

signal lang_changed(lang: String)
signal progress_changed

const SAVE_PATH := "user://edukit_save.json"
const VERSION := 1

var lang := "ms":
	set(v):
		if v != lang and v in ["ms", "en"]:
			lang = v
			lang_changed.emit(v)
			save()
var player_name := ""
var volumes := {"Master": 1.0, "Music": 0.6, "SFX": 0.9, "Voice": 1.0}
var progress := {}  # game_id -> {level(str) -> {"stars": int, "best": int}}
var coins := 0


func _ready() -> void:
	_font_fallbacks()
	load_save()
	for bus in volumes:
		Audio.set_volume(bus, volumes[bus])


## Browsers have no system-font fallback, so ★ ☆ ▶ ✓ ✗ → would render as boxes on the web.
## Fonts are cached resources, so setting fallbacks once here reaches the theme and every preload.
static func _font_fallbacks() -> void:
	var symbols: FontFile = load("res://assets/fonts/NotoSansSymbols2-Regular.ttf")
	var andika: FontFile = load("res://assets/fonts/Andika-Regular.ttf")
	andika.fallbacks = [symbols]
	(load("res://assets/fonts/Andika-Bold.ttf") as FontFile).fallbacks = [symbols]
	(load("res://assets/fonts/Fredoka.ttf") as FontFile).fallbacks = [andika, symbols]


## Keeps the best result per level. Returns true if it is a new best.
func record_level(game_id: String, level: int, stars: int, score := 0) -> bool:
	var g: Dictionary = progress.get_or_add(game_id, {})
	var prev: Dictionary = g.get(str(level), {"stars": 0, "best": 0})
	var improved: bool = stars > prev.stars or score > prev.best
	g[str(level)] = {"stars": maxi(stars, prev.stars), "best": maxi(score, prev.best)}
	save()
	progress_changed.emit()
	return improved


func stars_for(game_id: String, level: int) -> int:
	return progress.get(game_id, {}).get(str(level), {}).get("stars", 0)


func total_stars(game_id: String) -> int:
	var n := 0
	for lv in progress.get(game_id, {}).values():
		n += lv.stars
	return n


## A level is open if it is the first one or the previous one has at least one star.
func is_unlocked(game_id: String, level: int) -> bool:
	return level <= 1 or stars_for(game_id, level - 1) > 0


func set_volume(bus: String, v: float) -> void:
	volumes[bus] = clampf(v, 0.0, 1.0)
	Audio.set_volume(bus, volumes[bus])
	save()


## Localised pick: tr2("Betul", "Correct").
func tr2(ms: String, en: String) -> String:
	return ms if lang == "ms" else en


func save() -> void:
	var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if f == null:
		push_warning("GameState: cannot write save (%d)" % FileAccess.get_open_error())
		return
	f.store_string(JSON.stringify({"v": VERSION, "lang": lang, "name": player_name, "volumes": volumes, "progress": progress, "coins": coins}))


func load_save() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var data = JSON.parse_string(FileAccess.get_file_as_string(SAVE_PATH))
	if typeof(data) != TYPE_DICTIONARY:
		# shortcut: a corrupt save is ignored (kept on disk), upgrade to a backup copy if this ever bites
		push_warning("GameState: save unreadable, starting fresh")
		return
	lang = data.get("lang", "ms")
	player_name = data.get("name", "")
	volumes.merge(data.get("volumes", {}), true)
	progress = data.get("progress", {})
	coins = int(data.get("coins", 0))


func reset_all() -> void:
	progress = {}
	coins = 0
	save()
	progress_changed.emit()
