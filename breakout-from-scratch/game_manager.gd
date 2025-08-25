extends Node

var bricks_hit: int = 0
var score: int = 0
var ceiling_hit: bool = false
var current_level = 0
var brick_count = 1

signal brick_destroyed
signal life_lost

func hit_brick():
	bricks_hit += 1
	brick_count -= 1
	score += 100
func next_level():
	current_level += 1
	bricks_hit = 0
	ceiling_hit = 0
	get_tree().reload_current_scene()

func reset_game():
	bricks_hit = 0
	ceiling_hit = false
	current_level = 0
	score = 0
