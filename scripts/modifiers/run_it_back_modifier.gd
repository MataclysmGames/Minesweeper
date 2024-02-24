class_name RunItBackModifier
extends Modifier

var amount : int

func _init():
	amount = randi_range(3, 7)
	title = "Run It\nBack"
	explanation = "Decrease level by %d." % [amount]

func apply(run_data : RunData) -> void:
	run_data.run_it_back = true
	run_data.current_level -= (amount + 1)

func is_available(run_data : RunData) -> bool:
	return not run_data.run_it_back and run_data.current_level > 8
