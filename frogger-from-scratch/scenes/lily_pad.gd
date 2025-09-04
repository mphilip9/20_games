extends Sprite2D
@export var completed_texture: Texture2D
@export var status_complete: bool = false

func complete_lilypad():
	status_complete = true
	texture = completed_texture
