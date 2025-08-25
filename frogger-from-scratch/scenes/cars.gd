extends CharacterBody2D
@onready var car_sprite: Sprite2D = $CarSprite
@export var car_textures: Array[Texture2D] = []  # Drag 4 textures here in inspector

#Needs
#Move in a given direction (x axis)
#Variable speed
@export var speed: float = 50
var direction = Vector2(-1, 0)

func _ready() -> void:
	if car_textures.size() > 0:
		car_sprite.texture = car_textures[randi() % car_textures.size()]
	if direction.x > 0:
		car_sprite.flip_h = false
	velocity = direction * speed

func _physics_process(delta):
	move_and_slide()
