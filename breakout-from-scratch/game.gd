extends Node2D
@onready var paddle: CharacterBody2D = $Paddle
@onready var ball: CharacterBody2D = $Ball
@onready var start_menu: MarginContainer = $"UI/Control/Start Menu"
@onready var lives_container: HBoxContainer = $UI/Control/MarginContainer/StatsBox/Lives2
@onready var score: Label = $UI/Control/MarginContainer/StatsBox/Score
@onready var game_over_container: VBoxContainer = $UI/Control/GameOverContainer
@onready var next_level: AudioStreamPlayer2D = $Sounds/NextLevel
@onready var quit_sound: AudioStreamPlayer2D = $Sounds/QuitSound
@onready var music: AudioStreamPlayer2D = $Sounds/Music

@export var brick_scene: PackedScene

var lives: int = 3
var ball_launched = false

func add_bricks() -> void:
	var brick_width: int = 70
	var brick_height: int = 30
	var screen_width: int = 1000
	var margin: int = 10  # Few pixels on each side
	var rows: int = 1 + GameManager.current_level
	var start_y: int = 50
	# Calculate how many bricks fit and spacing
	var available_width = screen_width - (2 * margin)
	var bricks_per_row = 12  # You can adjust this
	var total_brick_width = bricks_per_row * brick_width
	var total_spacing_width = available_width - total_brick_width
	var spacing = total_spacing_width / (bricks_per_row - 1)  # Space between bricks
	GameManager.brick_count = rows * bricks_per_row

	var start_x = margin
	var row_colors = [
	   Color.RED,
	   Color.ORANGE,
	   Color.YELLOW,
	   Color.GREEN,
	   Color.BLUE
   ]

	for row in range(rows):
		for col in range(bricks_per_row):
			var brick = brick_scene.instantiate()
			var x_pos = start_x + col * (brick_width + spacing)
			var y_pos = start_y + row * (brick_height + 5)  # Small vertical spacing

			brick.global_position = Vector2(x_pos, y_pos)
			brick.modulate = row_colors[row % row_colors.size()]  # Cycle through colors
			add_child(brick)

func _process(delta: float) -> void:
	score.text = str(GameManager.score)
	if GameManager.brick_count == 0:
		GameManager.next_level()
	if lives < 0:
		quit_sound.play()

		get_tree().paused = true
		game_over_container.visible = true
	if Input.is_action_pressed('launch_ball') and !ball_launched:
		start_menu.visible = false
		ball_launched = true
		ball.launch_ball()
	if !ball_launched:
		var paddle_collision_node = paddle.get_node("CollisionShape2D")
		var paddle_center_x = paddle.to_global(paddle_collision_node.position).x
		ball.global_position.x = paddle_center_x
		ball.global_position.y = paddle.global_position.y - 50

func reset_ball():
	# Stop the ball
	ball.velocity = Vector2.ZERO
	ball_launched = false

func _ready() -> void:
	next_level.play()
	add_bricks()
	var screen_center_x = DisplayServer.window_get_size().x / 2

	# Get paddle width and center it
	var paddle_shape = paddle.get_node("CollisionShape2D").shape as RectangleShape2D
	paddle.global_position.x = screen_center_x - paddle_shape.size.x / 2

func lose_life():
	lives -= 1
	update_lives_display()
	reset_ball()

func update_lives_display():
	var life_icons = lives_container.get_children()
	for i in range(life_icons.size()):
		life_icons[i].visible = i < lives


func _on_goal_body_entered(body: Node2D) -> void:
	lose_life()


func _on_restart_button_pressed() -> void:
	get_tree().paused = false
	GameManager.reset_game()
	get_tree().reload_current_scene()


func _on_ceiling_goal_body_entered(body: Node2D) -> void:
	GameManager.ceiling_hit = true
