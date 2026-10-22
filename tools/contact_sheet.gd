## Rasterises every SVG in a folder with Godot's own SVG importer (ThorVG) and
## tiles them into one PNG, so art can be reviewed exactly as Godot renders it.
## godot --headless --path . -s tools/contact_sheet.gd -- <res folder> <out.png> [cell] [cols]
extends SceneTree


func _init() -> void:
	var args := OS.get_cmdline_user_args()
	var folder: String = args[0]
	var out: String = args[1]
	var cell := int(args[2]) if args.size() > 2 else 128
	var cols := int(args[3]) if args.size() > 3 else 10
	var files := Array(DirAccess.get_files_at(folder)).filter(func(f): return f.ends_with(".svg"))
	files.sort()
	var rows := ceili(files.size() / float(cols))
	var sheet := Image.create(cols * cell, max(rows, 1) * cell, false, Image.FORMAT_RGBA8)
	for y in sheet.get_height():
		for x in sheet.get_width():
			var checker := ((x / 16) + (y / 16)) % 2 == 0
			sheet.set_pixel(x, y, Color(0.93, 0.93, 0.95) if checker else Color(0.86, 0.87, 0.9))
	var failed := 0
	for i in files.size():
		var img := Image.new()
		var err := img.load_svg_from_string(FileAccess.get_file_as_string(folder.path_join(files[i])), 1.0)
		if err != OK:
			push_error("SVG failed: " + files[i])
			failed += 1
			continue
		var s: float = float(cell - 8) / maxi(img.get_width(), img.get_height())
		img.resize(maxi(1, int(img.get_width() * s)), maxi(1, int(img.get_height() * s)), Image.INTERPOLATE_LANCZOS)
		var pos := Vector2i((i % cols) * cell + (cell - img.get_width()) / 2, (i / cols) * cell + (cell - img.get_height()) / 2)
		sheet.blend_rect(img, Rect2i(Vector2i.ZERO, img.get_size()), pos)
		print("%d\t%s" % [i, files[i]])
	sheet.save_png(out)
	print("sheet: %s (%d files, %d failed)" % [out, files.size(), failed])
	quit(1 if failed else 0)
