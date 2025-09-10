extends Node

@export var player_pos: Vector2
@export var wave: int = 1
@export var asteroids_count: int
#TODO: The ufo_positions could be count as well
@export var ufos_count: int = 0

func asteroid_speed() -> int:
#	Provide a semi random speed based on current wave + score
	return 100

func determine_ufo_spawn_timer() -> float:
	return 25.0
