## One round: 10 questions (the 10th is the boss), timer by stage, streak multiplier,
## three lifelines (50:50, hint, skip). Solo records stars; class mode rotates teams
## question by question and ends on a podium.
extends Control

var card := QuizCard.new()
var _robo := Character2D.new()
var _kenny := Character2D.new()
var _score := ScoreCounter.new()
var _progress := Label.new()
var _streak_lbl := Label.new()
var _bubble := PanelContainer.new()
var _bubble_lbl := Label.new()
var _turn := Label.new()
var _board := VBoxContainer.new()
var _results := ResultsPanel.new()
var _podium := PanelContainer.new()
var _life := {}  # name -> Button

var qs: Array = []
var i := 0
var correct := 0
var points := 0
var streak := 0
var team_points: Array = []
var team_lifelines: Array = []  # per team (or one entry in solo): {"fifty": bool, "hint": bool, "skip": bool}


func _ready() -> void:
	var st: Array = Jks.STAGES[Jks.stage - 1]
	KitUtil.background(self, st[2])
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.18)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(dim)
	_robo.char_id = "robo"
	_robo.height_px = 430
	_robo.position = Vector2(190, 1060)
	add_child(_robo)
	_kenny.char_id = "kenyalang"
	_kenny.height_px = 380
	_kenny.position = Vector2(1740, 1060)
	add_child(_kenny)
	card.time_limit = float(st[3])
	card.position = Vector2(420, 130)
	card.custom_minimum_size = Vector2(1100, 0)
	card.answered.connect(_on_answered)
	add_child(card)
	_build_hud()
	_build_lifelines()
	_build_bubble()
	_results.process_mode = Node.PROCESS_MODE_ALWAYS
	_results.retry.connect(func(): get_tree().reload_current_scene())
	_results.next.connect(_next_stage)
	_results.menu.connect(func(): JksUI.go("stages"))
	add_child(_results)
	_build_podium()
	var n_teams := maxi(Jks.teams, 1)
	team_points.resize(n_teams)
	team_points.fill(0)
	for t in n_teams:
		team_lifelines.append({"fifty": true, "hint": true, "skip": true})
	_refresh_board()
	qs = Jks.build_round()
	Audio.music("quiz_berfikir")
	Audio.say("feedback", "lets_start")
	_show()
	KitUtil.maybe_shot(self, "jks_play", 2.5)


func _team() -> int:
	return i % Jks.teams if Jks.teams > 0 else 0


# ---------------- HUD ----------------
func _build_hud() -> void:
	var top := HBoxContainer.new()
	top.position = Vector2(24, 20)
	top.size = Vector2(1872, 96)
	top.add_theme_constant_override("separation", 18)
	add_child(top)
	var home := JksUI.icon_button("icons/home", "ButtonYellow", 88)
	home.pressed.connect(func(): JksUI.go("stages"))
	top.add_child(home)
	_progress.theme_type_variation = "LabelHeading"
	_progress.add_theme_color_override("font_color", Color.WHITE)
	_progress.add_theme_color_override("font_outline_color", Color("2b2d42"))
	_progress.add_theme_constant_override("outline_size", 10)
	_progress.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(_progress)
	_streak_lbl.theme_type_variation = "LabelHeading"
	_streak_lbl.add_theme_color_override("font_color", Color("ffd166"))
	_streak_lbl.add_theme_color_override("font_outline_color", Color("2b2d42"))
	_streak_lbl.add_theme_constant_override("outline_size", 10)
	top.add_child(_streak_lbl)
	if Jks.teams == 0:
		top.add_child(_score)
	_turn.theme_type_variation = "LabelTitle"
	_turn.add_theme_color_override("font_outline_color", Color("2b2d42"))
	_turn.add_theme_constant_override("outline_size", 14)
	_turn.position = Vector2(400, 1000)
	_turn.size = Vector2(1120, 70)
	_turn.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(_turn)
	_board.position = Vector2(1560, 140)
	_board.add_theme_constant_override("separation", 8)
	add_child(_board)


func _refresh_board() -> void:
	for c in _board.get_children():
		c.queue_free()
	if Jks.teams == 0:
		return
	for t in Jks.teams:
		var p := PanelContainer.new()
		var sb := StyleBoxFlat.new()
		sb.bg_color = Jks.TEAMS[t][2]
		sb.set_corner_radius_all(16)
		sb.set_border_width_all(4 if t != _team() else 8)
		sb.border_color = Color("2b2d42") if t != _team() else Color.WHITE
		sb.content_margin_left = 16
		sb.content_margin_right = 16
		sb.content_margin_top = 6
		sb.content_margin_bottom = 6
		p.add_theme_stylebox_override("panel", sb)
		var l := Label.new()
		l.text = "%s  %d" % [Jks.TEAMS[t][0 if GameState.lang == "ms" else 1], team_points[t]]
		l.theme_type_variation = "LabelHeading"
		l.add_theme_color_override("font_color", Color.WHITE)
		l.add_theme_color_override("font_outline_color", Color("2b2d42"))
		l.add_theme_constant_override("outline_size", 8)
		p.add_child(l)
		_board.add_child(p)


func _build_lifelines() -> void:
	var col := VBoxContainer.new()
	col.position = Vector2(40, 170)
	col.add_theme_constant_override("separation", 14)
	add_child(col)
	for l in [["fifty", "50:50", "", "ButtonPurple"], ["hint", GameState.tr2("Petunjuk", "Hint"), "icons/hint", "ButtonYellow"],
			["skip", GameState.tr2("Langkau", "Skip"), "icons/next", "ButtonTeal"]]:
		var b := JksUI.button(l[1], l[3], l[2], Vector2(250, 100))
		b.add_theme_font_size_override("font_size", 28)
		b.tooltip_text = {"fifty": GameState.tr2("Buang 2 jawapan salah", "Remove 2 wrong answers"),
			"hint": GameState.tr2("Petunjuk daripada Robo", "Hint from Robo"), "skip": GameState.tr2("Langkau soalan", "Skip question")}[l[0]]
		b.pressed.connect(_use_lifeline.bind(l[0]))
		col.add_child(b)
		_life[l[0]] = b


func _build_bubble() -> void:
	_bubble.theme_type_variation = "PanelCream"
	_bubble.position = Vector2(60, 560)
	_bubble.custom_minimum_size = Vector2(330, 0)
	_bubble_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_bubble_lbl.custom_minimum_size = Vector2(290, 0)
	_bubble.add_child(_bubble_lbl)
	_bubble.hide()
	add_child(_bubble)


func _say(text: String, seconds := 4.0) -> void:
	_bubble_lbl.text = text
	_bubble.show()
	_robo.talk(1.5)
	get_tree().create_timer(seconds).timeout.connect(func(): if _bubble_lbl.text == text: _bubble.hide())


# ---------------- flow ----------------
func _show() -> void:
	var q: Dictionary = qs[i]
	var boss: bool = q.get("boss", false)
	_progress.text = "%s · %s %d / %d" % [Jks.stage_name(Jks.stage), GameState.tr2("Soalan", "Question"), i + 1, qs.size()]
	_streak_lbl.text = (GameState.tr2("Kombo x%d", "Combo x%d") % Jks.multiplier(streak)) if Jks.multiplier(streak) > 1 else ""
	_robo.expression = "thinking"
	_kenny.expression = "neutral"
	var ll: Dictionary = team_lifelines[_team()]
	for k in _life:
		_life[k].disabled = not ll[k] or boss
	if Jks.teams > 0:
		_turn.text = GameState.tr2("Giliran: ", "Turn: ") + Jks.team_name(_team())
		_turn.add_theme_color_override("font_color", Jks.TEAMS[_team()][2])
		_refresh_board()
	if boss:
		Audio.sfx("powerup")
		_say(GameState.tr2("SOALAN BOS! Mata berganda!", "BOSS QUESTION! Double points!"), 3.0)
		Feedback.float_text(self, GameState.tr2("SOALAN BOS!", "BOSS QUESTION!"), Vector2(760, 60), Color("ef476f"))
	card.time_limit = float(Jks.STAGES[Jks.stage - 1][3]) * (1.5 if boss else 1.0)
	card.show_question(q)


func _on_answered(ok: bool, _idx: int) -> void:
	var q: Dictionary = qs[i]
	var boss: bool = q.get("boss", false)
	if ok:
		streak += 1
		correct += 1
		var p := Jks.points(card.time_left(), streak, boss)
		points += p
		team_points[_team()] += p
		if Jks.teams == 0:
			_score.add(p)
		Feedback.float_text(self, "+%d" % p, Vector2(900, 80))
		_robo.react(true)
		if streak in [3, 5]:
			_kenny.cheer()
			Audio.sfx("combo")
			_say(GameState.tr2("Hebat! %d berturut-turut! x%d" % [streak, Jks.multiplier(streak)], "Amazing! %d in a row! x%d" % [streak, Jks.multiplier(streak)]), 2.5)
	else:
		streak = 0
		_robo.react(false)
	i += 1
	if i >= qs.size():
		_finish()
	else:
		_show()


func _use_lifeline(kind: String) -> void:
	if card.is_locked():
		return
	team_lifelines[_team()][kind] = false
	_life[kind].disabled = true
	Audio.sfx("powerup")
	var q: Dictionary = qs[i]
	match kind:
		"fifty":
			card.eliminate(2)
		"hint":
			_say(Jks.hint(q), 6.0)
		"skip":
			card.cancel()
			var keys: Array = qs.map(func(x): return str(x.text) + "|" + str(x.get("image", "")))
			qs[i] = Jks.one(q.get("subject", Jks.subject) if Jks.subject == Jks.MIXED else Jks.subject, keys)
			_show()


func _finish() -> void:
	card.hide()
	_turn.text = ""
	for k in _life:
		_life[k].hide()
	if Jks.teams > 0:
		_show_podium()
		return
	var stars := StarRating.stars_for(correct, qs.size())
	var best := GameState.record_level(Jks.game_id(), Jks.stage, stars, points)
	if stars >= 2:
		_robo.cheer()
		_kenny.cheer()
	_results.open(correct, qs.size())
	if best and stars > 0:
		Audio.say("feedback", "new_record")
	var pts := JksUI.title(GameState.tr2("Mata: %d", "Points: %d") % points, "LabelHeading", Color("ffd166"))
	pts.position = Vector2(760, 870)
	pts.size = Vector2(400, 60)
	add_child(pts)


func _next_stage() -> void:
	if Jks.stage < 5 and GameState.is_unlocked(Jks.game_id(), Jks.stage + 1):
		Jks.stage += 1
		get_tree().reload_current_scene()
	else:
		JksUI.go("stages")


# ---------------- class-mode podium ----------------
func _build_podium() -> void:
	_podium.theme_type_variation = "PanelCream"
	_podium.custom_minimum_size = Vector2(900, 620)
	_podium.position = Vector2(510, 200)
	_podium.hide()
	add_child(_podium)


func _show_podium() -> void:
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 14)
	_podium.add_child(v)
	v.add_child(JksUI.title(GameState.tr2("Keputusan Pasukan", "Team Results"), "LabelTitle", Color("3a86ff")))
	var order := range(Jks.teams)
	order.sort_custom(func(a, b): return team_points[a] > team_points[b])
	for rank in order.size():
		var t: int = order[rank]
		var h := HBoxContainer.new()
		h.add_theme_constant_override("separation", 20)
		var medal := TextureRect.new()
		medal.texture = EduAssets.texture(["ui/badge_gold", "ui/badge_silver", "ui/badge_bronze", "icons/star_empty"][mini(rank, 3)])
		medal.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		medal.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		medal.custom_minimum_size = Vector2(90, 100)
		h.add_child(medal)
		var l := JksUI.title("%s — %d" % [Jks.team_name(t), team_points[t]], "LabelHeading", Jks.TEAMS[t][2])
		h.add_child(l)
		v.add_child(h)
	var winner_tie: bool = Jks.teams > 1 and team_points[order[0]] == team_points[order[1]]
	v.add_child(JksUI.title(GameState.tr2("Seri!", "It's a tie!") if winner_tie else (GameState.tr2("Juara: ", "Champion: ") + Jks.team_name(order[0])), "LabelHeading", Color("2b2d42")))
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 20)
	var again := JksUI.button(GameState.tr2("Main lagi", "Play again"), "ButtonGreen", "icons/restart", Vector2(300, 96))
	again.pressed.connect(func(): get_tree().reload_current_scene())
	row.add_child(again)
	var menu := JksUI.button(GameState.tr2("Pentas", "Stages"), "ButtonBlue", "icons/home", Vector2(300, 96))
	menu.pressed.connect(func(): JksUI.go("stages"))
	row.add_child(menu)
	v.add_child(row)
	_podium.show()
	Audio.music("jingle_menang", 0.2)
	Feedback.confetti(self, Vector2(960, 300), 120)
	_robo.cheer()
	_kenny.cheer()
