## Five stages along a path: Kelas -> Sekolah -> Daerah -> Negeri -> Kebangsaan.
## Solo: a stage opens after a star on the previous one. Class mode: all open.
extends Control

const POS := [Vector2(260, 760), Vector2(640, 560), Vector2(980, 760), Vector2(1320, 540), Vector2(1660, 700)]


func _ready() -> void:
	KitUtil.background(self, "backgrounds/school_field")
	var path := Line2D.new()
	path.width = 18
	path.default_color = Color(1, 1, 1, 0.85)
	path.joint_mode = Line2D.LINE_JOINT_ROUND
	for i in POS.size() - 1:
		for k in 12:
			var t := k / 12.0
			var a: Vector2 = POS[i]
			var b: Vector2 = POS[i + 1]
			path.add_point(a.lerp(b, t) + Vector2(0, -sin(t * PI) * 60) + Vector2(70, 70))
	path.add_point(POS[-1] + Vector2(70, 70))
	add_child(path)
	var gid := Jks.game_id()
	for i in 5:
		var lb := LevelButton.new()
		lb.game_id = gid
		lb.level = i + 1
		lb.always_open = Jks.teams > 0
		lb.position = POS[i]
		lb.custom_minimum_size = Vector2(140, 140)
		lb.chosen.connect(func(level):
			Jks.stage = level
			JksUI.go("play"))
		add_child(lb)
		var name := JksUI.title(Jks.stage_name(i + 1), "LabelHeading")
		name.position = POS[i] + Vector2(-80, 150)
		name.size = Vector2(300, 60)
		add_child(name)
	var top := HBoxContainer.new()
	top.position = Vector2(30, 24)
	top.add_theme_constant_override("separation", 20)
	add_child(top)
	var back := JksUI.icon_button("icons/back", "ButtonYellow")
	back.pressed.connect(func(): JksUI.go("subjects"))
	top.add_child(back)
	var icon := TextureRect.new()
	icon.texture = EduAssets.texture(Jks.ICON[Jks.subject])
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.custom_minimum_size = Vector2(96, 96)
	top.add_child(icon)
	var title := "%s · %s" % [Jks.subject_name(Jks.subject), GameState.tr2("Tahun %d", "Year %d") % Jks.year]
	if Jks.teams > 0:
		title += " · " + GameState.tr2("%d pasukan", "%d teams") % Jks.teams
	top.add_child(JksUI.title(title, "LabelTitle"))
	var stars := JksUI.title("★ %d / 15" % GameState.total_stars(gid), "LabelHeading", Color("ffd166"))
	stars.position = Vector2(1640, 40)
	add_child(stars)
	Audio.music("jelajah_santai")
	KitUtil.maybe_shot(self, "jks_stages", 1.5)
