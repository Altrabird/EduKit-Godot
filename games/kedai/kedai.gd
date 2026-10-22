## Kedai Runcit Pak Ali: products, prices by Tahun, customer generation, money maths.
## Money is always handled in sen (int) to avoid float rounding.
class_name Kedai
extends RefCounted

const SCENES := {"menu": "res://games/kedai/menu.tscn", "shop": "res://games/kedai/shop.tscn"}
const DAYS := 10
## ref, base price (sen), category (unlocked by upgrades)
const PRODUCTS := [
	["bahasa_melayu/epal", 150, "buah"], ["bahasa_melayu/oren", 120, "buah"], ["bahasa_melayu/pisang", 200, "buah"],
	["bahasa_melayu/mangga", 250, "buah"], ["bahasa_melayu/rambutan", 300, "buah"], ["bahasa_melayu/manggis", 400, "buah"],
	["bahasa_melayu/nanas", 350, "buah"], ["bahasa_melayu/tembikai", 800, "buah"], ["bahasa_melayu/kelapa", 300, "buah"],
	["bahasa_melayu/belimbing", 200, "buah"], ["bahasa_melayu/anggur", 900, "buah"], ["bahasa_melayu/durian", 1500, "buah"],
	["bahasa_melayu/roti", 280, "roti"], ["bahasa_melayu/kuih_lapis", 150, "roti"], ["bahasa_melayu/telur", 50, "roti"],
	["bahasa_melayu/susu", 650, "minuman"], ["bahasa_melayu/teh_tarik", 200, "minuman"], ["pjpk/minuman_bergas", 250, "minuman"],
	["bahasa_melayu/nasi_lemak", 350, "gerai"], ["bahasa_melayu/roti_canai", 150, "gerai"], ["bahasa_melayu/satay", 100, "gerai"],
]
## upgrade id, name ms, name en, cost (RM earned), icon ref
const UPGRADES := [["roti", "Rak roti & telur", "Bread & egg shelf", 30, "bahasa_melayu/roti"],
	["minuman", "Peti minuman", "Drinks fridge", 60, "bahasa_melayu/teh_tarik"],
	["gerai", "Gerai makanan", "Food stall", 100, "bahasa_melayu/nasi_lemak"]]
const NOTES := [100, 500, 1000, 2000, 5000, 10000]
const COINS := [5, 10, 20, 50]
const CUSTOMERS := ["aiman", "aisyah", "meiling", "weijie", "kavitha", "arjun", "jaiden", "nurul", "rahman"]

static var tahun := 1   ## 1-4: money skills grow (RM only -> 50 sen -> 10 sen -> 5 sen + discounts)
static var day := 1


static func game_id() -> String:
	return "kedai_t%d" % tahun


static func unlocked() -> Array:
	var u: Array = GameState.progress.get("kedai_upgrades", {}).keys()
	return ["buah"] + u


static func buy_upgrade(id: String, cost_rm: int) -> bool:
	if GameState.coins < cost_rm:
		return false
	GameState.coins -= cost_rm
	GameState.progress.get_or_add("kedai_upgrades", {})[id] = true
	GameState.save()
	GameState.progress_changed.emit()
	return true


## Price in sen for this Tahun: T1 whole ringgit, T2 50-sen steps, T3 10-sen, T4 5-sen.
static func price(base: int, t := -1) -> int:
	t = tahun if t < 0 else t
	var step: int = [100, 50, 10, 5][clampi(t, 1, 4) - 1]
	var p := maxi(step, int(round(base / float(step))) * step)
	if t == 1:
		p = clampi(p, 100, 900)  # Tahun 1 works with whole ringgit up to RM10
	return p


static func shelf(t := -1) -> Array:
	var cats := unlocked()
	return PRODUCTS.filter(func(p): return p[2] in cats).map(func(p): return {"ref": p[0], "price": price(p[1], t)})


static func max_total(t := -1) -> int:
	t = tahun if t < 0 else t
	return [1000, 5000, 10000, 20000][clampi(t, 1, 4) - 1]


## One customer: {char, items: [{ref, price, qty}], discount(%), total, paid, change}
static func customer(rng: RandomNumberGenerator, d: int, t := -1) -> Dictionary:
	t = tahun if t < 0 else t
	var stock := shelf(t)
	var n_items := clampi(1 + d / 3, 1, 3 if t > 1 else 2)
	var items: Array = []
	var total := 0
	var pool := stock.duplicate()
	for k in 30:
		if items.size() >= n_items or pool.is_empty():
			break
		var p: Dictionary = pool.pop_at(rng.randi() % pool.size())
		var qty := 1 if d < 4 else rng.randi_range(1, 2)
		if total + p.price * qty > max_total(t):
			continue
		items.append({"ref": p.ref, "price": p.price, "qty": qty})
		total += p.price * qty
	if items.is_empty():
		var cheap: Dictionary = stock.reduce(func(a, b): return a if a.price <= b.price else b)
		items.append({"ref": cheap.ref, "price": cheap.price, "qty": 1})
		total = cheap.price
	var discount := 0
	if t >= 4 and rng.randf() < 0.4:
		discount = [10, 20, 50][rng.randi() % 3]
		total = total - total * discount / 100
		total = int(round(total / 5.0)) * 5
	var paid := pay_with(total, rng, t)
	return {"char": CUSTOMERS[rng.randi() % CUSTOMERS.size()], "items": items, "discount": discount, "total": total, "paid": paid, "change": paid - total}


## The customer pays with the smallest note (or sometimes the next one) that covers the total.
static func pay_with(total: int, rng: RandomNumberGenerator, t := -1) -> int:
	var ok := NOTES.filter(func(n): return n >= total)
	if ok.is_empty():
		return int(ceil(total / 10000.0)) * 10000
	var i := 0 if rng.randf() < 0.6 or ok.size() == 1 else 1
	return ok[i]


## Notes and coins in Pak Ali's drawer for this Tahun.
static func drawer(t := -1) -> Array:
	t = tahun if t < 0 else t
	match clampi(t, 1, 4):
		1: return [100, 500, 1000]
		2: return [50, 100, 500, 1000, 2000]
		_: return [5, 10, 20, 50, 100, 500, 1000, 2000, 5000]


## Can `amount` be made from this drawer? (all drawers include the smallest step, so yes for valid change)
static func payable(amount: int, t := -1) -> bool:
	var d := drawer(t)
	d.reverse()
	var left := amount
	for v in d:
		left = left % v if v <= left else left
	return left == 0


## Four choices for the total question: correct + near misses on the Tahun's price step.
static func total_choices(total: int, rng: RandomNumberGenerator, t := -1) -> Array:
	t = tahun if t < 0 else t
	var step: int = [100, 50, 10, 5][clampi(t, 1, 4) - 1]
	var c := [total]
	var tries := 0
	while c.size() < 4 and tries < 50:
		tries += 1
		var d := total + rng.randi_range(-4, 4) * step
		if d > 0 and not d in c:
			c.append(d)
	while c.size() < 4:
		c.append(c[-1] + step)
	c.shuffle()
	return c


static func rm(sen: int) -> String:
	return ("RM%d" % (sen / 100)) if sen % 100 == 0 and tahun == 1 else MoneyItem.format_rm(sen)


## Opening time for the clock task: T1 whole hours, T2 half hours, T3+ 5-minute steps.
static func opening_time(rng: RandomNumberGenerator, t := -1) -> Vector2i:
	t = tahun if t < 0 else t
	var h := rng.randi_range(7, 10)
	var m := 0 if t == 1 else (rng.randi_range(0, 1) * 30 if t == 2 else rng.randi_range(0, 11) * 5)
	return Vector2i(h, m)


## Fraction order (Tahun 2+): [numerator, denominator] for cutting a fruit.
static func fraction_order(rng: RandomNumberGenerator, t := -1) -> Vector2i:
	t = tahun if t < 0 else t
	var opts := [Vector2i(1, 2), Vector2i(1, 4), Vector2i(3, 4)] if t <= 2 else [Vector2i(1, 2), Vector2i(1, 4), Vector2i(3, 4), Vector2i(1, 3), Vector2i(2, 3), Vector2i(3, 8), Vector2i(5, 8)]
	return opts[rng.randi() % opts.size()]
