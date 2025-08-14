extends Node2D
@onready var player_1_score: Label = $CanvasLayer/UI/MarginContainer/HBoxContainer/MarginContainer2/Player1Container/Player1Score
@onready var player_2_score: Label = $CanvasLayer/UI/MarginContainer/HBoxContainer/MarginContainer/Player2Container/Player2Score
@onready var start_button: Button = $"CanvasLayer/UI/Start Button"
@onready var pause_menu: MarginContainer = $"CanvasLayer/UI/Pause Menu"
@onready var game_over: Label = $"CanvasLayer/UI/Game Over"
@onready var score: AudioStreamPlayer2D = $Node/Score
@onready var game_over_sound: AudioStreamPlayer2D = $Node/GameOver
@onready var start: AudioStreamPlayer2D = $Node/Start

var ball_scene = preload("res://scenes/ball/ball.tscn")

var p1_score: int = 0
var p2_score: int = 0
var win_size: Vector2
var game_in_progress = false


func _process(delta: float) -> void:
	if p1_score > 9 or p2_score > 9:
		game_over_sound.play()
		get_tree().paused = true
		pause_menu.visible = true
		game_over.visible = true

func restart_ball():
		win_size = get_viewport_rect().size
		var new_ball = ball_scene.instantiate()
		new_ball.position.x = win_size.x / 2
		new_ball.position.y = randi_range(200, win_size.y - 200)
		add_child(new_ball)

func _on_goal_2_body_entered(body: Node2D) -> void:
	p2_score += 1
	player_2_score.text = str(p2_score)
	body.queue_free()
	score.play()
	restart_ball()

#Plyer 1 score
func _on_goal_body_entered(body: Node2D) -> void:
	p1_score += 1
	player_1_score.text = str(p1_score)
	body.queue_free()
	score.play()
	restart_ball()


func _on_start_button_pressed() -> void:
	start.play()
	game_in_progress = true
	get_tree().paused = false
	restart_ball()
	start_button.visible = false


func _on_restart_pressed() -> void:
	get_tree().reload_current_scene()
