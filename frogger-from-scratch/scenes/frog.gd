extends CharacterBody2D

@onready var frog_sprite: AnimatedSprite2D = $FrogSprite
@onready var water_check_timer: Timer = Timer.new()
@onready var frog_jump: AudioStreamPlayer2D = $FrogJump
@onready var death_sound: AudioStreamPlayer2D = $DeathSound
@onready var run_timer: Timer = $RunTimer

var tile_size = 16
var is_moving = false
var starting_position: Vector2
var platform_velocity: Vector2 = Vector2.ZERO
var in_water_area: bool = false
var is_dead: bool = false


signal death(frog_node)
signal lilypad_reached(frog_node, complete)

var current_platform: AnimatableBody2D

func _ready():
	#frog_sprite.play('idle')
	# Setup the water check timer
	add_child(water_check_timer)
	water_check_timer.wait_time = 0.15  # Grace period in seconds
	water_check_timer.one_shot = true
	water_check_timer.timeout.connect(_on_water_check_timeout)

func _process(delta: float):
	GameManager.time = run_timer.time_left

func _physics_process(delta):
	# Check if standing on a moving platform
	if not is_moving and current_platform:
		position += current_platform.velocity * delta

	if not is_moving:
		handle_input()

func check_for_platform():
	# Cast a ray downward to detect platforms
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(
		global_position,
		global_position + Vector2(0, 2)  # Small downward ray
	)

	var result = space_state.intersect_ray(query)
	print(result)

	if result and result.collider is AnimatableBody2D:
		platform_velocity = result.collider.velocity
	else:
		platform_velocity = Vector2.ZERO

func handle_input():
	if is_dead:
		return
	var input_dir = Vector2.ZERO

	if Input.is_action_just_pressed("left"):
		input_dir = Vector2.LEFT
		frog_sprite.flip_h = false
	elif Input.is_action_just_pressed("right"):
		input_dir = Vector2.RIGHT
		frog_sprite.flip_h = true
	elif Input.is_action_just_pressed("up"):
		input_dir = Vector2.UP
	elif Input.is_action_just_pressed("down"):
		input_dir = Vector2.DOWN

	if input_dir != Vector2.ZERO:
		if position.y == starting_position.y and input_dir == Vector2.DOWN:
			pass
		else:
			move_to_tile(input_dir)

func move_to_tile(direction: Vector2):
	frog_sprite.play('jump')
	frog_jump.play()
	is_moving = true
	var target_position = position + direction * tile_size

	var tween = create_tween()
	tween.tween_property(self, "position", target_position, 0.2)
	await tween.finished

	is_moving = false
	if !is_dead:
		frog_sprite.play('idle')
	# After landing, check if we're in water and not on a platform
	if in_water_area:
		_check_water_death()

func _check_water_death():
	# Only kill if in water, not moving, and not on a platform
	if in_water_area and not is_moving and not current_platform:
		is_dead = true
		death_sound.play()
		frog_sprite.play('water_death')


func _on_water_check_timeout():
	_check_water_death()

# Connected to the Area2D signals
func _on_area_2d_body_entered(body: Node2D) -> void:
	if is_dead:
		return
	if body.is_in_group('car'):
		#death.emit(self)
		is_dead = true

		death_sound.play()

		frog_sprite.play('death')

	elif body is AnimatableBody2D:
		current_platform = body
		water_check_timer.stop()



func _on_area_2d_area_entered(area: Area2D) -> void:
	print(area)
	if area.is_in_group('kill_area'):
		is_dead = true

		death_sound.play()

		frog_sprite.play('death')
	if area.is_in_group('lilypad'):
		var complete = area.get_parent().status_complete
		if !complete:
			area.get_parent().complete_lilypad()
		lilypad_reached.emit(self, complete)
		water_check_timer.stop()
		return
	# Assuming this is the water area
	if area.is_in_group('water'):
		in_water_area = true
	# Only start death timer if not currently jumping and not on a platform

	elif not is_moving and not current_platform and in_water_area:
		water_check_timer.start()

func _on_area_2d_area_exited(area: Area2D) -> void:
	# Left the water area
	in_water_area = false
	water_check_timer.stop()  # Cancel any pending death check

func _on_area_2d_body_exited(body: Node2D) -> void:

	if body is AnimatableBody2D and body == current_platform:
		current_platform = null

		# If we left a platform and we're still in water, start the death timer
		if in_water_area and not is_moving:
			water_check_timer.start()




func _on_death_sound_finished() -> void:
	death.emit(self)


func _on_run_timer_timeout() -> void:
	death_sound.play()
	frog_sprite.play('death')
