extends Node2D

func _ready() -> void:
	SoundManager.play_music("res://assets/Drifting-Off_Looping.mp3")

func _on_button_pressed() -> void:
	SceneManager.swap_scenes("res://scene_manager/Menus/start_screen.tscn", get_tree().root, self, "start_wipe_from_right")
