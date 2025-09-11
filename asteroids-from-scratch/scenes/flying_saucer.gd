extends CharacterBody2D

@export var speed = 100
@export var fire_rate: float = 1.5
@export var bullet_scene: PackedScene
@export var size: float
@export var death_particles_scene: PackedScene
@export var direction: Vector2
var screen_size: Vector2
@onready var bullet_timer: Timer = $BulletTimer
@onready var engine_sound: AudioStreamPlayer2D = $EngineSound
@onready var flying_saucer_sprite: AnimatedSprite2D = $FlyingSaucerSprite



# The ship needs to fire bullets in the general direction of the player
# We could track the position of the player in GameManager
# And then fire in that direction, with a bit of inaccuracy added
func spawn_somewhere() -> void:
	# Randomly choose left (0) or right (1) side
	var spawn_side = randi() % 2

	if spawn_side == 0:
		global_position = Vector2(-50, randf() * screen_size.y)
		direction = Vector2(1, 0)
	else:
		global_position = Vector2(screen_size.x + 50, randf() * screen_size.y)
		direction = Vector2(-1, 0)
func _ready() -> void:
	scale = Vector2(size, size)
	flying_saucer_sprite.play("fly")
	bullet_timer.wait_time = fire_rate
	bullet_timer.start()
	screen_size = get_viewport().get_visible_rect().size
	spawn_somewhere()

func wrap_around_screen():
	# wrapf(value, min, max) wraps the value between min and max
	position.x = wrapf(position.x, 0, screen_size.x)
	position.y = wrapf(position.y, 0, screen_size.y)

func get_input():
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = direction * speed

func _physics_process(delta):
	get_input()
	move_and_slide()
	#wrap_around_screen()

func trigger_death_animation() -> void:
	var death_particles = death_particles_scene.instantiate()
	death_particles.position = position
	death_particles.one_shot = true
	death_particles.scale = Vector2(0.5, 0.5)
	get_parent().add_child(death_particles)

func kill_saucer() -> void:
	AudioManager.play("res://sounds/kenney_sci-fi-sounds/Audio/explosionCrunch_000.ogg")
	trigger_death_animation()
	GameManager.ufos_count -= 1
	if size < 1:
		GameManager.score += 700
	else:
		GameManager.score += 500
	queue_free()

func _on_hitbox_area_entered(area: Area2D) -> void:
	kill_saucer()

func shoot_bullet() -> void:
	AudioManager.play("res://sounds/kenney_sci-fi-sounds/Audio/laserSmall_001.ogg")

	var b = bullet_scene.instantiate()
	b.position = position
	#b.rotation = rotation
	var direction_to_player = (GameManager.player_pos - position).normalized()

	var inaccuracy_angle = randf_range(-0.5, 0.5)
	var final_direction = direction_to_player.rotated(inaccuracy_angle)

	b.direction = final_direction
	b.rotation = final_direction.angle() + PI/2 # +90° if bullet sprite points up
	if size < 1:
		b.speed = 600

	get_parent().add_child(b)

func _on_bullet_timer_timeout() -> void:
	shoot_bullet()
