extends Control

@onready var exit_button = $HBoxContainer/ExitButton
@onready var start_button = $HBoxContainer/StartButton

# Called when the node enters the scene tree for the first time.
func _ready():
	exit_button.pressed.connect(exit_game)
	start_button.pressed.connect(start_game)

func exit_game():
	get_tree().quit()

func start_game():
	get_tree().change_scene_to_file("res://scenes/game.tscn")
