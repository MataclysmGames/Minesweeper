class_name AddLifeModifier
extends Modifier

var amount : int

func _init(amount : int = 1):
	self.amount = amount
	if amount == 1:
		title = "+1 Life"
		explanation = "Get a life. You're going to need it."
	else:
		title = "+%d Lives" % amount
		explanation = "Get %d more lives. It's your lucky day!" % amount

func apply(run_data : RunData) -> void:
	run_data.num_lives += amount

func is_available(run_data : RunData) -> bool:
	return true
