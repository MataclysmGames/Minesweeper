class_name AddLifeModifier
extends Modifier

var amount : int

func _init(amount : int = 1):
	self.amount = amount
	title = "Extra Life"
	explanation = "+%d extra life." % amount
