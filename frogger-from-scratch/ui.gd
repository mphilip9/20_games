extends CanvasLayer
@onready var lives: Label = $MarginContainer/HBoxContainer/PanelContainer/Lives
@onready var lilypads: Label = $MarginContainer/HBoxContainer/PanelContainer2/Lilypads

func _ready():
	lives.text = str(GameManager.lives)
	lilypads.text = str(GameManager.lilypads)

func _process(delta: float) -> void:
	lives.text = str(GameManager.lives)
	lilypads.text = str(GameManager.lilypads)
