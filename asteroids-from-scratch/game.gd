extends Node2D
@onready var asteroid_spawn: Marker2D = $AsteroidSpawn

@export var asteroid_scene: PackedScene
@export var player_scene: PackedScene

# Anytime we spawn an asteroid, we need to connect to its spawn_more_asteroids
# signal

func spawn_asteroids(num: int = 4):
	for i in range(num):
		var new_ass = asteroid_scene.instantiate()
		new_ass.position = asteroid_spawn.position
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
	if ass_size > 1:
		for i in range(2):
			var new_ass = asteroid_scene.instantiate()
			new_ass.position = pos
			new_ass.size = ass_size - 1
			new_ass.speed = ass_speed
			new_ass.asteroid_destroyed.connect(_spawn_more_asteroids)
			add_child(new_ass)
