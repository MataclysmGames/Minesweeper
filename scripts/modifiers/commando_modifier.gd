class_name CommandoModifier
extends Modifier

func _init():
	title = "Commando"
	explanation = "Reduce number of mines by 2.\nCan no longer flag cells."

func apply(run_data : RunData) -> void:
	run_data.commando_enabled = true
	run_data.extra_mines -= 2
