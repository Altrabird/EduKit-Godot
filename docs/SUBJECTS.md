# KSSR subjects → asset folders

Source: KPM dataset *Senarai Mata Pelajaran KSSR (Semakan 2017) dan KSSM ikut SPI*
(Surat Pekeliling Ikhtisas Bil. 8 & 9 Tahun 2016), archive.data.gov.my —
local copy: `docs/kssr-senarai-mata-pelajaran-data.gov.my.xlsx`.

| # | Mata pelajaran (KSSR Semakan 2017) | Tahun | Folder `assets/art/subjects/…` |
|---|---|---|---|
| Teras 1–4 | Bahasa Melayu (SK / SJK) | 1–6 | `bahasa_melayu` |
| Teras 3–4 | Bahasa Inggeris (SK / SJK) | 1–6 | `bahasa_inggeris` |
| Teras 5 | Bahasa Cina | 1–6 | `bahasa_lain` (shared tiles + font notes) |
| Teras 6 | Bahasa Tamil | 1–6 | `bahasa_lain` |
| Teras 7 | Matematik | 1–6 | `matematik` |
| Teras 8 | Pendidikan Islam | 1–6 | `pendidikan_islam` |
| Teras 9 | Pendidikan Moral | 1–6 | `pendidikan_moral` |
| Teras 10 | Sains | 1–6 | `sains` |
| Teras 11 | Pendidikan Jasmani dan Pendidikan Kesihatan | 1–6 | `pjpk` |
| Teras 12 | Pendidikan Kesenian (Seni Visual + Muzik) | 1–6 | `seni_visual`, `muzik` |
| Teras 13 | Sejarah | 4–6 | `sejarah` |
| Teras 14 | Reka Bentuk dan Teknologi | 4–6 | `rbt` |
| Tambahan 15–20 | Bahasa Arab, Bahasa Cina SK, Bahasa Tamil SK, Bahasa Iban, Bahasa Kadazandusun, Bahasa Semai | 1–6 | `bahasa_lain` |

Words on screen are never baked into art. Letter/word/number tiles are Godot scenes
(`kit/components/text_tile.tscn`) that draw text with a bundled font, so the same tile
art serves every language subject. Picture vocabulary (fruit, animals, objects) lives in
`bahasa_melayu`/`bahasa_inggeris`/`sains` etc. and each item carries `bm` + `en` names in
`assets/art/manifest.json` — any language game can use any subject's pictures.

Shared, subject-free art: `icons`, `characters`, `backgrounds`, `ui`, `tiles`, `fx`.

Note: KPM has announced Kurikulum Persekolahan 2027 (new integrated Tahap 1/2 subjects).
The folders follow the subjects in force today; new 2027 subjects can reuse them.
