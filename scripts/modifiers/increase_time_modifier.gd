class_name IncreaseTimeModifier
extends Modifier

var amount : int

func _init(min : int = 5, max : int = 10):
	amount = randi_range(min, max)
	title = "Time +%d" % amount
	explanation = "Get an extra %d seconds per round." % amount

func apply(run_data : RunData) -> void:
	run_data.extra_time += amount

func is_available(run_data : RunData) -> bool:
	return true
