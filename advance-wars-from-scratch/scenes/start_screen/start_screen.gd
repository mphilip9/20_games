extends Control
@onready var settings_menu: Control = %SettingsMenu

func _on_start_button_pressed() -> void:
	SceneManager.swap_scenes(Scenes.GAMEPLAY, get_tree().root, self, "start_wipe_from_right")

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		SceneManager.swap_scenes(Scenes.GAMEPLAY, get_tree().root, self, "start_wipe_from_right")


func _on_settings_button_pressed() -> void:
	settings_menu.animation_player.play('blur')
	settings_menu.visible = true
