class_name RewardManager
extends Node2D

var one_time_modifiers : Array[Modifier] = [
	CommandoModifier.new(),
	WrapAroundModifier.new(),
	JustColorModifier.new(),
	FirstOneIsFreeModifier.new(),
	BloodSacrificeModifier.new(),
	BloodSacrificePlusModifier.new()
]

func _ready():
	pass

func get_rewards(run_data : RunData) -> Array[Modifier]:
	var possible_rewards : Array[Modifier] = []
	
	for modifier in one_time_modifiers:
		if modifier.is_available(run_data):
			possible_rewards.append(modifier)

	possible_rewards.append(IncreaseScoreModifier.new())
	possible_rewards.append(IncreaseTimeModifier.new(5, 10))
	
	var lives_to_give : int = 1
	if run_data.blood_sacrifice: lives_to_give += 1
	if run_data.blood_sacrifice_plus: lives_to_give += 1
	
	possible_rewards.append(AddLifeModifier.new(lives_to_give))
	
	possible_rewards.shuffle()
	return possible_rewards.slice(0, 3)
