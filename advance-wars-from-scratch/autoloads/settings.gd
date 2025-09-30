extends Node

var play_sfx: bool = true
var play_music: bool = true
var fullscreen: bool = false
var master_volume: float
var music_volume: float
var sfx_volume: float
var version: String
var show_debug_ui: bool = false
const SCENE_MAIN_MENU = "res://main_menu/main_menu.tscn"
#const EXPORT_CONFIG_FILE := "res://export.cfg"
#const EXPORT_CONFIG_METADATA_SECTION := "metadata"
const SETTINGS_FILE := "user://settings.cfg"
const CONFIG_SETTINGS_SECTION := "settings"

func _ready() -> void:
	print_debug("Settings singleton ready")
	Engine.max_fps = 60
	load_settings()
	#load_game_metadata()

	# hidden by default, can be toggled on in debug mode
	get_tree().call_group("debug_ui", "hide")

func load_settings() -> void:
	var config: ConfigFile = ConfigFile.new()
	var load_res: Error = config.load(SETTINGS_FILE)

	if load_res != OK:
		print("failed to load settings")
		return
	for setting_key in config.get_section_keys(CONFIG_SETTINGS_SECTION):
		set_setting(setting_key, config.get_value(CONFIG_SETTINGS_SECTION, setting_key), false)

## persist all settings to disk
## add a new setting in the array to ensure it persists
func save_settings() -> void:
	var config: ConfigFile = ConfigFile.new()
	for setting: String in ["fullscreen", "play_sfx", "play_music", "master_volume", "music_volume", "sfx_volume"]:
		config.set_value(CONFIG_SETTINGS_SECTION, setting, self[setting])
	config.save(SETTINGS_FILE)

## val is a bool representing whether or not to toggle on fullscreen
func set_fullscreen(val: bool) -> void:
	fullscreen = val
	if fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func set_volume(bus_name: String, value: float) -> void:
		var bus_index: int = AudioServer.get_bus_index(bus_name)
		AudioServer.set_bus_volume_db(
			bus_index,
			linear_to_db(value)
		 )

## Assigns the value to ths after one gets set, but can be disabled
## with the `save` argument.e Global setting variable.
## Defaults to saving all settings
func set_setting(setting: String, val: Variant, save := true) -> void:
	self[setting] = val
	match setting:
		"fullscreen":
			set_fullscreen(val)
#			TODO: THis hsould be improved. All it does right now is mute the bus for the music or audio, but the stream is still playing
		"play_music":
			var idx: int = AudioServer.get_bus_index("Music")
			if idx > 0:
				AudioServer.set_bus_mute(idx, not val)
		"play_sfx":
			var idx: int = AudioServer.get_bus_index("SFX")
			if idx > 0:
				AudioServer.set_bus_mute(idx, not val)
		"master_volume":
			set_volume('Master', val)
		"music_volume":
			set_volume('Music', val)
		"sfx_volume":
			set_volume('SFX', val)
	if save:
		save_settings()

## sets the version property from the export.cfg file
#func load_game_metadata() -> void:
	#var config := ConfigFile.new()
	#var load_res := config.load(EXPORT_CONFIG_FILE)
#
	#if load_res != OK:
		#print("failed to load game metadata")
		#return
#
	#version = config.get_value(EXPORT_CONFIG_METADATA_SECTION, "version")

func _input(event: InputEvent) -> void:
	if OS.is_debug_build() and event.is_action_pressed("debug_toggle_ui"):
		show_debug_ui = !show_debug_ui
		print_debug("debug UI toggled, but it is not yet implemented: " + str(show_debug_ui))
		#if show_debug_ui:
			#get_tree().call_group("debug_ui", "show")
		#else:
			#get_tree().call_group("debug_ui", "hide")
