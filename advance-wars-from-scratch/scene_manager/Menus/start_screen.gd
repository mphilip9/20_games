extends Control

func _on_start_button_pressed() -> void:
	SceneManager.swap_scenes("res://scene_manager/gameplay.tscn", get_tree().root, self, "start_wipe_from_right")

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		SceneManager.swap_scenes("res://scene_manager/gameplay.tscn", get_tree().root, self, "start_wipe_from_right")
