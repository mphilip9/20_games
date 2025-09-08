extends CharacterBody2D
@onready var thrust_audio: AudioStreamPlayer2D = $ThrustAudio
@onready var hitbox: Area2D = $Hitbox
@onready var spawn_immunity_timer: Timer = $SpawnImmunityTimer
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var player_sprite: AnimatedSprite2D = $PlayerSprite


@export var bullet: PackedScene
@export var weapon: String
@export var shield: bool = false
@onready var shield_sprite: Sprite2D = $ShieldSprite
@onready var bullet_launch_point: Marker2D = $BulletLaunchPoint
@export var died: bool = false

@export var death_particles_scene: PackedScene


var thrust_power = 200.0
var rotation_speed = 3.0
var drag = 0.98
var screen_size: Vector2
var is_thrusting: bool

signal player_death

func _ready() -> void:
	if died:
		hitbox.monitorable = false
		hitbox.monitoring = false
		spawn_immunity_timer.start()
	screen_size = get_viewport().get_visible_rect().size
	position = screen_size / 2


func shoot_bullet() -> void:
	var b = bullet.instantiate()
	b.position = position
	b.rotation = rotation
	b.direction = -transform.y
	get_parent().add_child(b)


func wrap_around_screen():
	# wrapf(value, min, max) wraps the value between min and max
	position.x = wrapf(position.x, 0, screen_size.x)
	position.y = wrapf(position.y, 0, screen_size.y)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("shoot"):
		shoot_bullet()


func get_input(delta):
	# Handle rotation
	if Input.is_action_pressed("rotate_left"):
		rotation -= rotation_speed * delta
	if Input.is_action_pressed("rotate_right"):
		rotation += rotation_speed * delta

	# Handle thrust
	if Input.is_action_pressed("move"):
		if not is_thrusting:
			is_thrusting = true
			thrust_audio.play()
			player_sprite.play('thrust')
		# Convert the local raycast direction to global direction
		var thrust_direction = -transform.y
		velocity += thrust_direction * thrust_power * delta
	else:
		if is_thrusting:
			is_thrusting = false
			thrust_audio.stop()
			player_sprite.play('default')


func _physics_process(delta):
	GameManager.player_pos = position
	get_input(delta)

	# Apply drag
	velocity *= drag

	move_and_slide()

	wrap_around_screen()

func trigger_death_animation() -> void:
	var death_particles = death_particles_scene.instantiate()
	death_particles.position = position
	death_particles.one_shot = true
	death_particles.scale = Vector2(0.5, 0.5)
	get_parent().add_child(death_particles)

func kill_player() -> void:
	AudioManager.play("res://sounds/kenney_sci-fi-sounds/Audio/explosionCrunch_000.ogg")
	trigger_death_animation()
	player_death.emit()
	queue_free()

func _on_hitbox_body_entered(body: Node2D) -> void:
	kill_player()

func _on_hitbox_area_entered(area: Area2D) -> void:
	kill_player()

func _on_spawn_immunity_timer_timeout() -> void:
	hitbox.monitorable = true
	hitbox.monitoring = true
