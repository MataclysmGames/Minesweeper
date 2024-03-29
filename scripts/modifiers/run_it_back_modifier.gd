class_name RunItBackModifier
extends Modifier

var amount : int

func _init():
	amount = randi_range(1, 2)
	title = "Run It\nBack"
	if amount == 1:
		explanation = "Replay current level."
	else:
		explanation = "Replay previous level."

func apply(run_data : RunData) -> void:
	run_data.run_it_back = true
	run_data.current_level -= amount

func is_available(run_data : RunData) -> bool:
	return not run_data.run_it_back and run_data.current_level >= 5
