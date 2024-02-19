extends Node

# Called when the node enters the scene tree for the first time.
func _ready():
	# Hide screen flashes during loading
	RenderingServer.set_default_clear_color(Color(0.12, 0.12, 0.25, 1))

func _notification(what : int):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		SaveData.save_to_disk()
