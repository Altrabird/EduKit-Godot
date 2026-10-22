## Shared scene helpers (demos + games): home button, full-screen background, doc screenshots.
class_name KitUtil
extends RefCounted


static func background(parent: Node, ref: String) -> TextureRect:
	var bg := TextureRect.new()
	bg.texture = EduAssets.texture(ref)
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(bg)
	return bg


static func home_button(parent: Node) -> Button:
	var b := Button.new()
	b.icon = EduAssets.texture("icons/home")
	b.expand_icon = true
	b.custom_minimum_size = Vector2(96, 96)
	b.position = Vector2(24, 24)
	b.theme_type_variation = "ButtonYellow"
	b.pressed.connect(func(): Audio.sfx("ui_back"); Fader.go("res://demo/gallery.tscn"))
	parent.add_child(b)
	return b


## With `-- --shot` on the command line: wait, save docs/screens/<shot_name>.png, quit.
static func maybe_shot(node: Node, shot_name: String, delay := 2.0) -> void:
	if not "--shot" in OS.get_cmdline_user_args():
		return
	await node.get_tree().create_timer(delay).timeout
	await RenderingServer.frame_post_draw
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://docs/screens"))
	node.get_viewport().get_texture().get_image().save_png("res://docs/screens/%s.png" % shot_name)
	print("shot ", shot_name)
	node.get_tree().quit()
