class_name JustColorModifier
extends Modifier

func _init():
	title = "Color Me\nImpressed"
	explanation = "Numbers are replaced by only color.\nIncrease time by 20%."

func apply(run_data : RunData) -> void:
	run_data.just_color_enabled = true
