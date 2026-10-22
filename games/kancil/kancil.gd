## Kancil & Suku Kata: session state, word data and the level generator.
## A level = 2 words. Each word's parts (syllables in BM, letters in English) lie on the
## main path; decoys sit on optional planks; a word gate blocks the way until the
## parts are arranged. The generator only emits jumpable terrain (see check()).
class_name Kancil
extends RefCounted

const SCENES := {"menu": "res://games/kancil/menu.tscn", "level": "res://games/kancil/level.tscn"}
const ROWS := 12          ## map height in tiles; ground surface row = ROWS - 1 - height
const MAX_PIT := 3        ## Player2D jumps ~6 tiles far and ~3 high; keep a margin
const MAX_STEP := 2
const WORDS_PER_LEVEL := 2

static var mode := "ms"   ## "ms" = suku kata, "en" = English letters
static var level := 1
static var seen_intro := false
static var _words := {}


static func words(m := "") -> Array:
	if _words.is_empty():
		_words = JSON.parse_string(FileAccess.get_file_as_string("res://data/kancil_words.json"))
	return _words[m if m != "" else mode]


static func level_count(m := "") -> int:
	return ceili(words(m).size() / float(WORDS_PER_LEVEL))


static func game_id() -> String:
	return "kancil_" + mode


static func level_words(lv: int, m := "") -> Array:
	var w := words(m)
	var a := (lv - 1) * WORDS_PER_LEVEL
	return w.slice(a, mini(a + WORDS_PER_LEVEL, w.size()))


## Wrong parts mixed into the spelling tray and onto side planks.
static func decoys(word: Dictionary, n: int, m := "") -> Array:
	var pool: Array = []
	if (m if m != "" else mode) == "ms":
		for c in "b d g k l m n p r s t".split(" "):
			for v in "aiueo":
				pool.append(c + v)
	else:
		pool = Array("abcdefghijklmnopqrstuvwxyz".split(""))
	pool = pool.filter(func(p): return not p in word.parts)
	pool.shuffle()
	return pool.slice(0, n)


## Builds a level description:
## heights[x]: ground height in tiles (0 = pit, -1 = water with crocodiles),
## items: [{type, x, y(tile row), ...}] for parts, decoys, planks, spikes, tigers, crocs, gates, flag.
static func build(lv: int, m := "") -> Dictionary:
	var rng := RandomNumberGenerator.new()
	rng.seed = hash("%s_%d" % [m if m != "" else mode, lv])
	var diff := clampi(lv, 1, 11)
	var heights: Array[int] = []
	var items: Array = []
	var h := 3
	var flat := func(n: int) -> void:
		for i in n:
			heights.append(h)
	var obstacle := func() -> void:
		var r := rng.randf()
		if r < 0.25 + diff * 0.03:
			for i in rng.randi_range(2, mini(MAX_PIT, 1 + diff / 3)):
				heights.append(0)
		elif r < 0.45:
			h = clampi(h + rng.randi_range(-MAX_STEP, MAX_STEP), 2, 6)
		elif r < 0.6 and diff >= 3:
			flat.call(2)
			items.append({"type": "spike", "x": heights.size(), "h": h})
			heights.append(h)
			flat.call(2)
		elif r < 0.75 and diff >= 4:
			# crocodile river (the Sang Kancil tale): low banks so you can climb out from a croc's back
			h = mini(h, 1 + MAX_STEP)
			flat.call(2)
			var w := rng.randi_range(4, 6)
			for i in w:
				heights.append(-1)
				if i % 2 == 1:
					items.append({"type": "croc", "x": heights.size() - 1, "h": 1})
		elif r < 0.9 and diff >= 2:
			items.append({"type": "tiger", "x": heights.size() + 1, "w": 5, "h": h})
			flat.call(7)
		flat.call(rng.randi_range(2, 3))
	flat.call(5)
	items.append({"type": "start", "x": 2, "h": h})
	for wi in level_words(lv, m).size():
		var word: Dictionary = level_words(lv, m)[wi]
		for p in word.parts:
			obstacle.call()
			flat.call(1)
			items.append({"type": "part", "x": heights.size(), "h": h, "text": p, "word": wi})
			flat.call(2)
		# one decoy on a plank (optional route)
		flat.call(1)
		items.append({"type": "plank", "x": heights.size(), "w": 3, "h": h + 3})
		items.append({"type": "decoy", "x": heights.size() + 1, "h": h + 3, "text": decoys(word, 1, m)[0], "word": wi})
		flat.call(5)
		items.append({"type": "gate", "x": heights.size(), "h": h, "word": wi})
		flat.call(4)
	flat.call(3)
	items.append({"type": "flag", "x": heights.size(), "h": h})
	flat.call(5)
	return {"heights": heights, "items": items, "width": heights.size()}


## Structural guarantee used by tests: no pit wider than MAX_PIT, no step taller than MAX_STEP,
## water stretches always have a crocodile within reach, every part sits on solid ground.
static func check(level_data: Dictionary) -> String:
	var hs: Array = level_data.heights
	var run := 0
	var last: int = hs[0]
	for x in hs.size():
		var v: int = hs[x]
		if v == 0:
			run += 1
			if run > MAX_PIT:
				return "pit too wide at %d" % x
		else:
			run = 0
		if v > 0 and last > 0 and v - last > MAX_STEP:  # only climbing is limited; drops are fine
			return "step too tall at %d" % x
		if v == -1 and x > 0 and hs[x - 1] > 1 + MAX_STEP:
			return "bank too high above the river at %d" % x
		if v > 1 + MAX_STEP and x > 0 and hs[x - 1] == -1:
			return "bank too high to climb out of the river at %d" % x
		if v > 0:
			last = v
	var crocs: Array = level_data.items.filter(func(i): return i.type == "croc").map(func(i): return i.x)
	var water_run := 0
	for x in hs.size():
		if hs[x] == -1:
			water_run = 0 if x in crocs else water_run + 1
			if water_run > 2:
				return "no crocodile to stand on near %d" % x
		else:
			water_run = 0
	for i in level_data.items:
		if i.type in ["part", "gate", "flag", "start"] and hs[i.x] <= 0:
			return "%s over a hole at %d" % [i.type, i.x]
	return ""
