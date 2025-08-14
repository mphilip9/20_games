extends CharacterBody2D


@export var speed = 400

func get_input():
	velocity = transform.y * Input.get_axis("up2", "down2") * speed

func _physics_process(delta):
	get_input()
	move_and_slide()
