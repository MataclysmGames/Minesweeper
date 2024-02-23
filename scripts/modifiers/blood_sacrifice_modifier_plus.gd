class_name BloodSacrificePlusModifier
extends Modifier

func _init():
	title = "Blood\nSacrifice+"
	explanation = "All future Extra Life rewards give 2 more lives.\nReduce number of lives to 1."

func apply(run_data : RunData) -> void:
	run_data.blood_sacrifice_plus = true
	run_data.num_lives = 1

func is_available(run_data : RunData) -> bool:
	return run_data.current_level > 10 and run_data.blood_sacrifice and not run_data.blood_sacrifice_plus
