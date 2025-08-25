extends AnimatableBody2D
@onready var turtle_sprite: Sprite2D = $TurtleSprite
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var direction = Vector2(-1, 0) # Speed and direction
var speed = 25
var velocity
func _ready():
	var random_num: float = randf_range(0, 1)
	if random_num > 0.5:
		animation_player.play("diving_turtle")
	if direction.x > 0:
		turtle_sprite.flip_h = true
	velocity = direction * speed

func _physics_process(delta):
	# Move the platform
	position += velocity * delta
