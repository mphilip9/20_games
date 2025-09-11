extends Node

@export var player_pos: Vector2
@export var wave: int = 1
@export var asteroids_count: int
@export var score: int
@export var lives = 3
#TODO: The ufo_positions could be count as well
@export var ufos_count: int = 0


func restart_game() -> void:
	wave = 1
	asteroids_count = 0
	score = 0
	ufos_count = 0
	lives = 3
	get_tree().reload_current_scene()



func asteroid_speed() -> int:
	# Base speed starts at 50, increases by 10 per wave
	var base_speed = 40 + (wave * 10)

	var score_bonus = min(score / 2000, 50)

	# Max speed 100
	var final_speed = min(base_speed + score_bonus, 100)
	var variation = final_speed * 0.1

	return int(randf_range(final_speed - variation, final_speed + variation))

func determine_ufo_spawn_timer() -> float:
	# Base timer starts at 30, decreases by 2 seconds per wave
	var base_timer = max(30.0 - (wave * 2.0), 5.0)  # Minimum 5 seconds

	# Score bonus: -0.5 seconds per 5000 points, capped at -10 seconds
	var score_reduction = min(score / 5000.0 * 0.5, 10.0)

	var final_timer = max(base_timer - score_reduction, 3.0)  # Absolute minimum 3 seconds

	# Add randomness (±30% variation)
	var variation = final_timer * 0.3
	return randf_range(final_timer - variation, final_timer + variation)

func determine_pup_spawn() -> bool:
	if wave <= 1:
		return false

	var base_rate = min(0.3 + (wave - 2) * 0.1, 0.8)
	var score_bonus = min(score / 1000.0 * 0.01, 0.2)

	var final_rate = min(base_rate + score_bonus, 0.95)

	return randf() < final_rate

func ufo_size() -> float:
	var base_chance_large = max(0.7 - (wave - 1) * 0.1, 0.2)  # Minimum 20% chance for large

	# Score bonus: reduces large UFO chance by 5% per 10000 points, capped at -30%
	var score_penalty = min(score / 10000.0 * 0.05, 0.3)

	var final_chance_large = max(base_chance_large - score_penalty, 0.1)  # Absolute minimum 10%

	# Return size based on probability
	if randf() < final_chance_large:
		return 1.0
	else:
		return 0.5
