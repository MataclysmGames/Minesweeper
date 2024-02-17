class_name IncreaseScoreModifier
extends Modifier

var percent_increase : int

func _init(min : int = 10, max : int = 30):
	percent_increase = randi_range(min, max)
	title = "Score +%d%%" % percent_increase
	explanation = "Increase score by %d percent." % percent_increase
