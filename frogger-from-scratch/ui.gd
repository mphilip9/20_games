extends CanvasLayer
@onready var life_1: TextureRect = $LivesContainer/Life1
@onready var life_2: TextureRect = $LivesContainer/Life2
@onready var life_3: TextureRect = $LivesContainer/Life3

@onready var lilypad_container: HBoxContainer = $LilypadContainer
@onready var score: Label = $ScoreContainer/Score
@onready var timer: Label = $TimerContainer/Timer


var lilypad_texture: Texture2D
var current_complete_pads: int = 0
#func _ready():
	#lilypads.text = str(GameManager.lilypads)

func add_lilypad():
	var new_lilypad = TextureRect.new()
	new_lilypad.texture = load("res://assets/complete_lilypad.png")
	lilypad_container.add_child(new_lilypad)

func reset_lilypads():
	# Clear all existing lilypad indicators
	for child in lilypad_container.get_children():
		child.queue_free()
	current_complete_pads = 0

	# Add lilypads for any that were already collected
	for i in range(GameManager.lilypads):
		add_lilypad()
		current_complete_pads += 1
func update_lives_display():
	life_1.visible = true
	life_2.visible = true
	life_3.visible = true


func _ready():
	reset_lilypads()
	update_lives_display()

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
