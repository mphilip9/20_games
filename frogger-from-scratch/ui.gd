extends CanvasLayer
@onready var life_1: TextureRect = $MarginContainer/HBoxContainer/HBoxContainer/Life1
@onready var life_2: TextureRect = $MarginContainer/HBoxContainer/HBoxContainer/Life2
@onready var life_3: TextureRect = $MarginContainer/HBoxContainer/HBoxContainer/Life3
@onready var lilypad_container: HBoxContainer = $MarginContainer/HBoxContainer/LilypadContainer
@onready var score: Label = $MarginContainer/HBoxContainer/ScoreContainer/Score

@onready var timer: Label = $MarginContainer/HBoxContainer/PanelContainer3/Timer
var lilypad_texture: Texture2D
var current_complete_pads: int = 0
#func _ready():
	#lilypads.text = str(GameManager.lilypads)

func add_lilypad():
	var new_lilypad = TextureRect.new()
	new_lilypad.texture = load("res://assets/complete_lilypad.png")
	lilypad_container.add_child(new_lilypad)

func _process(delta: float) -> void:
	score.text = str(GameManager.score)
	if GameManager.lilypads > current_complete_pads:
		current_complete_pads += 1
		add_lilypad()
	if GameManager.time:
		timer.text = str(int(GameManager.time))
	if GameManager.lives < 3:
		life_3.visible = false
	if GameManager.lives < 2:
		life_2.visible = false
	if GameManager.lives < 1:
		life_1.visible = false
	#lives.text = str(GameManager.lives)
