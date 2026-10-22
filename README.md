# EduKit — education game assets for Godot 4.7

Reusable art, audio, 3D props and GDScript components for Malaysian primary-school
(KSSR) games, in Bahasa Melayu and English. Everything is generated from code in
`tools/`, so any asset can be restyled or extended by editing a generator.

Open the folder in Godot 4.7 and press **F5**: the gallery browses every asset and
launches four playable demos (quiz, drag-and-match, platformer, 3D classroom).

## Games built on EduKit (play in the browser)

| Game | Play | Web build repo | Source |
|---|---|---|---|
| Juara Kuiz Sekolah — quiz show, 11 KSSR subjects, Tahun 1–6 | [play](https://altrabird.github.io/Juara-Kuiz-Sekolah/) | [Altrabird/Juara-Kuiz-Sekolah](https://github.com/Altrabird/Juara-Kuiz-Sekolah) | `games/juara_kuiz/` |
| Kancil & Suku Kata — BM syllable platformer (+ English letters) | [play](https://altrabird.github.io/Kancil-Suku-Kata/) | [Altrabird/Kancil-Suku-Kata](https://github.com/Altrabird/Kancil-Suku-Kata) | `games/kancil/` |
| Kedai Runcit Pak Ali — money, change, time, fractions | [play](https://altrabird.github.io/Kedai-Runcit-Pak-Ali/) | [Altrabird/Kedai-Runcit-Pak-Ali](https://github.com/Altrabird/Kedai-Runcit-Pak-Ali) | `games/kedai/` |
| Makmal Sains Ajaib 3D — 3D science lab missions (Sains + RBT) | [play](https://altrabird.github.io/Makmal-Sains-Ajaib-3D/) | [Altrabird/Makmal-Sains-Ajaib-3D](https://github.com/Altrabird/Makmal-Sains-Ajaib-3D) | `games/makmal/` |
| Kampungku Sihat — PJPK, Moral, PI, Seni & Muzik village | [play](https://altrabird.github.io/Kampungku-Sihat/) | [Altrabird/Kampungku-Sihat](https://github.com/Altrabird/Kampungku-Sihat) | `games/kampung/` |

Each game is a feature tag of this one project (`run/main_scene.<tag>` in `project.godot`
plus a Web export preset), so all five share the kit with no copies. Publish one with:

```bash
bash tools/deploy_web.sh "Web - Juara Kuiz Sekolah" juara_kuiz Juara-Kuiz-Sekolah "-"
```

It exports single-threaded HTML5 (works on GitHub Pages without special headers), loads
it in headless Chromium, and pushes the build to the game's own repo. Each game has a
headless play-through test: `godot --headless --path . res://games/<game>/test_<game>.tscn`.

| | Count | Where |
|---|---|---|
| Vector art (SVG, crisp at any size) | 539 | `assets/art/` |
| — per KSSR subject (11 folders) | 323 | `assets/art/subjects/<subject>/` |
| — icons / characters / backgrounds / UI / FX / tiles | 68 / 77 / 18 / 40 / 12 / 1 atlas | `assets/art/<category>/` |
| 3D props (GLB, low-poly, metres) | 64 | `assets/models/<group>/` |
| Sound effects (WAV) | 41 | `assets/audio/sfx/` |
| Music loops + jingles (OGG) | 5 + 2 | `assets/audio/music/` |
| Voice clips, ms-MY + English (MP3) | 1,421 | `assets/audio/voice/<ms\|en>/<group>/` |
| Question banks (BM + EN, voiced) | 193 in 11 subjects | `data/questions/` |
| GDScript components | 21 | `kit/` |

Subject list follows KPM's *Senarai Mata Pelajaran KSSR (Semakan 2017)* — see
[docs/SUBJECTS.md](docs/SUBJECTS.md). Contact sheets of every set: `docs/sheets/`.
Screenshots: `docs/screens/`.

## Using the kit in a game

Autoloads (already in `project.godot`):

```gdscript
Audio.sfx("correct")                      # 39 effects, see assets/audio/audio_manifest.json
Audio.music("menu_ceria")                 # loops + cross-fades
Audio.say("feedback", "well_done")        # voice in GameState.lang ("ms" / "en")
Audio.say_vocab("sains", "planet_earth")  # every subject picture has a BM + EN clip
GameState.lang = "en"                     # emits lang_changed; saved to user://
GameState.record_level("my_game", 3, 2)   # best stars per level, unlock rule built in
Questions.math("×", 3)                    # generated, 4 unique choices
Questions.from_bank("sejarah", 5)         # shuffled bank questions
Questions.picture("bahasa_melayu", 5)     # "Apakah ini?" from the art + spoken answer
Fader.go("res://my_scene.tscn")
```

Assets by reference (`"<subject or category>/<id>"`):

```gdscript
EduAssets.texture("sains/planet_saturn")
EduAssets.name_of("bahasa_melayu/durian")   # "Durian" / "Durian"
EduAssets.by_subject("matematik")           # all refs
EduAssets.by_tag("fruit")
EduAssets.character("aisyah", "happy")
EduAssets.model("classroom/desk")           # PackedScene
```

Components (all `class_name`, usable from code or the Add Node dialog):

| Component | What it does |
|---|---|
| `QuizCard`, `AnswerButton`, `TimerBar` | question + picture + 4 colour/shape-coded answers, optional countdown |
| `Feedback` | shared correct/wrong sound, voice, popup and confetti |
| `TextTile`, `PictureCard`, `DropSlot` | drag-and-drop letters/syllables/words/pictures onto targets |
| `DialogueBox`, `Character2D` | typewriter dialogue with portraits; characters with 7 expressions, talk/react/cheer |
| `FractionPie`, `AnalogClock`, `NumberLine`, `MoneyItem` | maths manipulatives (interactive) |
| `StarRating`, `ScoreCounter`, `LevelButton`, `ResultsPanel` | progression UI wired to GameState |
| `Player2D` + `kit/tiles/platformer_tileset.tres` | platformer controller, one-way planks, hazard tiles |
| `Prop3D`, `OrbitCamera3D` | clickable GLB props with auto-fitted colliders; orbit camera |

Theme: `kit/ui/theme.tres` (Fredoka headings, Andika body — Andika is designed for
early readers). Variations: `ButtonGreen/Red/Yellow/Purple/Orange/Teal`,
`PanelChalk/Blue/Cream/Dark`, `LabelTitle/Heading/Small/OnDark/Chalk`.

## Regenerating

```bash
python tools/gen_all.py          # all SVG art + assets/art/manifest.json
python tools/gen_audio.py        # SFX + music (needs ffmpeg)
python tools/gen_voice.py        # voice clips via edge-tts; re-run resumes
python tools/gen_questions.py    # data/questions/*.json (first choice = correct)
blender -b --factory-startup -P tools/build_models.py   # GLB props
godot --headless --path . --import
godot --headless --path . -s tools/build_theme.gd       # theme + tileset
bash tools/sheet.sh subjects/sains 160 10               # contact sheet -> docs/sheets/
```

## Checking

```bash
godot --headless --path . res://tools/selftest.tscn     # exit code = failures
godot --path . -- --shot                                # gallery screenshots -> docs/screens/
```

The self-test loads every asset, compiles every script, checks all manifests and voice
paths, runs 1,200 generated maths questions, every bank and picture question, the
save/load round trip, and runs each component in the tree (8,851 checks).

## Licences and notes

- Art, audio, models and code: generated for this project.
- Fonts: Fredoka, Andika and Noto Sans Symbols 2 (web glyph fallback), SIL Open Font License (`assets/fonts/OFL-*.txt`).
- Voices: Microsoft neural voices via `edge-tts` (ms-MY Yasmin, en-SG Luna). Fine for
  classroom use; check Microsoft's terms before selling a game that ships these clips.
- Money art is deliberately stylised (no real banknote designs).
- Exporting: add `*.json` to the export filter so manifests and question banks ship.
