extends Node2D
@onready var asteroid_spawn: Marker2D = $AsteroidSpawn
@onready var ufo_timer: Timer = $UFOTimer
@onready var wave_cooldown: Timer = $WaveCooldown
@onready var life_container: HBoxContainer = $UILayer/Lives/LifeContainer
@onready var score_label: Label = $UILayer/Score/ScoreLabel
@onready var game_over_container: VBoxContainer = $UILayer/GameOverContainer
@onready var wave_label: Label = $"UILayer/Waves/Wave Label"

@export var asteroid_scene: PackedScene
@export var player_scene: PackedScene
@export var ufo_scene: PackedScene
@export var pup_scene: PackedScene
@onready var pup_timer: Timer = $PupTimer
@export var life_texture: PackedScene


func spawn_ufo() -> void:
	GameManager.ufos_count += 1
	var ufo = ufo_scene.instantiate()
	ufo.size = 	GameManager.ufo_size()
	add_child(ufo)


func pause_game() -> void:
	get_tree().paused = true

func unpause_game() -> void:
	get_tree().paused = false

func show_game_over():
	game_over_container.visible = true

func _input(event):
	if event.is_action_pressed("pause"):
		pause_game()

func _process(delta: float):
	score_label.text =  str(GameManager.score)

func spawn_asteroids() -> void:
	var num = 3 + GameManager.wave
	GameManager.asteroids_count = num + (num * 2) + (num * 4)
	for i in range(num):
		var new_ass = asteroid_scene.instantiate()
		new_ass.wave_spawn = true
		new_ass.asteroid_destroyed.connect(_spawn_more_asteroids)
		add_child(new_ass)
func spawn_pup() -> void:
	var pup = pup_scene.instantiate()
	add_child(pup)

func spawn_player(died: bool = false) -> void:
	var new_player = player_scene.instantiate()
	new_player.player_death.connect(_on_player_death)
	new_player.died = true
	add_child(new_player)
func _ready():
	set_lives()

	spawn_asteroids()
	spawn_player()

func remove_life():
	var children = life_container.get_children()
	GameManager.lives -= 1
	if children.size() > 0:
		var last_life = children[-1]  # Get the last child
		last_life.queue_free()
func add_life():
	var life = life_texture.instantiate()
	life_container.add_child(life)
func set_lives() -> void:
	for child in life_container.get_children():
		child.queue_free()

	for i in range(GameManager.lives):
		add_life()

func _on_player_death() -> void:
	remove_life()
	if GameManager.lives < 0:
		print('lives', GameManager.lives)
		show_game_over()
		return
	get_tree().create_timer(1.0).timeout.connect(func(): spawn_player(true))



func _spawn_more_asteroids(pos: Vector2, ass_size: int, ass_speed: float) -> void:
	call_deferred("_do_spawn_more_asteroids", pos, ass_size, ass_speed)

func  _do_spawn_more_asteroids(pos: Vector2, ass_size: int, ass_speed: float) -> void:
	GameManager.asteroids_count -= 1
	GameManager.score += 200
	if GameManager.asteroids_count == 0:
			wave_cooldown.start()
			AudioManager.play("res://sounds/Bells2.mp3")
	if ass_size >= 0.5:
		for i in range(2):
			var new_ass = asteroid_scene.instantiate()
			new_ass.position = pos
			new_ass.size = ass_size / 2.0
			new_ass.speed = ass_speed
			new_ass.asteroid_destroyed.connect(_spawn_more_asteroids)
			add_child(new_ass)


func _on_ufo_timer_timeout() -> void:
	spawn_ufo()
	ufo_timer.wait_time = GameManager.determine_ufo_spawn_timer()


func _on_wave_cooldown_timeout() -> void:
	GameManager.wave += 1
	wave_label.text = 'Wave ' + str(GameManager.wave)

	var do_spawn_pup: bool = GameManager.determine_pup_spawn()
	if do_spawn_pup:
		pup_timer.start()

	spawn_asteroids()


func _on_pup_timer_timeout() -> void:
	spawn_pup()


func _on_bounds_left_area_entered(area: Area2D) -> void:
	if area.is_in_group('ufo'):
		area.get_parent().queue_free()


func _on_bounds_right_area_entered(area: Area2D) -> void:
	if area.is_in_group('ufo'):
		area.get_parent().queue_free()


func _on_restart_button_pressed() -> void:
	GameManager.restart_game()
