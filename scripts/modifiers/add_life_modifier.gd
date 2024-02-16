class_name AddLifeModifier
extends Modifier

var amount : int

func _init(amount : int = 1):
	self.amount = amount
	if amount == 1:
		title = "+1 Life"
		explanation = "Get one more life. You're going to need it."
	else:
		title = "+%d Lives" % amount
		explanation = "Get %d more lives. It's your lucky day!" % amount
