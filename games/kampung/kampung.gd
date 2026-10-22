## Kampungku Sihat: activity list and the facts each activity checks against.
class_name Kampung
extends RefCounted

const GAME := "kampung"
const MAP := "res://games/kampung/map.tscn"
## id, scene, name ms, name en, icon, map position, subject
const ACTIVITIES := [
	["plate", "res://games/kampung/plate.tscn", "Pinggan Sihat", "Healthy Plate", "pjpk/pinggan_sihat", Vector2(330, 640), "PJPK"],
	["recycle", "res://games/kampung/recycle.tscn", "Kitar Semula", "Recycling", "pendidikan_moral/tong_kitar_biru", Vector2(760, 820), "Moral"],
	["wash", "res://games/kampung/wash.tscn", "Basuh Tangan", "Hand Washing", "pjpk/basuh_tangan", Vector2(1180, 640), "PJPK"],
	["help", "res://games/kampung/help.tscn", "Bantu Jiran", "Help Your Neighbours", "pendidikan_moral/tolong_menolong", Vector2(560, 400), "Moral"],
	["pi", "res://games/kampung/pi.tscn", "Sudut Ibadah", "Worship Corner", "pendidikan_islam/masjid", Vector2(1480, 380), "Pendidikan Islam"],
	["art", "res://games/kampung/art.tscn", "Kompang & Warna", "Kompang & Colours", "muzik/kompang", Vector2(1560, 800), "Seni & Muzik"],
]

## Pinggan Sihat Malaysia: half fruit & vegetables, a quarter grains, a quarter protein; some foods to cut down.
const PLATE := {"pjpk/brokoli": "sayur", "pjpk/lobak_merah": "sayur", "pjpk/tomato": "sayur", "bahasa_melayu/epal": "sayur",
	"bahasa_melayu/pisang": "sayur", "pjpk/nasi": "bijirin", "bahasa_melayu/roti": "bijirin", "bahasa_inggeris/fish": "protein",
	"bahasa_melayu/telur": "protein", "pjpk/ayam_goreng": "protein", "pjpk/burger": "kurang", "pjpk/minuman_bergas": "kurang"}
const PLATE_ZONES := [["sayur", "Sayur & buah (½)", "Vegetables & fruit (½)", Color("7cb342")], ["bijirin", "Bijirin (¼)", "Grains (¼)", Color("ffe0a3")],
	["protein", "Protein (¼)", "Protein (¼)", Color("e57373")], ["kurang", "Kurangkan", "Eat less", Color("adb5bd")]]

## Malaysian recycling colours: blue paper, brown glass, orange plastic & cans; food waste goes in the rubbish bin.
const RECYCLE := {"icons/book": "biru", "seni_visual/kertas_warna": "biru", "pendidikan_moral/kad_terima_kasih": "biru",
	"sains/beaker": "coklat", "sains/flask_conical": "coklat", "sains/flask_round": "coklat",
	"pjpk/minuman_bergas": "oren", "seni_visual/gam": "oren", "icons/bag": "oren",
	"bahasa_melayu/pisang": "sampah", "bahasa_melayu/epal": "sampah"}
const BINS := [["biru", "pendidikan_moral/tong_kitar_biru", "Kertas", "Paper"], ["coklat", "pendidikan_moral/tong_kitar_coklat", "Kaca", "Glass"],
	["oren", "pendidikan_moral/tong_kitar_oren", "Plastik & tin", "Plastic & cans"], ["sampah", "pendidikan_moral/tong_sampah", "Sisa makanan", "Food waste"]]

## Captions where the picture's general name would mislead or give the answer away.
const CAPTIONS := {"icons/bag": ["Beg plastik", "Plastic bag"], "bahasa_melayu/pisang": ["Kulit pisang", "Banana peel"],
	"bahasa_melayu/epal": ["Sisa epal", "Apple core"], "pjpk/burger": ["Burger", "Burger"], "pjpk/minuman_bergas": ["Minuman bergas", "Fizzy drink"],
	"sains/beaker": ["Bekas kaca", "Glass jar"], "sains/flask_conical": ["Botol kaca", "Glass bottle"], "sains/flask_round": ["Botol kaca bulat", "Round glass bottle"],
	"seni_visual/gam": ["Gam (plastik)", "Glue stick (plastic)"], "icons/book": ["Buku lama", "Old book"]}

const WASH_STEPS := [["Basahkan tangan", "Wet your hands"], ["Sapu sabun", "Put on soap"], ["Gosok tapak tangan", "Rub your palms"],
	["Gosok celah jari & belakang tangan", "Scrub between fingers & backs of hands"], ["Bilas dengan air", "Rinse with water"], ["Lap dengan tuala bersih", "Dry with a clean towel"]]
const SCRUB_SECONDS := 20.0

## situation, choices (first is right), image
const HELP := [
	[["Kamu jumpa dompet di kantin.", "You find a wallet in the canteen."], [["Serahkan kepada guru", "Give it to a teacher"], ["Simpan sendiri", "Keep it"], ["Buang ke dalam tong", "Throw it in the bin"]], "pendidikan_moral/dompet"],
	[["Nenek jiran membawa barang yang berat.", "Your elderly neighbour is carrying heavy bags."], [["Tolong bawakan barangnya", "Help carry the bags"], ["Buat tidak tahu", "Pretend not to see"], ["Ketawa", "Laugh"]], "pendidikan_moral/tolong_menolong"],
	[["Rakan kamu terjatuh di padang.", "Your friend falls over on the field."], [["Bantu dia dan beritahu guru", "Help them and tell a teacher"], ["Tinggalkan dia", "Leave them"], ["Ambil gambar", "Take a photo"]], "pjpk/kit_pertolongan_cemas"],
	[["Kamu terpecahkan pasu bunga jiran.", "You break your neighbour's flower pot."], [["Mengaku dan minta maaf", "Own up and say sorry"], ["Sorokkan pasu itu", "Hide the pot"], ["Salahkan kucing", "Blame the cat"]], "sains/plant_flower"],
	[["Ada murid baharu dalam kelas.", "There is a new pupil in class."], [["Ajak dia berkawan", "Invite them to be friends"], ["Abaikan dia", "Ignore them"], ["Ejek dia", "Tease them"]], "pendidikan_moral/keluarga"],
	[["Lampu dan kipas masih hidup selepas kelas.", "The lights and fan are still on after class."], [["Tutup suis", "Switch them off"], ["Biarkan sahaja", "Leave them on"], ["Main suis", "Play with the switch"]], "rbt/suis"],
]

## Rukun wudhu in order (niat is made while washing the face).
const WUDHU := [["Niat dan basuh muka", "Intention and wash the face"], ["Basuh tangan hingga siku", "Wash the arms up to the elbows"],
	["Sapu sebahagian kepala", "Wipe part of the head"], ["Basuh kaki hingga buku lali", "Wash the feet up to the ankles"]]
const RAYA_YES := ["bahasa_melayu/ketupat", "pendidikan_islam/pelita", "pendidikan_islam/sampul_duit_raya"]
const RAYA_NO := ["pjpk/bola_sepak", "muzik/gitar", "bahasa_inggeris/umbrella"]

## Kompang patterns: D = dum (centre), P = pak (edge)
const RHYTHMS := ["DPDP", "DDPP", "DPPD", "PDPDD"]
## target -> the two primaries that make it
const MIXES := {"hijau": ["biru", "kuning"], "oren": ["merah", "kuning"], "ungu": ["merah", "biru"]}
const COLOURS := {"merah": Color("ef476f"), "kuning": Color("ffd166"), "biru": Color("3a86ff"), "hijau": Color("6bcb77"), "oren": Color("ff9f1c"), "ungu": Color("9b5de5")}
const COLOUR_EN := {"merah": "red", "kuning": "yellow", "biru": "blue", "hijau": "green", "oren": "orange", "ungu": "purple"}


static func name_of(i: int) -> String:
	return ACTIVITIES[i][2] if GameState.lang == "ms" else ACTIVITIES[i][3]


static func done_count() -> int:
	var n := 0
	for i in ACTIVITIES.size():
		n += 1 if GameState.stars_for(GAME, i + 1) > 0 else 0
	return n


## Village colour: grey at the start, full colour when every activity has a star.
static func saturation() -> float:
	return 0.12 + 0.88 * done_count() / float(ACTIVITIES.size())


static func mix_ok(target: String, a: String, b: String) -> bool:
	var want: Array = MIXES[target]
	return a != b and a in want and b in want


static func stars(mistakes: int) -> int:
	return 3 if mistakes == 0 else (2 if mistakes <= 2 else 1)
