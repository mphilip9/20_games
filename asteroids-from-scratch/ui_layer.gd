extends CanvasLayer
@onready var pause_menu: MarginContainer = $PauseMenu


func show_pause():
	pause_menu.visible = !pause_menu.visible
func pause_game() -> void:
	get_tree().paused = !get_tree().paused




func _input(event):
	if event.is_action_pressed("pause"):
		show_pause()
		pause_game()
