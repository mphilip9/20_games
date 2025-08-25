extends Node2D
@onready var starting_position: Marker2D = $Markers/StartingPosition
@onready var lilypad_lane: Marker2D = $Markers/LilypadLane

@onready var frog: CharacterBody2D = $Frog
@onready var markers: Node = $Markers
var car_scene = preload("res://scenes/cars.tscn")
var log_scene = preload("res://scenes/log.tscn")
var turtle_scene = preload("res://scenes/turtle.tscn")
var lilypad_scene = preload("res://scenes/lily_pad.tscn")
var frog_scene = preload("res://scenes/frog.tscn")
var rng = RandomNumberGenerator.new()
var lane_speeds = {}
var lane_timers = {}
# determine speed for each lane in _ready func

func _ready():
	frog.position = starting_position.position
	frog.death.connect(_on_frog_death)
	frog.lilypad_reached.connect(_on_lilypad_reached)
	spawn_objects_on_markers()
	spawn_lilypads()


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
		scene_to_spawn = log_scene
	elif name.begins_with("Turtle"):
		scene_to_spawn = turtle_scene
	return scene_to_spawn

func _on_lilypad_reached(frog_node: CharacterBody2D):
	frog_node.queue_free()
	var new_frog = frog_scene.instantiate()
	new_frog.position = starting_position.position
	new_frog.death.connect(_on_frog_death)
	new_frog.lilypad_reached.connect(_on_lilypad_reached)
	add_child(new_frog)
	GameManager.lilypads += 1

func _on_frog_death(frog_node: CharacterBody2D):
#	maybe just play an animation? await it and then move the from
	frog_node.queue_free()
	var new_frog = frog_scene.instantiate()
	new_frog.position = starting_position.position
	new_frog.death.connect(_on_frog_death)
	new_frog.lilypad_reached.connect(_on_lilypad_reached)
	add_child(new_frog)
	GameManager.lives -= 1


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
		var num_scenes = randi_range(6, 12)
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
	lane_speeds[marker.name] = rng.randi_range(30, 75)
	var spawn_interval = rng.randf_range(3.0, 5.0)

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

	timer.wait_time = rng.randf_range(2.0, 5.0)
	var spawned_scene = scene_to_spawn.instantiate()
	spawned_scene.position = marker.position
	spawned_scene.direction = Vector2(-1, 0) if marker.position.x > 0 else Vector2(1, 0)
	spawned_scene.speed = lane_speeds[marker.name]
	add_child(spawned_scene)


func _on_kill_car_area_body_entered(body: Node2D) -> void:
	body.queue_free()


func _on_kill_car_area_2_body_entered(body: Node2D) -> void:
	body.queue_free()
