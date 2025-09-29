extends Control

@onready var settings_v_box_container: VBoxContainer = %SettingsVBoxContainer
@onready var toggle_music: CheckButton = %ToggleMusic
@onready var toggle_sfx: CheckButton = %ToggleSFX
@onready var fullscreen: CheckButton = %Fullscreen

func _ready() -> void:
	# Initialize values
	toggle_music.set_pressed_no_signal(Settings.play_music)
	toggle_sfx.set_pressed_no_signal(Settings.play_sfx)
	fullscreen.set_pressed_no_signal(Settings.fullscreen)


		# Connect signals
	toggle_music.toggled.connect(_on_music_toggled)
	toggle_sfx.toggled.connect(_on_sfx_toggled)
	fullscreen.toggled.connect(_on_fullscreen_toggled)
	# Handle initial focus for keyboard/gamepad navigation
	_grab_first_focus()

func _grab_first_focus() -> void:
	for child in settings_v_box_container.get_children():
		if child.visible and child.focus_mode != Control.FOCUS_NONE:
			child.grab_focus()
			return

func _on_music_toggled(pressed: bool) -> void:
	Settings.set_setting("play_music", pressed)

func _on_sfx_toggled(pressed: bool) -> void:
	Settings.set_setting("play_sfx", pressed)

func _on_fullscreen_toggled(pressed: bool) -> void:
	Settings.set_setting("fullscreen", pressed)
