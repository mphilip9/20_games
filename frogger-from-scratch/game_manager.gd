extends Node

@export var score: int = 0
@export var lilypads: int = 0
@export var level: int = 1
@export var lives: int = 3
@export var is_dead: bool = false
@export var time: float = 30

func new_level():
	lilypads = 0
	level += 1
	lives = 3
	is_dead = false
	time = 30.0
	get_tree().reload_current_scene()

func restart_game():
	lilypads = 0
	level = 1
	lives = 3
	is_dead = false
	time= 30.0
	get_tree().reload_current_scene()
	get_tree().paused = false


func get_diff_multiplier():
	var scaling_factor = 1.08
	if level == 1:
		return 1
	var multiplier = 1 * pow(scaling_factor, level - 1)

	return min(multiplier, 10)
