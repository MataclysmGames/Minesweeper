class_name BloodSacrificeModifier
extends Modifier

func _init():
	title = "Blood\nSacrifice"
	explanation = "All future Extra Life rewards give 1 more life.\nCost: 3 lives"

func apply(run_data : RunData) -> void:
	run_data.blood_sacrifice = true
	run_data.num_lives -= 3

func is_available(run_data : RunData) -> bool:
	return run_data.num_lives > 3 and not run_data.blood_sacrifice
