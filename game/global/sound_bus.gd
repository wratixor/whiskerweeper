extends Node

signal play_action_sfx(action: String, pitch_variation: float)
signal play_bg_music(category: String)
signal music_track_changed(track_name: String, index: int)

const MASTER_BUS = "Master"
const BG_BUS = "BG"
const SFX_BUS = "SFX"

var master_bus_index: int
var music_bus_index: int
var sfx_bus_index: int

var _music_player: AudioStreamPlayer
var _current_music_index: int = -1
var _current_music_category: String = ""
var _music_autoplay: bool = true

var _sounds: Dictionary = {}
var _music_tracks: Dictionary = {}

func _ready():
	master_bus_index = AudioServer.get_bus_index(MASTER_BUS)
	music_bus_index = AudioServer.get_bus_index(BG_BUS)
	sfx_bus_index = AudioServer.get_bus_index(SFX_BUS)

	_music_player = AudioStreamPlayer.new()
	_music_player.bus = BG_BUS
	add_child(_music_player)
	_music_player.finished.connect(_on_music_finished)
	
	
	register_action_sounds("meow", [
		preload("res://asset/sound/meow-1.wav"),
		preload("res://asset/sound/meow-2.wav"),
		preload("res://asset/sound/meow-3.wav")
	])
	register_action_sounds("chop", [
		preload("res://asset/sound/chop-1.wav"),
		preload("res://asset/sound/chop-2.wav"),
		preload("res://asset/sound/chop-3.wav")
	])
	register_action_sounds("mark", [
		preload("res://asset/sound/mark-1.wav")
	])
	register_action_sounds("clap", [
		preload("res://asset/sound/clap-1.wav")
	])
	register_action_sounds("ui_click", [
		preload("res://asset/sound/button-click-press.wav")
	])
	register_action_sounds("ui_hover", [
		preload("res://asset/sound/button-click-hover.wav")
	])
	
	register_music_tracks("theme", [
		preload("res://asset/sound/theme-1.mp3"),
		preload("res://asset/sound/theme-2.wav")
	])
	play_action_sfx.connect(play_sfx_action)
	play_bg_music.connect(play_music)
	play_music()

#SoundBus.play_sfx_action.emit("footstep", 0.1)

func register_action_sounds(action: String, streams: Array[AudioStream]) -> void:
	_sounds[action] = streams

func register_music_tracks(category: String, streams: Array[AudioStream]) -> void:
	_music_tracks[category] = streams

# ---------- Музыкальные методы ----------
# Воспроизвести музыку указанной категории (по умолчанию "theme")
func play_music(category: String = "theme", start_random: bool = true) -> void:
	if not _music_tracks.has(category):
		push_error("No music tracks registered for category: ", category)
		return
	var tracks: Array[AudioStream] = _music_tracks[category]
	if tracks.is_empty():
		push_error("Music track array for category '%s' is empty" % category)
		return

	_current_music_category = category
	# Если нужно начать со случайного трека
	if start_random:
		_current_music_index = randi() % tracks.size()
	else:
		_current_music_index = 0  # или можно оставить предыдущий, если он уже в этой категории

	_play_current_music_track()

# Принудительно переключить на следующий случайный трек
func next_music_track() -> void:
	if _current_music_category.is_empty() or not _music_tracks.has(_current_music_category):
		push_warning("No active music category or tracks not found")
		return
	var tracks: Array[AudioStream] = _music_tracks[_current_music_category]
	if tracks.size() <= 1:
		# Если только один трек, просто перезапускаем его
		_music_player.play()
		return

	# Выбираем случайный трек, отличный от текущего (если треков больше 1)
	var new_index
	if tracks.size() == 2:
		# Если два трека, просто переключаем на другой
		new_index = 1 - _current_music_index
	else:
		new_index = randi() % tracks.size()

	_current_music_index = new_index
	_play_current_music_track()

# Воспроизвести текущий трек по индексу _current_music_index
func _play_current_music_track() -> void:
	if _current_music_category.is_empty() or _current_music_index < 0:
		return
	var tracks: Array[AudioStream] = _music_tracks[_current_music_category]
	if _current_music_index >= tracks.size():
		return
	_music_player.stream = tracks[_current_music_index]
	_music_player.play()
	# Испускаем сигнал с именем трека (можно извлечь из ресурса, но для простоты передаём индекс)
	music_track_changed.emit(_current_music_category + str(_current_music_index), _current_music_index)

# Обработчик окончания трека
func _on_music_finished():
	if _music_autoplay:
		next_music_track()


func play_sfx_action(action: String, pitch_variation: float = 0.0) -> void:
	if not _sounds.has(action):
		push_error("No sounds registered for action: ", action)
		return
	var streams: Array[AudioStream] = _sounds[action]
	if streams.is_empty():
		push_error("Sound array for action '%s' is empty" % action)
		return
	var random_stream = streams[randi() % streams.size()]
	play_sound(random_stream, SFX_BUS, pitch_variation)

func play_sound(stream: AudioStream, bus_name: String = SFX_BUS, pitch_variation: float = 0.0) -> void:
	var player = AudioStreamPlayer2D.new()
	player.stream = stream
	player.bus = bus_name
	if pitch_variation > 0:
		player.pitch_scale = 1.0 + randf_range(-pitch_variation, pitch_variation)
	add_child(player)
	player.play()
	player.finished.connect(
		func(): if is_instance_valid(player): player.queue_free(),
		CONNECT_ONE_SHOT)

func _on_sound_finished(player: AudioStreamPlayer) -> void:
	if is_instance_valid(player):
		player.queue_free()
