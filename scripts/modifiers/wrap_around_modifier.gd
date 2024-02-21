class_name WrapAroundModifier
extends Modifier

func _init():
	title = "Wrap It Up"
	explanation = "The board wraps vertically and horizontally."

func apply(run_data : RunData) -> void:
	run_data.wrap_around_enabled = true
