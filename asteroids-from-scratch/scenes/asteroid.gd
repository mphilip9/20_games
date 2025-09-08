extends Area2D


@export var speed: float = 100
@export var direction: Vector2
@export var rotation_speed: float
@export var size: int = 3
@export var death_animation: PackedScene

signal asteroid_destroyed(pos: Vector2, size: int, speed: float)

var screen_size: Vector2
var _self_scene: PackedScene
func _ready() -> void:
	scale = Vector2(size, size)
	screen_size = get_viewport().get_visible_rect().size
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
	trigger_death_animation()
	asteroid_destroyed.emit(position, size, speed)
	AudioManager.play("res://sounds/kenney_sci-fi-sounds/Audio/lowFrequency_explosion_000.ogg")
	queue_free()
