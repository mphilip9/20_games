extends AnimatableBody2D

var direction = Vector2(-1, 0) # Speed and direction
var speed = 25
var velocity
func _ready():
	velocity = direction * speed

func _physics_process(delta):
	# Move the platform
	position += velocity * delta
