class_name CommandoModifier
extends Modifier

func _init():
	title = "Commando"
	explanation = "Reduce number of mines by 10%.\nCan no longer flag cells."

func apply(run_data : RunData) -> void:
	run_data.commando_enabled = true

func is_available(run_data : RunData) -> bool:
	return not run_data.commando_enabled
