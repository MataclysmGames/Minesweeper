class_name RunData

var total_score : int = 0
var num_lives : int = 3
var current_level : int = 0

var modifiers : Array[Modifier]
var extra_time : int = 0
var commando_enabled : bool = false
var wrap_around_enabled : bool = false
var extra_mines = 0

func get_rows() -> int:
	var rows : int = 5 + current_level * 0.4
	return min(rows, 20)

func get_columns() -> int:
	var columns : int = 10 + current_level * 0.8
	return min(columns, 40)

func get_mines() -> int:
	var mines = 2 + current_level * 2 + extra_mines
	return min(mines, 60)

func get_allowed_seconds() -> float:
	return 60 + extra_time

func get_rewards() -> Array[Modifier]:
	return [
		IncreaseTimeModifier.new(),
		AddLifeModifier.new(),
		WrapAroundModifier.new(),
	]

func apply_modifier(modifier : Modifier):
	if modifier is IncreaseTimeModifier:
		extra_time += modifier.amount
	elif modifier is AddLifeModifier:
		num_lives += modifier.amount
	elif modifier is CommandoModifier and not commando_enabled:
		extra_mines -= 3
		commando_enabled = true
	elif modifier is WrapAroundModifier:
		wrap_around_enabled = true
	else:
		modifiers.append(modifier)
