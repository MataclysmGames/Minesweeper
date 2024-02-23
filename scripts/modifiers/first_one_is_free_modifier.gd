class_name FirstOneIsFreeModifier
extends Modifier

func _init():
	title = "First One\nIs Free"
	explanation = "Guarantee the first cell clicked isn't a bomb."

func apply(run_data : RunData) -> void:
	run_data.first_one_is_free = true

func is_available(run_data : RunData) -> bool:
	return not run_data.first_one_is_free
