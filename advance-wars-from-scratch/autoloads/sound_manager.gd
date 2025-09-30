# Audio.gd - Combined audio manager
extends Node

const POOL_SIZE: int = 10
# These two buses are initializes/setup in the Audio tab (to the right of Debugger)
const MUSIC_BUS: String = "Music"
const SFX_BUS: String = "SFX"

var sfx_pool: Array[AudioStreamPlayer] = []
var available_players: Array[AudioStreamPlayer] = []
var music_player: AudioStreamPlayer
func _ready() -> void:
#
	# Create music player
	music_player = AudioStreamPlayer.new()
	music_player.bus = MUSIC_BUS
	music_player.process_mode = Node.PROCESS_MODE_ALWAYS # Allows music to play even when game is paused
	add_child(music_player)

	# Create SFX pool
	for i in POOL_SIZE:
		var player: AudioStreamPlayer = AudioStreamPlayer.new()
#		NOTE: You may want the SFX bus to also always be 'on'
		player.bus = SFX_BUS
		player.finished.connect(_on_sfx_finished.bind(player))
		add_child(player)
		sfx_pool.append(player)
		available_players.append(player)

func play_sfx(music_path: String) -> void:
#	No need to 'mute' sfc bc they get played the one time. Easier just to block the sound from ever getting played
	if not Settings.play_sfx or available_players.is_empty():
		return
	var stream: AudioStream = load(music_path)
	if stream == null:
		push_error("Failed to load music: " + music_path)
		return
	var player: AudioStreamPlayer = available_players.pop_front()
	player.stream = stream
	player.play()

func play_music(music_path: String, fade_in: bool = false) -> void:
	#if not Settings.play_music:
		#return
	if not Settings.play_music:
		var idx: int = AudioServer.get_bus_index("Music")

		AudioServer.set_bus_mute(idx, true)
	var stream: AudioStream = load(music_path)
	if stream == null:
		push_error("Failed to load music: " + music_path)
		return

	music_player.stream = stream
	music_player.play()

	if fade_in:
		var tween: Tween = create_tween()
		music_player.volume_db = -20.0
		tween.tween_property(music_player, "volume_db", 0.0, 1.0)





func stop_music(fade_out: bool = false) -> void:
	if fade_out:
		var tween: Tween = create_tween()
		tween.tween_property(music_player, "volume_db", -20.0, 1.0)
		tween.tween_callback(music_player.stop)
	else:
		music_player.stop()

func _on_sfx_finished(player: AudioStreamPlayer) -> void:
	available_players.append(player)
