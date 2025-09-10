extends Area2D
@onready var pup_sprite: Sprite2D = $PupSprite

@export var type: String
@export var shotgun: Texture2D
@export var shield: Texture2D

var glow_strength = 0.5
var pulse_speed = 3.0
var base_intensity = 1.0
var time_elapsed = 0.0


func _ready() -> void:
	if type == 'shotgun':
		pup_sprite.texture = shotgun
	else:
		pup_sprite.texture = shield

func _process(delta):
	time_elapsed += delta
	rotation += 1.0 * delta

	var pulse = sin(time_elapsed * pulse_speed)
	var intensity = base_intensity + (pulse * glow_strength)
	modulate = Color(intensity, intensity, intensity, 1.0)
