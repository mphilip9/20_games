extends CharacterBody2D
@onready var thrust_audio: AudioStreamPlayer2D = $ThrustAudio
@onready var hitbox: Area2D = $Hitbox
@onready var spawn_immunity_timer: Timer = $SpawnImmunityTimer
@onready var player_sprite: AnimatedSprite2D = $PlayerSprite


@export var bullet: PackedScene
@export var weapon: String
@export var shield: bool = false
@onready var shield_sprite: Sprite2D = $ShieldSprite
@export var died: bool = false
@onready var weapon_timer: Timer = $WeaponTimer

@export var death_particles_scene: PackedScene


var thrust_power = 200.0
var rotation_speed = 3.5
var drag = 0.98
var screen_size: Vector2
var is_thrusting: bool
var rotation_smoothing = 8.0
var target_rotation_velocity = 0.0
var rotation_velocity = 0.0


signal player_death

func _ready() -> void:
	if died:
		hitbox.monitorable = false
		hitbox.monitoring = false
		spawn_immunity_timer.start()
	screen_size = get_viewport().get_visible_rect().size
	position = screen_size / 2


func shoot_bullet() -> void:
	if weapon == 'shotgun':
		AudioManager.play("res://sounds/kenney_sci-fi-sounds/Audio/laserLarge_000.ogg")
		var spread_angles = [-15, 0, 15]
		for angle_offset in spread_angles:
			var b = bullet.instantiate()
			b.speed = 400
			b.position = position
			b.direction = -transform.y.rotated(deg_to_rad(angle_offset))
			b.rotation = rotation + deg_to_rad(angle_offset)
			get_parent().add_child(b)
	else:
		AudioManager.play("res://sounds/kenney_sci-fi-sounds/Audio/laserSmall_000.ogg")
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
	target_rotation_velocity = 0.0
	if Input.is_action_pressed("rotate_left"):
		target_rotation_velocity = -rotation_speed
	if Input.is_action_pressed("rotate_right"):
		target_rotation_velocity = rotation_speed

	# Smooth the rotation
	rotation_velocity = lerp(rotation_velocity, target_rotation_velocity, rotation_smoothing * delta)
	rotation += rotation_velocity * delta

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
	if shield:
		shield = false
		shield_sprite.visible = false
		hitbox.call_deferred("set_monitorable", false)
		hitbox.call_deferred("set_monitoring", false)
		spawn_immunity_timer.start()
	else:
		AudioManager.play("res://sounds/kenney_sci-fi-sounds/Audio/explosionCrunch_000.ogg")
		trigger_death_animation()
		player_death.emit()
		queue_free()

func handle_powerup(area: Area2D) -> void:
	AudioManager.play("res://sounds/SynthChime6.mp3")
	if area.type == 'shotgun':
		weapon = 'shotgun'
		weapon_timer.start()
	elif area.type == 'shield':
		shield = true
		shield_sprite.visible = true
	area.queue_free()
	return


func _on_hitbox_body_entered(body: Node2D) -> void:
	kill_player()

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group('powerup'):
		handle_powerup(area)
	else:
		kill_player()

func _on_spawn_immunity_timer_timeout() -> void:
	hitbox.monitorable = true
	hitbox.monitoring = true


func _on_weapon_timer_timeout() -> void:
	weapon = 'standard'
