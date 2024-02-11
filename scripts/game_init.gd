extends Node

# Called when the node enters the scene tree for the first time.
func _ready():
	# Hide screen flashes during loading
	RenderingServer.set_default_clear_color(Color.BLACK)
