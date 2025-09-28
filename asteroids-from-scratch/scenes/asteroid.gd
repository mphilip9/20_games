extends Area2D


@export var speed: float = 50
@export var direction: Vector2
@export var rotation_speed: float
@export var size: float = 2
@export var death_animation: PackedScene
@export var wave_spawn: bool
@export var score: int = 0
var is_destroyed: bool = false

signal asteroid_destroyed(pos: Vector2, size: int, speed: float)

var screen_size: Vector2
var _self_scene: PackedScene

func spawn_on_periphery() -> void:
	# Choose a random edge: 0=top, 1=right, 2=bottom, 3=left
	var edge = randi() % 4
	var spawn_pos: Vector2
	var target_pos: Vector2

	match edge:
		0: # Top edge
			spawn_pos = Vector2(randf() * screen_size.x, -50)
			target_pos = Vector2(randf() * screen_size.x, screen_size.y + 50)
		1: # Right edge
			spawn_pos = Vector2(screen_size.x + 50, randf() * screen_size.y)
			target_pos = Vector2(-50, randf() * screen_size.y)
		2: # Bottom edge
			spawn_pos = Vector2(randf() * screen_size.x, screen_size.y + 50)
			target_pos = Vector2(randf() * screen_size.x, -50)
		3: # Left edge
			spawn_pos = Vector2(-50, randf() * screen_size.y)
			target_pos = Vector2(screen_size.x + 50, randf() * screen_size.y)

	# Set position
	global_position = spawn_pos
func _ready() -> void:
	speed = GameManager.asteroid_speed()
	if size < 1:
		scale = Vector2(.7, .7)
	else:
		scale = Vector2(size, size)
	screen_size = get_viewport().get_visible_rect().size
	if wave_spawn:
		spawn_on_periphery()
 	# Random movement direction
	direction = Vector2.from_angle(randf() * TAU)

	# Random rotation speed (radians per second)
	rotation_speed = randf_range(-2.0, 2.0)  # Adjust range as needed

# Bullet direction is determined by Player
# Bullet launches in a given direction for a given time
# Bullet does either times out or hits something
# The logic for hitting something is handled the area or body2d that it enters

func wrap_around_screen():
	# wrapf(value, min, max) wraps the value between min and max
	position.x = wrapf(position.x, 0, screen_size.x)
	position.y = wrapf(position.y, 0, screen_size.y)

func _physics_process(delta):
	if is_destroyed:
		return
	position += direction * speed * delta
	rotation += rotation_speed * delta
	wrap_around_screen()

func trigger_death_animation() -> void:
	var death_particles = death_animation.instantiate()
	death_particles.position = position
	death_particles.one_shot = true
	var scale = size * 0.5
	death_particles.scale = Vector2(scale, scale)
	get_parent().add_child(death_particles)


func _on_area_entered(area: Area2D) -> void:
	if is_destroyed:
		return
	is_destroyed = true
	trigger_death_animation()
	asteroid_destroyed.emit(position, size, speed)

	AudioManager.play("res://sounds/kenney_sci-fi-sounds/Audio/lowFrequency_explosion_000.ogg")
	queue_free()
