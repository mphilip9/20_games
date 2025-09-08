extends Node2D
@onready var starting_position: Marker2D = $Markers/StartingPosition
@onready var lilypad_lane: Marker2D = $Markers/LilypadLane
@onready var point_scored: AudioStreamPlayer2D = $SoundManager/PointScored
@onready var level_container: VBoxContainer = $UI/LevelContainer
@onready var music: AudioStreamPlayer2D = $SoundManager/Music
@onready var start_game_container: MarginContainer = $UI/StartGameContainer

@onready var level_label: Label = $UI/LevelContainer/LevelLabel
@onready var game_over_container: MarginContainer = $UI/GameOverContainer
@onready var game_over_label: Label = $UI/GameOverContainer/VBoxContainer/GameOverLabel
@onready var pause_menu: MarginContainer = $UI/PauseMenu

@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var frog: CharacterBody2D = $Frog
@onready var markers: Node = $Markers
var car_scene = preload("res://scenes/cars.tscn")
var log_scene = preload("res://scenes/log.tscn")
var croc_scene = preload('res://crocodile.tscn')
var turtle_scene = preload("res://scenes/turtle.tscn")
var lilypad_scene = preload("res://scenes/lily_pad.tscn")
var frog_scene = preload("res://scenes/frog.tscn")
var rng = RandomNumberGenerator.new()
var lane_speeds = {}
var lane_timers = {}
var difficulty: float
var paused: bool = false
# determine speed for each lane in _ready func
# Difficulty logic
# --- Base Values ---
@export var initial_min_time: float = 2.0
@export var initial_max_time: float = 5.0

# --- Minimum Values (The hard limits) ---
@export var final_min_time: float = 0.5
@export var final_max_time: float = 1.2
@export var difficulty_for_min_time: float = 10.0

func toggle_pause_menu():
	pause_menu.visible = !pause_menu.visible
	get_tree().paused = !paused


func get_spawn_interval(difficulty_multiplier: float) -> float:
	# 1. Calculate progress (0.0 to 1.0) towards the minimum time.
	# We subtract 1.0 from the difficulty values to ensure progress is 0.0 at a multiplier of 1.0.
	var progress = inverse_lerp(1.0, difficulty_for_min_time, difficulty_multiplier)
	# Clamp ensures progress doesn't go below 0.0 or above 1.0
	progress = clamp(progress, 0.0, 1.0)

	# 2. Lerp each side of the range based on the progress.
	var current_min = lerp(initial_min_time, final_min_time, progress)
	var current_max = lerp(initial_max_time, final_max_time, progress)

	# 3. Get the final random value from the new, difficulty-adjusted range.
	var spawn_interval = rng.randf_range(current_min, current_max)
	return spawn_interval
func start_game():
	get_tree().paused = false
	if GameManager.level == 1:
		level_label.text = 'Level ' + str(GameManager.level)
	else:
		level_label.text = 'Level ' + str(GameManager.level)
	difficulty = GameManager.get_diff_multiplier()
	frog.position = starting_position.position
	frog.death.connect(_on_frog_death)
	frog.lilypad_reached.connect(_on_lilypad_reached)
	spawn_objects_on_markers()
	spawn_lilypads()
	animation_player.play('level_2')

func _ready():
	get_tree().paused = true
	if GameManager.level != 1 or GameManager.restarted_game:
		start_game_container.visible = false
		start_game()
		GameManager.restarted_game = false


func _input(event):
	if event.is_action_pressed("pause"):
		toggle_pause_menu()

func spawn_lilypads() -> void:
	var screen_width = get_viewport().get_visible_rect().size.x
	var lily_count = 5
	var spacing = screen_width / (lily_count + 1)  # +1 for margins on sides

	for i in range(lily_count):
		var lilypad = lilypad_scene.instantiate()
		var x_pos = spacing * (i + 1)  # Start from first spacing point
		var spawn_position = Vector2(x_pos, lilypad_lane.position.y)

		lilypad.global_position = spawn_position
		add_child(lilypad)
func pick_scene(name: String) -> PackedScene:
	var scene_to_spawn: PackedScene
	if name.begins_with("Car"):
		scene_to_spawn = car_scene
	elif name.begins_with("Log"):
		# Direct level scaling: +5% crocs per level
		var base_croc_chance = 0.15
		var croc_chance = min(base_croc_chance + (GameManager.level * 0.05), 0.85)

		var rand_log = randf_range(0, 1)
		if rand_log < croc_chance:
			scene_to_spawn = croc_scene
		else:
			scene_to_spawn = log_scene
	elif name.begins_with("Turtle"):
		scene_to_spawn = turtle_scene
	return scene_to_spawn

func _on_lilypad_reached(frog_node: CharacterBody2D, complete: bool):
	point_scored.play()
	frog_node.call_deferred("queue_free")

	var new_frog = frog_scene.instantiate()
	new_frog.position = starting_position.position
	new_frog.death.connect(_on_frog_death)
	new_frog.lilypad_reached.connect(_on_lilypad_reached)
	call_deferred("add_child", new_frog)
	if not complete:
		GameManager.lilypads += 1
		GameManager.score += 1000 + GameManager.time * 5
		if GameManager.lilypads == 5:
			level_label.text = 'LEVEL COMPLETE'


func _on_frog_death(frog_node: CharacterBody2D):
	GameManager.lives -= 1


	if GameManager.lives < 0:
		#get_tree().paused = true
		game_over_label.visible = true
		game_over_container.visible = true
		return
#	maybe just play an animation? await it and then move the from
	frog_node.queue_free()
	var new_frog = frog_scene.instantiate()
	new_frog.position = starting_position.position
	new_frog.death.connect(_on_frog_death)
	new_frog.lilypad_reached.connect(_on_lilypad_reached)
	add_child(new_frog)



func spawn_objects_on_markers():
	for child in markers.get_children():
		if child is Marker2D:
			setup_lane_timer(child)
			spawn_object_for_marker(child)

func spawn_object_for_marker(marker: Marker2D):
	var direction: Vector2 = Vector2(-1, 0)
	if marker.position.x < 0:
		direction = Vector2(1, 0)
	var scene_to_spawn: PackedScene = pick_scene(marker.name)
	if scene_to_spawn:
		var screen_width = get_viewport().get_visible_rect().size.x
		var car_width = 16
		var min_spacing = car_width + 20
		var max_cars = int(screen_width / min_spacing)
		var num_scenes = int(randf_range(4 * difficulty, 10 * difficulty))
		var cur_min: int = 0
		print('\n-------new scene set:', num_scenes)
		for i in range(num_scenes):
			var instance = scene_to_spawn.instantiate()
			var multiplier: int = 40
			var new_x: int
			new_x = randi_range(cur_min, multiplier + cur_min + 20)
			if direction.x < 0:
				new_x = -new_x
			instance.position = Vector2(marker.position.x + new_x, marker.position.y)
			instance.direction = direction
			instance.speed = lane_speeds[marker.name]
			var additional_spacing = randi_range(48, 64)
			cur_min = abs(new_x) + additional_spacing
			add_child(instance)

func setup_lane_timer(marker: Marker2D):
	lane_speeds[marker.name] = rng.randi_range(30 * difficulty, 70 * difficulty)
	var spawn_interval = get_spawn_interval(difficulty)

	var timer = Timer.new()
	timer.wait_time = spawn_interval
	timer.autostart = true
	timer.timeout.connect(_on_lane_spawn.bind(marker))
	add_child(timer)
	lane_timers[marker.name] = timer

func _on_lane_spawn(marker: Marker2D):
	var scene_to_spawn = pick_scene(marker.name)
#	logic to determine scene to spawn
	if scene_to_spawn == null:
		return
	var timer = lane_timers[marker.name]

	timer.wait_time = get_spawn_interval(difficulty)
	var spawned_scene = scene_to_spawn.instantiate()
	spawned_scene.position = marker.position
	spawned_scene.direction = Vector2(-1, 0) if marker.position.x > 0 else Vector2(1, 0)
	spawned_scene.speed = lane_speeds[marker.name]
	add_child(spawned_scene)


func _on_kill_car_area_body_entered(body: Node2D) -> void:
	body.queue_free()


func _on_kill_car_area_2_body_entered(body: Node2D) -> void:
	body.queue_free()


func _on_point_scored_finished() -> void:
	if GameManager.lilypads == 5:
		GameManager.new_level()


func _on_restart_button_pressed() -> void:
	GameManager.restart_game()


func _on_restart_pressed() -> void:
	GameManager.restart_game()


func _on_resume_pressed() -> void:
	get_tree().paused = false
	pause_menu.visible = false



func _on_music_finished() -> void:
	music.play()


func _on_start_game_pressed() -> void:
	start_game_container.visible = false
	start_game()
