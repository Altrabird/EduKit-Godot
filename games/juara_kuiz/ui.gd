## Small UI builders shared by the Juara Kuiz scenes.
class_name JksUI
extends RefCounted


static func title(text: String, variation := "LabelTitle", color := Color.WHITE) -> Label:
	var l := Label.new()
	l.text = text
	l.theme_type_variation = variation
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.add_theme_color_override("font_color", color)
	l.add_theme_color_override("font_outline_color", Color("2b2d42"))
	l.add_theme_constant_override("outline_size", 14)
	return l


static func button(text: String, variation := "Button", icon_ref := "", min_size := Vector2(0, 96)) -> Button:
	var b := Button.new()
	b.text = text
	b.theme_type_variation = variation
	b.custom_minimum_size = min_size
	if icon_ref != "":
		b.icon = EduAssets.texture(icon_ref)
		b.expand_icon = true
	b.pressed.connect(func(): Audio.sfx("ui_click"))
	return b


static func icon_button(icon_ref: String, variation := "ButtonYellow", size := 96) -> Button:
	var b := button("", variation, icon_ref, Vector2(size, size))
	return b


static func center_column(parent: Control, top := 40, bottom := 40, sep := 24) -> VBoxContainer:
	var v := VBoxContainer.new()
	v.set_anchors_preset(Control.PRESET_FULL_RECT)
	v.offset_top = top
	v.offset_bottom = -bottom
	v.offset_left = 60
	v.offset_right = -60
	v.add_theme_constant_override("separation", sep)
	parent.add_child(v)
	return v


static func go(scene_key: String) -> void:
	Fader.go(Jks.SCENES[scene_key])
