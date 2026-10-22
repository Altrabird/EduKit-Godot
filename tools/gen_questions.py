"""Sample question banks per KSSR subject -> data/questions/<subject>.json.
Authoring rule: the FIRST choice is the correct one; Questions.gd shuffles at runtime.
Images are asset refs ("<subject or category>/<id>") from assets/art/manifest.json.
These are starter banks for demos; teachers can extend the JSON directly."""
import json, os

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(ROOT, "data", "questions")

# (year, q_ms, q_en, [choices_ms], [choices_en], image_ref or "")
BANK = {
    "bahasa_melayu": [
        (1, "Apakah nama buah ini?", "What is this fruit called?", ["Durian", "Rambutan", "Manggis", "Nanas"], ["Durian", "Rambutan", "Mangosteen", "Pineapple"], "bahasa_melayu/durian"),
        (1, "Suku kata pertama bagi perkataan 'buku' ialah...", "The first syllable of 'buku' is...", ["bu", "ku", "ba", "bi"], ["bu", "ku", "ba", "bi"], ""),
        (1, "Pilih huruf vokal.", "Choose the vowel.", ["a", "b", "k", "m"], ["a", "b", "k", "m"], ""),
        (2, "Haiwan ini dikenali sebagai...", "This animal is known as...", ["Sang Kancil", "Harimau", "Buaya", "Gajah"], ["Mouse deer", "Tiger", "Crocodile", "Elephant"], "bahasa_melayu/sang_kancil"),
        (2, "Lawan bagi perkataan 'tinggi' ialah...", "The opposite of 'tinggi' (tall) is...", ["rendah", "besar", "panjang", "cantik"], ["rendah (short)", "besar (big)", "panjang (long)", "cantik (pretty)"], ""),
        (3, "Pilih ayat yang betul.", "Choose the correct sentence.", ["Adik makan nasi.", "Nasi adik makan.", "Makan nasi adik.", "Adik nasi makan."], ["Adik makan nasi.", "Nasi adik makan.", "Makan nasi adik.", "Adik nasi makan."], ""),
        (3, "Permainan tradisional ini ialah...", "This traditional game is...", ["Congkak", "Gasing", "Wau", "Batu seremban"], ["Congkak", "Spinning top", "Kite", "Five stones"], "bahasa_melayu/congkak"),
        (4, "Peribahasa 'bagai aur dengan tebing' bermaksud...", "The proverb 'bagai aur dengan tebing' means...", ["saling membantu", "bergaduh", "malas", "sombong"], ["helping each other", "quarrelling", "lazy", "arrogant"], ""),
        (5, "Kata sendi nama yang sesuai: Ayah pergi ___ pejabat.", "Correct preposition: Ayah pergi ___ pejabat.", ["ke", "di", "dari", "pada"], ["ke", "di", "dari", "pada"], ""),
    ],
    "bahasa_inggeris": [
        (1, "What animal is this?", "What animal is this?", ["Kucing (cat)", "Anjing (dog)", "Arnab (rabbit)", "Lembu (cow)"], ["Cat", "Dog", "Rabbit", "Cow"], "bahasa_inggeris/cat"),
        (1, "Which word starts with 'b'?", "Which word starts with 'b'?", ["bus", "car", "ship", "train"], ["bus", "car", "ship", "train"], ""),
        (2, "This is a ___.", "This is a ___.", ["bicycle", "motorcycle", "helicopter", "boat"], ["bicycle", "motorcycle", "helicopter", "boat"], "bahasa_inggeris/bicycle"),
        (2, "Choose the plural of 'apple'.", "Choose the plural of 'apple'.", ["apples", "appleses", "appls", "apple"], ["apples", "appleses", "appls", "apple"], ""),
        (3, "I ___ a student.", "I ___ a student.", ["am", "is", "are", "be"], ["am", "is", "are", "be"], ""),
        (3, "Which one can fly?", "Which one can fly?", ["bird", "fish", "snail", "turtle"], ["bird", "fish", "snail", "turtle"], ""),
        (4, "Yesterday, she ___ to school.", "Yesterday, she ___ to school.", ["walked", "walks", "walking", "walk"], ["walked", "walks", "walking", "walk"], ""),
        (5, "The opposite of 'brave' is...", "The opposite of 'brave' is...", ["afraid", "strong", "happy", "quick"], ["afraid", "strong", "happy", "quick"], ""),
    ],
    "matematik": [
        (1, "Berapakah 3 + 4?", "What is 3 + 4?", ["7", "6", "8", "5"], ["7", "6", "8", "5"], ""),
        (1, "Bentuk ini ialah...", "This shape is a...", ["Segi tiga", "Bulatan", "Segi empat sama", "Pentagon"], ["Triangle", "Circle", "Square", "Pentagon"], "matematik/shape_triangle"),
        (2, "Pepejal ini ialah...", "This solid is a...", ["Silinder", "Kon", "Kubus", "Sfera"], ["Cylinder", "Cone", "Cube", "Sphere"], "matematik/solid_cylinder"),
        (2, "Berapakah 50 sen + 50 sen?", "What is 50 sen + 50 sen?", ["RM1", "RM10", "100 sen + RM1", "50 sen"], ["RM1", "RM10", "100 sen + RM1", "50 sen"], ""),
        (3, "Berapakah 6 x 7?", "What is 6 x 7?", ["42", "36", "48", "13"], ["42", "36", "48", "13"], ""),
        (3, "1 jam = ___ minit", "1 hour = ___ minutes", ["60", "100", "30", "24"], ["60", "100", "30", "24"], "matematik/clock_face"),
        (4, "Pecahan setara bagi 1/2 ialah...", "An equivalent fraction of 1/2 is...", ["2/4", "1/4", "2/3", "3/4"], ["2/4", "1/4", "2/3", "3/4"], ""),
        (5, "0.5 = ___ %", "0.5 = ___ %", ["50", "5", "0.5", "500"], ["50", "5", "0.5", "500"], "matematik/op_percent"),
        (6, "Purata bagi 4, 6 dan 8 ialah...", "The average of 4, 6 and 8 is...", ["6", "18", "8", "5"], ["6", "18", "8", "5"], "matematik/chart_bar"),
    ],
    "sains": [
        (1, "Planet tempat kita tinggal ialah...", "The planet we live on is...", ["Bumi", "Marikh", "Musytari", "Zuhal"], ["Earth", "Mars", "Jupiter", "Saturn"], "sains/planet_earth"),
        (1, "Deria apakah yang digunakan untuk melihat?", "Which sense do we use to see?", ["Mata", "Telinga", "Hidung", "Lidah"], ["Eyes", "Ears", "Nose", "Tongue"], ""),
        (2, "Peringkat selepas telur dalam kitaran hidup katak ialah...", "After the egg, the frog's next life stage is...", ["Berudu", "Anak katak", "Katak dewasa", "Rama-rama"], ["Tadpole", "Froglet", "Adult frog", "Butterfly"], "sains/frog_eggs"),
        (2, "Tumbuhan memerlukan ___ untuk membuat makanan.", "Plants need ___ to make food.", ["cahaya matahari", "gula", "garam", "plastik"], ["sunlight", "sugar", "salt", "plastic"], "sains/plant_young"),
        (3, "Magnet menarik objek yang diperbuat daripada...", "A magnet attracts objects made of...", ["besi", "kayu", "plastik", "kertas"], ["iron", "wood", "plastic", "paper"], "sains/magnet"),
        (3, "Alat ini digunakan untuk mengukur suhu.", "This tool measures temperature.", ["Termometer", "Pembaris", "Penimbang", "Bikar"], ["Thermometer", "Ruler", "Scale", "Beaker"], "sains/thermometer"),
        (4, "Planet terbesar dalam Sistem Suria ialah...", "The largest planet in the Solar System is...", ["Musytari", "Bumi", "Zuhal", "Utarid"], ["Jupiter", "Earth", "Saturn", "Mercury"], "sains/planet_jupiter"),
        (5, "Air mendidih pada suhu...", "Water boils at...", ["100 °C", "0 °C", "50 °C", "37 °C"], ["100 °C", "0 °C", "50 °C", "37 °C"], "sains/beaker"),
        (6, "Bulan mengelilingi Bumi dalam masa kira-kira...", "The Moon orbits the Earth in about...", ["29.5 hari", "24 jam", "365 hari", "7 hari"], ["29.5 days", "24 hours", "365 days", "7 days"], "sains/moon"),
    ],
    "pendidikan_islam": [
        (1, "Bilangan solat fardu sehari semalam ialah...", "How many obligatory prayers are there in a day?", ["5", "3", "4", "6"], ["5", "3", "4", "6"], "pendidikan_islam/sejadah"),
        (1, "Kitab suci umat Islam ialah...", "The holy book of Muslims is...", ["Al-Quran", "Zabur", "Taurat", "Injil"], ["The Quran", "Zabur", "Taurat", "Injil"], "pendidikan_islam/al_quran_rehal"),
        (2, "Sebelum solat, kita perlu mengambil...", "Before praying, we must perform...", ["wuduk", "makan", "tidur", "mandi sahaja"], ["ablution (wuduk)", "a meal", "a nap", "only a bath"], "pendidikan_islam/paip_air_wuduk"),
        (2, "Umat Islam berpuasa pada bulan...", "Muslims fast in the month of...", ["Ramadan", "Syawal", "Rejab", "Muharam"], ["Ramadan", "Syawal", "Rejab", "Muharam"], "pendidikan_islam/tanglung"),
        (3, "Kiblat umat Islam ialah ke arah...", "The qibla faces towards the...", ["Kaabah", "Masjid", "Matahari", "Laut"], ["Kaaba", "Mosque", "Sun", "Sea"], "pendidikan_islam/kaabah"),
        (4, "Hari raya selepas bulan Ramadan ialah...", "The festival after Ramadan is...", ["Hari Raya Aidilfitri", "Hari Raya Aidiladha", "Maulidur Rasul", "Awal Muharam"], ["Eid al-Fitr", "Eid al-Adha", "Prophet's Birthday", "Islamic New Year"], "bahasa_melayu/ketupat"),
    ],
    "pendidikan_moral": [
        (1, "Apakah yang patut kamu lakukan apabila menjumpai dompet orang lain?", "What should you do if you find someone's wallet?", ["Serahkan kepada guru", "Simpan sendiri", "Buang", "Abaikan"], ["Give it to a teacher", "Keep it", "Throw it away", "Ignore it"], "pendidikan_moral/dompet"),
        (1, "Tong kitar semula berwarna biru untuk...", "The blue recycling bin is for...", ["kertas", "kaca", "plastik", "sisa makanan"], ["paper", "glass", "plastic", "food waste"], "pendidikan_moral/tong_kitar_biru"),
        (2, "Tong kitar semula berwarna coklat untuk...", "The brown recycling bin is for...", ["kaca", "kertas", "plastik", "tin"], ["glass", "paper", "plastic", "cans"], "pendidikan_moral/tong_kitar_coklat"),
        (2, "Apabila lampu isyarat merah, kita mesti...", "When the traffic light is red, we must...", ["berhenti", "berlari", "melintas", "menunggang"], ["stop", "run", "cross", "ride"], "pendidikan_moral/lampu_isyarat"),
        (3, "Menolong rakan yang jatuh menunjukkan nilai...", "Helping a friend who fell shows...", ["baik hati", "sombong", "malas", "boros"], ["kindness", "arrogance", "laziness", "wastefulness"], "pendidikan_moral/tolong_menolong"),
        (4, "Menyimpan wang di dalam tabung menunjukkan sikap...", "Saving money in a piggy bank shows...", ["berjimat cermat", "boros", "tamak", "pemarah"], ["thrift", "wastefulness", "greed", "anger"], "pendidikan_moral/tabung"),
    ],
    "pjpk": [
        (1, "Mengikut Pinggan Sihat Malaysia, separuh pinggan ialah...", "On the Malaysian Healthy Plate, half the plate is...", ["sayur dan buah", "nasi", "ayam", "gula-gula"], ["vegetables and fruit", "rice", "chicken", "sweets"], "pjpk/pinggan_sihat"),
        (1, "Kita perlu mencuci tangan dengan...", "We should wash our hands with...", ["sabun dan air", "pasir", "minyak", "susu"], ["soap and water", "sand", "oil", "milk"], "pjpk/basuh_tangan"),
        (2, "Kita menggosok gigi sekurang-kurangnya ___ sehari.", "We brush our teeth at least ___ a day.", ["2 kali", "sekali seminggu", "5 kali", "tidak perlu"], ["twice", "once a week", "5 times", "never"], "pjpk/berus_gigi"),
        (3, "Bola ini digunakan dalam permainan...", "This ball is used in...", ["sepak takraw", "bola jaring", "bola keranjang", "ping pong"], ["sepak takraw", "netball", "basketball", "table tennis"], "pjpk/bola_takraw"),
        (4, "Makanan yang perlu dikurangkan ialah...", "Food we should eat less of is...", ["minuman bergas", "brokoli", "lobak merah", "tomato"], ["fizzy drinks", "broccoli", "carrots", "tomatoes"], "pjpk/minuman_bergas"),
        (5, "Sebelum bersenam, kita perlu melakukan...", "Before exercising, we should...", ["memanaskan badan", "tidur", "makan banyak", "minum air bergas"], ["warm up", "sleep", "eat a lot", "drink soda"], "pjpk/kon"),
    ],
    "seni_visual": [
        (1, "Warna primer ialah merah, biru dan...", "The primary colours are red, blue and...", ["kuning", "hijau", "ungu", "oren"], ["yellow", "green", "purple", "orange"], "seni_visual/tiub_cat"),
        (2, "Biru + kuning menghasilkan warna...", "Blue + yellow makes...", ["hijau", "oren", "ungu", "coklat"], ["green", "orange", "purple", "brown"], "seni_visual/roda_warna"),
        (3, "Merah + biru menghasilkan warna...", "Red + blue makes...", ["ungu", "hijau", "oren", "kuning"], ["purple", "green", "orange", "yellow"], "seni_visual/roda_warna"),
        (4, "Alat ini digunakan untuk membuat batik.", "This tool is used to make batik.", ["Canting", "Berus", "Gunting", "Pensel"], ["Canting", "Brush", "Scissors", "Pencil"], "seni_visual/canting"),
        (5, "Seni melipat kertas dikenali sebagai...", "The art of folding paper is called...", ["origami", "batik", "arca", "kolaj"], ["origami", "batik", "sculpture", "collage"], "seni_visual/origami"),
    ],
    "muzik": [
        (1, "Alat muzik ini ialah...", "This instrument is a...", ["Kompang", "Gitar", "Piano", "Rekoder"], ["Kompang", "Guitar", "Piano", "Recorder"], "muzik/kompang"),
        (2, "Alat muzik tradisional Sarawak ini ialah...", "This traditional Sarawak instrument is the...", ["Sape", "Gitar", "Biola", "Seruling"], ["Sape", "Guitar", "Violin", "Flute"], "muzik/sape"),
        (3, "Not krocet bernilai ___ detik.", "A crotchet is worth ___ beat(s).", ["1", "2", "4", "1/2"], ["1", "2", "4", "1/2"], "muzik/not_krocet"),
        (4, "Not minim bernilai ___ detik.", "A minim is worth ___ beats.", ["2", "1", "4", "3"], ["2", "1", "4", "3"], "muzik/not_minim"),
        (5, "Not semibrif bernilai ___ detik.", "A semibreve is worth ___ beats.", ["4", "2", "1", "3"], ["4", "2", "1", "3"], "muzik/not_semibreve"),
    ],
    "sejarah": [
        (4, "Bendera Malaysia dikenali sebagai...", "Malaysia's flag is called...", ["Jalur Gemilang", "Sang Saka", "Union Jack", "Merah Putih"], ["Jalur Gemilang", "Sang Saka", "Union Jack", "Merah Putih"], "sejarah/jalur_gemilang"),
        (4, "Bunga kebangsaan Malaysia ialah...", "Malaysia's national flower is the...", ["Bunga raya", "Orkid", "Melur", "Mawar"], ["Hibiscus", "Orchid", "Jasmine", "Rose"], "sejarah/bunga_raya"),
        (4, "Jalur Gemilang mempunyai ___ jalur merah dan putih.", "The Jalur Gemilang has ___ red and white stripes.", ["14", "13", "12", "10"], ["14", "13", "12", "10"], "sejarah/jalur_gemilang"),
        (5, "Malaysia (Persekutuan Tanah Melayu) mencapai kemerdekaan pada...", "Malaya gained independence on...", ["31 Ogos 1957", "16 September 1963", "1 Januari 1957", "31 Ogos 1963"], ["31 August 1957", "16 September 1963", "1 January 1957", "31 August 1963"], ""),
        (5, "Pada 16 September 1963, terbentuknya...", "On 16 September 1963, what was formed?", ["Malaysia", "Kesultanan Melayu Melaka", "Persekutuan Tanah Melayu", "Negeri-negeri Selat"], ["Malaysia", "The Melaka Sultanate", "The Federation of Malaya", "The Straits Settlements"], ""),
        (6, "Bijih timah didulang menggunakan alat ini.", "Tin ore was panned with this tool.", ["Dulang", "Cangkul", "Canting", "Kendi"], ["Dulang (tray)", "Hoe", "Canting", "Water jug"], "sejarah/dulang_bijih_timah"),
    ],
    "rbt": [
        (4, "Alat ini digunakan untuk memasukkan skru.", "This tool is used to drive screws.", ["Pemutar skru", "Tukul", "Gergaji", "Playar"], ["Screwdriver", "Hammer", "Saw", "Pliers"], "rbt/pemutar_skru"),
        (4, "Komponen yang menyalakan cahaya dalam litar ialah...", "The component that gives light in a circuit is the...", ["LED", "Perintang", "Suis", "Motor"], ["LED", "Resistor", "Switch", "Motor"], "rbt/led"),
        (5, "Komponen yang menghadkan arus elektrik ialah...", "The component that limits electric current is the...", ["Perintang", "LED", "Bateri", "Motor"], ["Resistor", "LED", "Battery", "Motor"], "rbt/perintang"),
        (5, "Alat ini digunakan untuk menyiram tanaman.", "This tool is used to water plants.", ["Penyiram", "Cangkul", "Penyodok", "Gunting"], ["Watering can", "Hoe", "Spade", "Scissors"], "rbt/penyiram"),
        (6, "Kod blok 'ulang 10 kali' ialah contoh...", "A 'repeat 10 times' block is an example of...", ["gelung (loop)", "pemboleh ubah", "acara", "input"], ["a loop", "a variable", "an event", "an input"], "rbt/kod_blok"),
    ],
}


def main():
    os.makedirs(OUT, exist_ok=True)
    manifest = json.load(open(os.path.join(ROOT, "assets", "art", "manifest.json"), encoding="utf-8"))
    refs = {(m.get("subject") or m["category"]) + "/" + m["id"] for m in manifest}
    total = 0
    for subject, rows in BANK.items():
        out = []
        for year, qms, qen, cms, cen, img in rows:
            assert len(cms) == len(cen) == 4, (subject, qms)
            assert len(set(cms)) == 4 and len(set(cen)) == 4, f"duplicate choices: {subject} {qms}"
            if img and img not in refs:
                img = ""  # unknown picture: keep the question, drop the image
            out.append({"year": year, "q": {"ms": qms, "en": qen}, "choices": {"ms": cms, "en": cen}, "answer": 0, "image": img})
        with open(os.path.join(OUT, subject + ".json"), "w", encoding="utf-8") as f:
            json.dump(out, f, ensure_ascii=False, indent=1)
        total += len(out)
    print(total, "questions in", len(BANK), "subjects")


if __name__ == "__main__":
    main()
