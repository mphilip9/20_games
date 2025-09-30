extends Node2D

func _ready() -> void:
#	This is just here to show how to play music
	SoundManager.play_music("res://assets/Drifting-Off_Looping.mp3")




func _on_sfx_button_pressed() -> void:
	SoundManager.play_sfx("res://assets/Bells2.mp3")


func _on_return_button_pressed() -> void:
	SoundManager.stop_music()
	SceneManager.swap_scenes("res://scene_manager/Menus/start_screen.tscn", get_tree().root, self, "start_wipe_from_right")
