extends CanvasLayer
@onready var pause_menu: MarginContainer = $"UI/Pause Menu"

var paused = false

#func _ready():
	#restart_ball()

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_pressed("pause") and get_parent().game_in_progress:
		paused = !paused
		get_parent().get_tree().paused = paused
		pause_menu.visible = !pause_menu.visible
