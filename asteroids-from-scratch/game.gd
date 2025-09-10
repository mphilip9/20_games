extends Node2D
@onready var asteroid_spawn: Marker2D = $AsteroidSpawn
@onready var ufo_timer: Timer = $UFOTimer
@onready var wave_cooldown: Timer = $WaveCooldown

@export var asteroid_scene: PackedScene
@export var player_scene: PackedScene
@export var ufo_scene: PackedScene


func spawn_ufo() -> void:
	GameManager.ufos_count += 1
	var ufo = ufo_scene.instantiate()
	add_child(ufo)
#	THis will be triggered based on a timer.


func spawn_asteroids() -> void:
	var num = 3 + GameManager.wave
	GameManager.asteroids_count = num + (num * 2) + (num * 4)
	for i in range(num):
		var new_ass = asteroid_scene.instantiate()
		new_ass.wave_spawn = true
		new_ass.asteroid_destroyed.connect(_spawn_more_asteroids)
		add_child(new_ass)

func spawn_player(died: bool = false) -> void:
	var new_player = player_scene.instantiate()
	new_player.player_death.connect(_on_player_death)
	new_player.died = true
	add_child(new_player)
func _ready():
	spawn_asteroids()
	spawn_player()

func _on_player_death() -> void:
#	Play death sound??
	get_tree().create_timer(1.0).timeout.connect(func(): spawn_player(true))

func _spawn_more_asteroids(pos: Vector2, ass_size: int, ass_speed: float) -> void:
	call_deferred("_do_spawn_more_asteroids", pos, ass_size, ass_speed)

func  _do_spawn_more_asteroids(pos: Vector2, ass_size: int, ass_speed: float) -> void:
	GameManager.asteroids_count -= 1
	if GameManager.asteroids_count == 0:
			print('should be NO asteroids', GameManager.asteroids_count, GameManager.ufos_count)
			wave_cooldown.start()
			AudioManager.play("res://sounds/Bells2.mp3")

	if ass_size > 1:
		for i in range(2):
			var new_ass = asteroid_scene.instantiate()
			new_ass.position = pos
			new_ass.size = ass_size - 1
			new_ass.speed = ass_speed
			new_ass.asteroid_destroyed.connect(_spawn_more_asteroids)
			add_child(new_ass)


func _on_ufo_timer_timeout() -> void:
	spawn_ufo()


func _on_wave_cooldown_timeout() -> void:
	print('why is this going off...')
	GameManager.wave += 1
	spawn_asteroids()
