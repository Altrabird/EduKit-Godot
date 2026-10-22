## Builds kit/ui/theme.tres (flat, rounded, chunky "school sticker" look) and the
## platformer TileSet. Run after art changes:
## godot --headless --path . -s tools/build_theme.gd
extends SceneTree

const INK := Color("2b2d42")
const PAL := {
	"Blue": Color("3a86ff"), "Green": Color("6bcb77"), "Red": Color("ef476f"),
	"Yellow": Color("ffd166"), "Purple": Color("9b5de5"), "Orange": Color("ff9f1c"), "Teal": Color("2ec4b6"),
}

func _init() -> void:
	var theme := build_theme()
	var err := ResourceSaver.save(theme, "res://kit/ui/theme.tres")
	print("theme.tres ", "OK" if err == OK else "FAILED %d" % err)
	var ts := build_tileset()
	var err2 := ResourceSaver.save(ts, "res://kit/tiles/platformer_tileset.tres")
	print("platformer_tileset.tres ", "OK" if err2 == OK else "FAILED %d" % err2)
	quit(0 if err == OK and err2 == OK else 1)


static func box(bg: Color, radius := 18, border := 4, shadow := 6, border_col := INK) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = bg
	s.set_corner_radius_all(radius)
	s.set_border_width_all(border)
	s.border_color = border_col
	s.shadow_color = Color(0, 0, 0, 0.22)
	s.shadow_size = 0
	s.shadow_offset = Vector2(0, shadow)
	if shadow > 0:
		s.shadow_size = 1
	s.content_margin_left = 22
	s.content_margin_right = 22
	s.content_margin_top = 12
	s.content_margin_bottom = 14
	s.anti_aliasing = true
	return s


static func weight(base: Font, w: int) -> FontVariation:
	var fv := FontVariation.new()
	fv.base_font = base
	fv.variation_opentype = {TextServerManager.get_primary_interface().name_to_tag("wght"): w}
	return fv


func build_theme() -> Theme:
	var t := Theme.new()
	var andika: FontFile = load("res://assets/fonts/Andika-Regular.ttf")
	var andika_b: FontFile = load("res://assets/fonts/Andika-Bold.ttf")
	var fredoka: FontFile = load("res://assets/fonts/Fredoka.ttf")
	var heading := weight(fredoka, 600)
	t.default_font = andika
	t.default_font_size = 30
	# Buttons: one base style + a type variation per colour (theme_type_variation = "ButtonGreen" etc.)
	for name in ["Button"] + PAL.keys().map(func(k): return "Button" + k):
		var col: Color = PAL.get(name.trim_prefix("Button"), PAL["Blue"]) if name != "Button" else PAL["Blue"]
		if name != "Button":
			t.set_type_variation(name, "Button")
		t.set_stylebox("normal", name, box(col))
		t.set_stylebox("hover", name, box(col.lightened(0.12)))
		var pressed := box(col.darkened(0.12), 18, 4, 0)
		pressed.content_margin_top = 16
		pressed.content_margin_bottom = 10
		t.set_stylebox("pressed", name, pressed)
		t.set_stylebox("disabled", name, box(Color("adb5bd"), 18, 4, 2, Color("6c757d")))
		var focus := box(Color(0, 0, 0, 0), 20, 4, 0, Color("ffd166"))
		focus.draw_center = false
		t.set_stylebox("focus", name, focus)
		var fg := INK if col.get_luminance() > 0.6 else Color.WHITE
		for c in ["font_color", "font_hover_color", "font_focus_color", "font_pressed_color", "font_hover_pressed_color"]:
			t.set_color(c, name, fg)
		t.set_color("font_disabled_color", name, Color("6c757d"))
		t.set_font("font", name, heading)
		t.set_font_size("font_size", name, 34)
		t.set_constant("h_separation", name, 12)
		t.set_constant("icon_max_width", name, 56)
	# Panels
	t.set_stylebox("panel", "Panel", box(Color("fdfcf7"), 28, 5, 8))
	t.set_stylebox("panel", "PanelContainer", box(Color("fdfcf7"), 28, 5, 8))
	var panels := {"PanelChalk": Color("2f5d50"), "PanelBlue": Color("3a86ff"), "PanelCream": Color("fff3d6"), "PanelDark": Color(0.1, 0.1, 0.18, 0.88)}
	for pname in panels:
		t.set_type_variation(pname, "PanelContainer")
		var sb := box(panels[pname], 28, 5, 8)
		if pname == "PanelChalk":
			sb.border_color = Color("7a4a2a")
			sb.set_border_width_all(12)
		t.set_stylebox("panel", pname, sb)
	# Labels
	t.set_color("font_color", "Label", INK)
	t.set_color("font_outline_color", "Label", Color.WHITE)
	var labels := {"LabelTitle": 64, "LabelHeading": 44, "LabelSmall": 22}
	for lname in labels:
		t.set_type_variation(lname, "Label")
		t.set_font_size("font_size", lname, labels[lname])
		t.set_font("font", lname, heading if labels[lname] > 30 else andika)
	t.set_type_variation("LabelOnDark", "Label")
	t.set_color("font_color", "LabelOnDark", Color.WHITE)
	t.set_type_variation("LabelChalk", "Label")
	t.set_color("font_color", "LabelChalk", Color("f1faee"))
	t.set_font("font", "LabelChalk", andika_b)
	# Progress bar (timer/xp)
	var pb_bg := box(Color("dee2e6"), 999, 4, 0)
	pb_bg.content_margin_top = 0
	pb_bg.content_margin_bottom = 0
	var pb_fill := box(PAL["Green"], 999, 4, 0)
	t.set_stylebox("background", "ProgressBar", pb_bg)
	t.set_stylebox("fill", "ProgressBar", pb_fill)
	t.set_color("font_color", "ProgressBar", INK)
	t.set_font("font", "ProgressBar", heading)
	# Text input
	var le := box(Color.WHITE, 16, 4, 0)
	t.set_stylebox("normal", "LineEdit", le)
	var le_f := box(Color.WHITE, 16, 5, 0, PAL["Blue"])
	t.set_stylebox("focus", "LineEdit", le_f)
	t.set_color("font_color", "LineEdit", INK)
	t.set_font_size("font_size", "LineEdit", 34)
	# Tabs / scroll / tooltip / check
	t.set_stylebox("tab_selected", "TabContainer", box(PAL["Blue"], 14, 4, 0))
	t.set_stylebox("tab_unselected", "TabContainer", box(Color("dee2e6"), 14, 4, 0))
	t.set_stylebox("tab_hovered", "TabContainer", box(Color("8ecae6"), 14, 4, 0))
	t.set_stylebox("panel", "TabContainer", box(Color("fdfcf7"), 20, 4, 0))
	t.set_color("font_selected_color", "TabContainer", Color.WHITE)
	t.set_color("font_unselected_color", "TabContainer", INK)
	t.set_color("font_hovered_color", "TabContainer", INK)
	t.set_font("font", "TabContainer", heading)
	t.set_font_size("font_size", "TabContainer", 26)
	var grab := box(PAL["Blue"], 999, 0, 0)
	t.set_stylebox("grabber", "VScrollBar", grab)
	t.set_stylebox("grabber_highlight", "VScrollBar", box(PAL["Blue"].lightened(0.2), 999, 0, 0))
	t.set_stylebox("scroll", "VScrollBar", box(Color(0, 0, 0, 0.08), 999, 0, 0))
	t.set_stylebox("panel", "TooltipPanel", box(Color("fff3d6"), 12, 3, 0))
	t.set_color("font_color", "TooltipLabel", INK)
	t.set_color("font_color", "CheckBox", INK)
	t.set_color("font_color", "CheckButton", INK)
	t.set_font_size("font_size", "CheckButton", 28)
	var slider := box(Color("dee2e6"), 999, 3, 0)
	slider.content_margin_top = 6
	slider.content_margin_bottom = 6
	t.set_stylebox("slider", "HSlider", slider)
	t.set_stylebox("grabber_area", "HSlider", box(PAL["Green"], 999, 3, 0))
	t.set_stylebox("grabber_area_highlight", "HSlider", box(PAL["Green"].lightened(0.15), 999, 3, 0))
	# Lists (gallery, level pickers)
	t.set_stylebox("panel", "ItemList", box(Color("fdfcf7"), 18, 4, 0))
	t.set_stylebox("selected", "ItemList", box(PAL["Blue"], 10, 0, 0))
	t.set_stylebox("selected_focus", "ItemList", box(PAL["Blue"], 10, 0, 0))
	t.set_stylebox("hovered", "ItemList", box(Color("dbeafe"), 10, 0, 0))
	t.set_stylebox("cursor", "ItemList", StyleBoxEmpty.new())
	t.set_stylebox("cursor_unfocused", "ItemList", StyleBoxEmpty.new())
	t.set_color("font_color", "ItemList", INK)
	t.set_color("font_hovered_color", "ItemList", INK)
	t.set_color("font_selected_color", "ItemList", Color.WHITE)
	t.set_color("guide_color", "ItemList", Color(0, 0, 0, 0.06))
	t.set_constant("v_separation", "ItemList", 10)
	return t


# Atlas cell lists must match tools/gen_ui_fx_tiles.py.
const SOLID := [Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(3, 0),
	Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(3, 1), Vector2i(4, 1), Vector2i(5, 1), Vector2i(6, 1), Vector2i(7, 1),
	Vector2i(0, 2), Vector2i(1, 2), Vector2i(2, 2), Vector2i(3, 2), Vector2i(4, 2), Vector2i(5, 2), Vector2i(6, 2), Vector2i(7, 2)]
const ONE_WAY := [Vector2i(4, 0), Vector2i(5, 0), Vector2i(6, 0), Vector2i(7, 0)]
const HAZARD := [Vector2i(6, 3)]
const ATLAS_SIZE := Vector2i(8, 6)

func build_tileset() -> TileSet:
	var ts := TileSet.new()
	ts.tile_size = Vector2i(64, 64)
	ts.add_physics_layer()
	ts.set_physics_layer_collision_layer(0, 1)
	ts.add_custom_data_layer()
	ts.set_custom_data_layer_name(0, "kind")
	ts.set_custom_data_layer_type(0, TYPE_STRING)
	var src := TileSetAtlasSource.new()
	src.texture = load("res://assets/art/tiles/tiles_platformer.svg")
	src.texture_region_size = Vector2i(64, 64)
	ts.add_source(src, 0)
	var full := PackedVector2Array([Vector2(-32, -32), Vector2(32, -32), Vector2(32, 32), Vector2(-32, 32)])
	for y in ATLAS_SIZE.y:
		for x in ATLAS_SIZE.x:
			var c := Vector2i(x, y)
			src.create_tile(c)
			var td := src.get_tile_data(c, 0)
			if c in SOLID:
				td.add_collision_polygon(0)
				td.set_collision_polygon_points(0, 0, full)
				td.set_custom_data("kind", "solid")
			elif c in ONE_WAY:
				td.add_collision_polygon(0)
				td.set_collision_polygon_points(0, 0, PackedVector2Array([Vector2(-32, -28), Vector2(32, -28), Vector2(32, -4), Vector2(-32, -4)]))
				td.set_collision_polygon_one_way(0, 0, true)
				td.set_custom_data("kind", "one_way")
			elif c in HAZARD:
				# a low collider so Player2D's slide collisions can detect the hazard
				td.add_collision_polygon(0)
				td.set_collision_polygon_points(0, 0, PackedVector2Array([Vector2(-30, 0), Vector2(30, 0), Vector2(30, 32), Vector2(-30, 32)]))
				td.set_custom_data("kind", "hazard")
			else:
				td.set_custom_data("kind", "deco")
	return ts
