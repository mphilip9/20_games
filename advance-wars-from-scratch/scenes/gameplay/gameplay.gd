extends Node2D

func _ready() -> void:
#	This is just here to show how to play music
	SoundManager.play_music("res://assets/Drifting-Off_Looping.mp3")


func _on_return_button_pressed() -> void:
	SoundManager.stop_music()
	SceneManager.swap_scenes(Scenes.START_SCREEN, get_tree().root, self, "start_wipe_from_right")
