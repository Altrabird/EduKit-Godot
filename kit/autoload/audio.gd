## Audio autoload: SFX / music / voice on their own buses so settings can mix them.
##   Audio.sfx("correct")                  -> assets/audio/sfx/correct.wav
##   Audio.music("menu_ceria")             -> loops, cross-fades from the current track
##   Audio.say("feedback", "correct")      -> voice in GameState.lang (ms / en)
##   Audio.say_vocab("sains", "planet_earth")
extends Node

const SFX_DIR := "res://assets/audio/sfx/"
const MUSIC_DIR := "res://assets/audio/music/"
const VOICE_DIR := "res://assets/audio/voice/"
const BUSES := ["Music", "SFX", "Voice"]

var _sfx_players: Array[AudioStreamPlayer] = []
var _music_a := AudioStreamPlayer.new()
var _music_b := AudioStreamPlayer.new()
var _voice := AudioStreamPlayer.new()
var _cache := {}
var current_music := ""


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for bus in BUSES:
		if AudioServer.get_bus_index(bus) == -1:
			AudioServer.add_bus()
			AudioServer.set_bus_name(AudioServer.bus_count - 1, bus)
	for i in 8:
		var p := AudioStreamPlayer.new()
		p.bus = "SFX"
		add_child(p)
		_sfx_players.append(p)
	for p in [_music_a, _music_b]:
		p.bus = "Music"
		add_child(p)
	_voice.bus = "Voice"
	add_child(_voice)


func _stream(path: String) -> AudioStream:
	if not _cache.has(path):
		_cache[path] = load(path) if ResourceLoader.exists(path) else null
		if _cache[path] == null:
			push_warning("Audio: missing " + path)
	return _cache[path]


## Plays a sound effect; pitch_jitter gives repeated sounds (clicks, pops) some life.
func sfx(sfx_name: String, pitch_jitter := 0.0, volume_db := 0.0) -> void:
	var s := _stream(SFX_DIR + sfx_name + ".wav")
	if s == null:
		return
	var p := _sfx_players[0]  # all busy -> steal the first
	for x in _sfx_players:
		if not x.playing:
			p = x
			break
	p.stream = s
	p.pitch_scale = 1.0 + randf_range(-pitch_jitter, pitch_jitter)
	p.volume_db = volume_db
	p.play()


func music(track: String, fade := 0.8) -> void:
	if track == current_music:
		return
	current_music = track
	var s := _stream(MUSIC_DIR + track + ".ogg")
	if s == null:
		return
	if s is AudioStreamOggVorbis and not track.begins_with("jingle"):
		s.loop = true
	var old := _music_a if _music_a.playing else _music_b
	var new := _music_b if old == _music_a else _music_a
	new.stream = s
	new.volume_db = -40.0
	new.play()
	var tw := create_tween().set_parallel()
	tw.tween_property(new, "volume_db", 0.0, fade)
	if old.playing:
		tw.tween_property(old, "volume_db", -40.0, fade)
		tw.chain().tween_callback(old.stop)


func stop_music(fade := 0.6) -> void:
	current_music = ""
	for p in [_music_a, _music_b]:
		if p.playing:
			create_tween().tween_property(p, "volume_db", -40.0, fade).finished.connect(p.stop)


## Speaks a pre-recorded line. Returns false if the clip doesn't exist in that language.
func say(group: String, id: String, lang := "") -> bool:
	lang = lang if lang != "" else GameState.lang
	var s := _stream("%s%s/%s/%s.mp3" % [VOICE_DIR, lang, group, id])
	if s == null:
		return false
	_voice.stream = s
	_voice.play()
	return true


func say_vocab(subject: String, id: String, lang := "") -> bool:
	return say("vocab/" + subject, id, lang)


func say_number(n: int, lang := "") -> bool:
	return say("numbers", str(n), lang)


func is_speaking() -> bool:
	return _voice.playing


## Linear 0..1 volume for a bus ("Music", "SFX", "Voice", "Master").
func set_volume(bus: String, linear: float) -> void:
	var i := AudioServer.get_bus_index(bus)
	if i >= 0:
		AudioServer.set_bus_volume_db(i, linear_to_db(maxf(linear, 0.0001)))
		AudioServer.set_bus_mute(i, linear <= 0.001)
