# Five games built on EduKit — plan for approval

Nothing below is built yet. Each game reuses the kit as-is; the "new work" lines are
the only code each one needs. Order is by reuse (fastest first). Target: Godot 4.7,
Compatibility renderer, Windows + Android (school PCs and tablets); Web optional.

Coverage across the 11 KSSR subjects:

| | BM | BI | MT | SN | PI | PM | PJPK | PSV | PMZ | SJ | RBT |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 Juara Kuiz Sekolah | ● | ● | ● | ● | ● | ● | ● | ● | ● | ● | ● |
| 2 Kancil & Suku Kata | ● | ● | | | | ● | | | | | |
| 3 Kedai Runcit Pak Ali | ● | | ● | | | ● | ● | | | | |
| 4 Makmal Sains Ajaib 3D | | | ● | ● | | | | | | | ● |
| 5 Kampungku Sihat | | | | | ● | ● | ● | ● | ● | | |

---

## 1. Juara Kuiz Sekolah (School Quiz Champion) — Tahun 1–6, all subjects

**Fantasy:** a TV-style quiz show on the school-hall stage, hosted by Robo and Kenny.

**Core loop (3–5 min round):** pick subject + Tahun → 10 questions (bank, generated
maths, picture questions) → answer under a timer → streak multiplier → stars →
unlock the next "stage" (Kelas → Sekolah → Daerah → Negeri → Kebangsaan).

**Mechanics that make it a game, not a worksheet**
- Streak meter: 3 right in a row = ×2 points and Kenny's "on fire" cheer.
- Three lifelines per round: 50:50, Petunjuk (hint from Robo), Langkau (skip).
- Boss question at the end of each stage (harder Tahun, longer timer, double stars).
- Hot-seat class mode: 2–4 teams by answer colour, teacher projects the screen.
- Teacher editor: a screen to add questions to `data/questions/*.json` (BM + EN + picture picker).

**Kit reused:** QuizCard, AnswerButton, TimerBar, Feedback, Questions (bank/math/picture),
Character2D (Robo, Kenny), ResultsPanel, StarRating, LevelButton, stage_hall, quiz music,
983 voice clips. **New work:** subject/Tahun picker, lifelines, streak, team mode, editor, ~40 questions per subject.

**MVP:** subject picker + 5 stages + lifelines + results. **Then:** team mode, editor.

---

## 2. Kancil & Suku Kata (Kancil's Syllable Adventure) — Tahun 1–2, BM literacy (+ BI phonics mode)

**Fantasy:** Sang Kancil must outsmart Buaya and Harimau to cross the river and forest;
every obstacle opens only with the right word.

**Core loop (per level ~3 min):** run & jump through kampung / rainforest → collect
syllable tiles (ba, ju, bu, ku…) → reach a word gate showing a picture (baju) → drag
the syllables into the slots → hear the word → gate opens.

**Mechanics:** syllable tiles speak when touched (90 recorded suku kata); wrong syllable
bounces back with a gentle buzz, no life lost; crocodile "bridge" level retells the folk
tale (crocodiles line up as you spell); 3 stars = all syllables + no wrong drops + time.
BI mode swaps syllables for letters/phonics with the English vocab pictures.

**Kit reused:** Player2D, platformer TileSet, parallax layers, TextTile, DropSlot,
PictureCard, DialogueBox, Sang Kancil / Buaya / Harimau / Gajah art, syllable + vocab voices,
kampung + rainforest backgrounds. **New work:** word-gate scene, 15 level layouts
(ASCII like the demo), word list per level (2- then 3-syllable words), story dialogues.

**MVP:** 5 levels, 2-syllable words. **Then:** 3-syllable words, BI mode, story cut-scenes.

---

## 3. Kedai Runcit Pak Ali (Pak Ali's Shop) — Tahun 1–4, Matematik (wang, masa, pecahan)

**Fantasy:** run the village shop for a week; customers are the pupil characters.

**Core loop (one "day" ~4 min):** customer arrives with a picture shopping list → tap items
onto the counter → total the price → take payment → drag coins/notes to give exact change
→ customer reacts (happy/sad) → end-of-day takings and stars.

**Mechanics:** prices grow with Tahun (sen only → RM + sen → discounts/percent in Tahun 4);
opening-hours mini-task with the interactive clock ("Kedai buka pukul 8:30"); fraction
orders ("½ tembikai", "¼ kek") cut with FractionPie; unlock shop upgrades with earnings
(shelf, fridge, new fruit) — a light tycoon loop that rewards accuracy, not speed.

**Kit reused:** MoneyItem (coins + notes), AnalogClock, FractionPie, DropSlot, PictureCard,
BM fruit/food art, characters, kampung background, numbers voice, ScoreCounter, ResultsPanel.
**New work:** counter/shelf scene, customer generator, change checker, upgrade shop.

**MVP:** 5 days, coins only, exact change. **Then:** notes, clock and fraction orders, upgrades.

---

## 4. Makmal Sains Ajaib 3D (Magic Science Lab) — Tahun 3–6, Sains + RBT

**Fantasy:** Cikgu Nurul's after-school lab; each bench is a mission.

**Missions (5–8 min each):**
1. *Sistem Suria* — place 8 planets in orbit order in 3D; drag to rotate the view.
2. *Kitaran Hidup* — order frog / butterfly life-cycle cards, then watch them animate.
3. *Magnet* — sort objects into "ditarik / tidak ditarik" bins, test by dragging a magnet.
4. *Litar Ringkas* (RBT) — connect battery, switch, LED, resistor; LED lights only when correct.
5. *Tumbesaran Pokok* — water/light choices over a time-lapse; plant stages respond.

**Kit reused:** Prop3D (64 GLB props incl. lab table, microscope, planets, plants), OrbitCamera3D,
science + RBT SVG for cards, DialogueBox with Cikgu Nurul, Feedback, voices.
**New work:** mission framework (goal → check → reward), snap-points in 3D, circuit logic,
plant growth state machine. **Most new code of the five** — build last or after #1–#3.

**MVP:** missions 1 and 2. **Then:** magnet, circuit, plant.

---

## 5. Kampungku Sihat (My Healthy Village) — Tahun 1–3, PJPK + Moral + PI + Seni/Muzik

**Fantasy:** help villagers through one day; every good habit makes the village brighter
(colour returns to a grey map as you play).

**Activities (1–3 min each, picked from the village map):**
- *Pinggan Sihat* — drag food onto the quarter–quarter–half plate.
- *Kitar Semula* — sort rubbish into blue / brown / orange bins (Malaysian colour code).
- *Basuh Tangan* — follow the 20-second handwash with the TimerBar and soap bubbles.
- *Bantu Jiran* — short moral-choice dialogues (return the wallet, share, help a friend).
- *Pendidikan Islam corner* — order the wudhu steps, match festival items (optional module, objects only, no figures).
- *Kompang Rentak* — tap along to a kompang rhythm (music + art corner: colour-mixing puzzle with the colour wheel).

**Kit reused:** PJPK food + hygiene art, moral recycling bins, PI objects, muzik + seni art,
DropSlot, TimerBar, DialogueBox, characters, kampung background, badges, voices.
**New work:** village map hub with colour-restore effect, 6 activity scenes, rhythm timing.

**MVP:** map + Pinggan Sihat + Kitar Semula + Basuh Tangan. **Then:** the other three.

---

## Shared groundwork before game #1 (½ session)

- Move `kit/` + `assets/` into `addons/edukit/` so each game is its own Godot project that
  copies one folder (keeps games small and the kit upgradable).
- On-screen touch controls for Player2D (tablets).
- Android export preset + one test build on a real device.

## Decisions needed from you

1. Approve the five (or swap any).
2. Which to build first — recommendation: **#1 Juara Kuiz** (most reuse, covers every subject).
3. Main device: school PCs (Windows), Android tablets, or browser.
