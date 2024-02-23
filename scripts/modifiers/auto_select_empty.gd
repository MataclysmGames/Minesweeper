class_name AutoSelectEmptyModifier
extends Modifier

func _init():
	title = "Death By\nAutomation"
	explanation = "Each level begins by exposing a random section of empty cells.\nCost: 3 lives"

func apply(run_data : RunData) -> void:
	run_data.auto_select_empty = true
	run_data.num_lives -= 3

func is_available(run_data : RunData) -> bool:
	return not run_data.auto_select_empty and run_data.num_lives > 3
