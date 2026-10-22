## Makmal Sains Ajaib 3D: mission list + pure rules (testable without scenes).
class_name Makmal
extends RefCounted

const GAME := "makmal"
const HUB := "res://games/makmal/hub.tscn"
## id, scene, name ms, name en, bench prop (3D), Tahun hint
const MISSIONS := [
	["solar", "res://games/makmal/solar.tscn", "Sistem Suria", "Solar System", "sains/planet_saturn", "Tahun 4–6"],
	["lifecycle", "res://games/makmal/lifecycle.tscn", "Kitaran Hidup", "Life Cycles", "classroom/book_stack", "Tahun 2–3"],
	["magnet", "res://games/makmal/magnet.tscn", "Magnet", "Magnets", "sains/magnet", "Tahun 3"],
	["circuit", "res://games/makmal/circuit.tscn", "Litar Ringkas", "Simple Circuits", "rbt/robot_kit", "Tahun 4–6 (Sains/RBT)"],
	["plant", "res://games/makmal/plant.tscn", "Keperluan Tumbuhan", "What Plants Need", "sains/potted_plant", "Tahun 1–2"],
]
const PLANETS := ["mercury", "venus", "earth", "mars", "jupiter", "saturn", "uranus", "neptune"]
const LIFECYCLES := {
	"katak": [["sains/frog_eggs", "sains/tadpole", "sains/froglet", "bahasa_inggeris/frog"], "Katak", "Frog"],
	"rama_rama": [["bahasa_inggeris/butterfly_eggs", "bahasa_inggeris/caterpillar", "bahasa_inggeris/chrysalis", "bahasa_inggeris/butterfly"], "Rama-rama", "Butterfly"],
	"tumbuhan": [["sains/plant_seed", "sains/plant_sprout", "sains/plant_young", "sains/plant_flower"], "Tumbuhan", "Plant"],
}
## ref, attracted by a magnet?
const MAGNET_OBJECTS := [["rbt/sepana", true], ["rbt/playar", true], ["seni_visual/gunting", true], ["rbt/jarum_benang", true],
	["icons/key", true], ["rbt/tukul", true], ["icons/pencil", false], ["matematik/ruler_long", false], ["icons/book", false],
	["bahasa_inggeris/ball", false], ["bahasa_melayu/epal", false], ["seni_visual/kertas_warna", false], ["sains/leaf", false], ["seni_visual/gam", false]]
## component ref -> role in a circuit
const PARTS := {"sains/battery": "source", "rbt/suis": "switch", "sains/light_bulb": "bulb", "rbt/led": "led", "rbt/perintang": "resistor",
	"rbt/motor": "motor", "icons/pencil": "insulator", "matematik/ruler_long": "insulator"}
## mission level: slots needed + what must be there
const CIRCUITS := [
	{"slots": 3, "need": ["source", "switch", "bulb"], "goal": ["Nyalakan mentol", "Light the bulb"]},
	{"slots": 3, "need": ["source", "switch", "motor"], "goal": ["Gerakkan motor", "Run the motor"]},
	{"slots": 4, "need": ["source", "switch", "led", "resistor"], "goal": ["Nyalakan LED (perlukan perintang)", "Light the LED (it needs a resistor)"]},
]

static var mission := 0


static func name_of(i: int) -> String:
	return MISSIONS[i][2] if GameState.lang == "ms" else MISSIONS[i][3]


## Ring index for a click at distance `d` from the Sun (rings at 1.6 + i * 0.75 m).
static func ring_at(d: float) -> int:
	var i := int(round((d - 1.6) / 0.75))
	return i if i >= 0 and i < PLANETS.size() and absf(d - ring_radius(i)) < 0.36 else -1


static func ring_radius(i: int) -> float:
	return 1.6 + i * 0.75


## Evaluates a circuit: returns "" if it works, else a reason key.
static func circuit_result(level: int, placed: Array, switch_on: bool) -> String:
	var spec: Dictionary = CIRCUITS[level]
	var roles := placed.map(func(r): return PARTS.get(r, "?"))
	if roles.size() < spec.slots or "" in placed:
		return "open"            # gap in the loop
	if "insulator" in roles:
		return "insulator"
	for need in spec.need:
		if not need in roles:
			return "missing_" + need
	if "led" in roles and not "resistor" in roles:
		return "missing_resistor"
	if not switch_on:
		return "switch_off"
	return ""


## Plant experiment: which conditions let a plant grow well?
static func plant_grows(water: bool, light: bool) -> String:
	if water and light:
		return "healthy"
	if not water:
		return "wilted"
	return "pale"


static func stars(mistakes: int) -> int:
	return 3 if mistakes == 0 else (2 if mistakes <= 2 else 1)
