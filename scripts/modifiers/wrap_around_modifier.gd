class_name WrapAroundModifier
extends Modifier

func _init():
	title = "Wrap It Up"
	explanation = "The board wraps vertically and horizontally."

func apply(run_data : RunData) -> void:
	run_data.wrap_around_enabled = true

func is_available(run_data : RunData) -> bool:
	return not run_data.wrap_around_enabled
