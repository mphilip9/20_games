extends Control
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var pause_menu: Control = $"."
@onready var settings_menu: Control = %SettingsMenu


func _ready() -> void:
	pause_menu.visible = false
	animation_player.play("RESET") # This ensures the panel and color rect begin in the right state



func resume() -> void:
	animation_player.play_backwards('blur')
	await animation_player.animation_finished
	get_tree().paused = false

	pause_menu.visible = false

func pause() -> void:
	get_tree().paused = true
	pause_menu.visible = true

	animation_player.play('blur')


func testEsc() -> void:
	if Input.is_action_just_pressed("esc") and !get_tree().paused:
		pause()
	elif Input.is_action_just_pressed("esc") and get_tree().paused:
		resume()


func _on_resume_pressed() -> void:
	resume()

func _on_quit_pressed() -> void:
	get_tree().paused = false
	SoundManager.stop_music()
	SceneManager.swap_scenes(Scenes.START_SCREEN, get_tree().root, get_parent(), "start_wipe_from_right")

func _process(_delta: float) -> void:
	testEsc()


func _on_settings_pressed() -> void:
	settings_menu.animation_player.play('blur')
	settings_menu.visible = true
