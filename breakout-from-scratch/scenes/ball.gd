
extends CharacterBody2D
@onready var brick_hit_sound: AudioStreamPlayer2D = $BrickHitSound
@onready var paddle_hit: AudioStreamPlayer2D = $PaddleHit

func launch_ball() -> void:
	set_velocity(Vector2(250, 250))

func _physics_process(delta):
	var speed_multiplier = 1.0 + (GameManager.bricks_hit * 0.02)
	var collision_info = move_and_collide(velocity * delta * speed_multiplier)
	if collision_info:
		var collider = collision_info.get_collider()

		if collider.is_in_group("paddle"):
			# Get the paddle's collision shape
			paddle_hit.play()
			var shape = collider.get_node("CollisionShape2D").shape as RectangleShape2D
			var paddle_width = shape.size.x
			var collision_shape_node = collider.get_node("CollisionShape2D")

			# Get the actual global center of the collision shape
			var paddle_center = collider.to_global(collision_shape_node.position).x
			var hit_offset = (global_position.x - paddle_center) / (paddle_width / 2)

			# Apply new velocity
			var speed = velocity.length()
			var new_angle = -PI/2 + hit_offset * PI/4
			velocity = Vector2(cos(new_angle), sin(new_angle)) * speed
		elif collider.is_in_group("brick"):
			velocity = velocity.bounce(collision_info.get_normal())
			collider.queue_free()
			GameManager.hit_brick()
			brick_hit_sound.play()

		else:
			paddle_hit.play()
			velocity = velocity.bounce(collision_info.get_normal())
