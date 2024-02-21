class_name RewardManager
extends Node2D

func get_rewards(run_data : RunData) -> Array[Modifier]:
	var possible_rewards : Array[Modifier] = []
	if not run_data.commando_enabled:
		possible_rewards.append(CommandoModifier.new())
	if not run_data.wrap_around_enabled:
		possible_rewards.append(WrapAroundModifier.new())
	if not run_data.just_color_enabled:
		possible_rewards.append(JustColorModifier.new())
	if not run_data.first_one_is_free:
		possible_rewards.append(FirstOneIsFreeModifier.new())
	if not run_data.auto_select_empty and run_data.num_lives > 3:
		possible_rewards.append(AutoSelectEmptyModifier.new())

	possible_rewards.append(IncreaseTimeModifier.new(5, 10))
	possible_rewards.append(IncreaseScoreModifier.new())
	
	if run_data.num_lives <= 2:
		possible_rewards.append(AddLifeModifier.new(2))
	else:
		possible_rewards.append(AddLifeModifier.new())
	
	possible_rewards.shuffle()
	return possible_rewards.slice(0, 3)
