extends Area2D


@export var speed: float = 600
@export var direction: Vector2
@export var bullet_sound: String
var screen_size: Vector2

func _ready() -> void:
	AudioManager.play(bullet_sound)
	screen_size = get_viewport().get_visible_rect().size

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

	wrap_around_screen()


func _on_area_exited(area: Area2D) -> void:
	print('should the bullet be destroyed??')
	queue_free()


func _on_timer_timeout() -> void:
	queue_free()
