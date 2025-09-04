extends AnimatableBody2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer


var direction = Vector2(-1, 0) # Speed and direction
var speed = 25
var velocity
func _ready():
	animation_player.play('croc_attack')
	velocity = direction * speed

func _physics_process(delta):
	# Move the platform
	position += velocity * delta
