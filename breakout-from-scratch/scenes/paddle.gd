extends CharacterBody2D

@export var speed = 600
@export var initial_width: float = 150.0  # Set to your paddle's starting width
@export var min_width: float = 75.0

func _process(delta: float) -> void:
	if GameManager.ceiling_hit:
		var new_width = min_width
		var shape = get_node("CollisionShape2D").shape as RectangleShape2D
		shape.size.x = new_width

		if has_node("ColorRect"):
			var color_rect = get_node("ColorRect")
			var old_width = color_rect.size.x
			color_rect.size.x = new_width
			# Adjust position to keep it centered
			color_rect.position.x += (old_width - new_width) / 2

func _ready() -> void:
	var shape = get_node("CollisionShape2D").shape as RectangleShape2D
	shape.size.x = initial_width
	if has_node("ColorRect"):
		var texture_rect = get_node("ColorRect")
		texture_rect.size.x = initial_width

func get_input():
	var direction: Vector2 = Vector2(0,0)

	if Input.is_action_pressed('left'):
		direction = Vector2(-1, 0)
	elif Input.is_action_pressed('right'):
		direction = Vector2(1,0)

	velocity = direction * speed

func _physics_process(delta):
	get_input()
	move_and_slide()

# Move the character from left to right only


func _on_next_level_finished() -> void:
	pass # Replace with function body.
