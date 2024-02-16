class_name IncreaseScoreModifier
extends Modifier

var percent_increase : int

func _init(min : int = 5, max : int = 20):
	percent_increase = randi_range(min, max)
	title = "Score +%d%%" % percent_increase
	explanation = "Increase score by %d percent." % percent_increase
