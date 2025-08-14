extends CharacterBody2D
@onready var paddle: AudioStreamPlayer2D = $Paddle
@onready var timer: Timer = $Timer

var speed = 700
var starting_pos = Vector2(615, 283)
var win_size: Vector2

func start(_position, _direction):
	rotation = _direction
	position = _position
	velocity = Vector2(speed, 0).rotated(rotation)

func _physics_process(delta):
	var collision = move_and_collide(velocity * delta)
	if collision:
		paddle.play()
		velocity = velocity.bounce(collision.get_normal())
		if collision.get_collider().has_method("hit"):
			collision.get_collider().hit()

func _ready() -> void:
	start(position, 1)
	timer.start()

#func _on_VisibilityNotifier2D_screen_exited():
	#print('neato!')
	## Deletes the bullet when it exits the screen.
	#queue_free()


func _on_timer_timeout() -> void:
	print('increasing speed')
	velocity = velocity + velocity * .1
