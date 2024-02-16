class_name Game
extends Control

@onready var time_left_label : Label = $MainContainer/InfoContainer/TimeLabel
@onready var score_label : Label = $MainContainer/InfoContainer/ScoreLabel
@onready var lives_label : Label = $MainContainer/InfoContainer/LivesLabel
@onready var level_label : Label = $MainContainer/InfoContainer/LevelLabel

@onready var sweeper_board : SweeperBoard = $MainContainer/SweeperBoard
@onready var panel_container : PanelContainer = $PanelContainer

@onready var level_score_label : Label = $PanelContainer/LevelUpContainer/GainedPointsContainer/PointsLabel
@onready var level_points_label : Label = $PanelContainer/LevelUpContainer/GainedPointsContainer/PointsValueLabel
@onready var total_points_label : Label = $PanelContainer/LevelUpContainer/TotalPointsContainer/PointsValueLabel

@onready var rewards_container : VBoxContainer = $PanelContainer/LevelUpContainer/Rewards
@onready var reward_button_1 : Button = $PanelContainer/LevelUpContainer/Rewards/Container/Button1
@onready var reward_button_2 : Button = $PanelContainer/LevelUpContainer/Rewards/Container/Button2
@onready var reward_button_3 : Button = $PanelContainer/LevelUpContainer/Rewards/Container/Button3
@onready var reward_explanation_text : TextEdit = $PanelContainer/LevelUpContainer/Rewards/Explanation

@onready var view_summary_button : Button = $PanelContainer/LevelUpContainer/ViewSummaryButton

var timer : Timer
var run_data : RunData
var level_score : int = 0
var rewards : Array[Modifier]

func _ready():
	panel_container.hide()
	sweeper_board.board_cleared.connect(progress_level)
	sweeper_board.board_failed.connect(on_board_failed)
	reward_button_1.pressed.connect(accept_reward.bind(0))
	reward_button_2.pressed.connect(accept_reward.bind(1))
	reward_button_3.pressed.connect(accept_reward.bind(2))
	view_summary_button.pressed.connect(on_view_summary)
	
	timer = Timer.new()
	timer.one_shot = true
	timer.autostart = false
	timer.timeout.connect(lose_life)
	add_child(timer)
	run_data = RunData.create_casual()
	start()

func _process(_delta):
	var timer_text : String = get_time_left_text()
	if timer_text:
		time_left_label.text = timer_text
	level_score_label.text = "Level Score (x%3.2f)" % [run_data.score_multiplier]
	score_label.text = "Score: %d" % [run_data.total_score]
	lives_label.text = "Lives: %d" % [run_data.num_lives]
	level_label.text = "Level: %d" % [run_data.current_level]
	total_points_label.text = str(run_data.total_score)
	level_points_label.text = str(level_score)
	
	if reward_button_1.is_hovered():
		reward_explanation_text.text = rewards[0].explanation
		reward_explanation_text.modulate = Color(1, 1, 1, 1)
	elif reward_button_2.is_hovered():
		reward_explanation_text.text = rewards[1].explanation
		reward_explanation_text.modulate = Color(1, 1, 1, 1)
	elif reward_button_3.is_hovered():
		reward_explanation_text.text = rewards[2].explanation
		reward_explanation_text.modulate = Color(1, 1, 1, 1)
	else:
		reward_explanation_text.text = ""
		reward_explanation_text.modulate = Color(0, 0, 0, 0)

func start():
	run_data.current_level += 1
	sweeper_board.hide()
	sweeper_board.initialize_with_run_data(run_data)
	sweeper_board.modulate = Color(1, 1, 1, 0)
	sweeper_board.show()
	var tween = create_tween()
	tween.tween_property(sweeper_board, "modulate", Color(1, 1, 1, 1), 0.5)
	timer.wait_time = run_data.get_allowed_seconds()
	timer.start()
	BackgroundAudio.play_main_theme(0.66 + (run_data.current_level / 100.0))

func progress_level():
	var seconds_remaining = timer.time_left
	timer.stop()
	level_score = seconds_remaining * run_data.current_level
	level_score *= run_data.score_multiplier
	var new_total_score = run_data.total_score + level_score

	rewards_container.hide()
	view_summary_button.hide()
	panel_container.scale = Vector2(0, 0)
	panel_container.show()
	var tween = create_tween()
	tween.tween_property(sweeper_board, "modulate", Color(1, 1, 1, 0), 0.5)
	tween.parallel().tween_property(panel_container, "scale", Vector2(1, 1), 0.5).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(run_data, "total_score", new_total_score, 2.0).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN_OUT)
	tween.parallel().tween_property(self, "level_score", 0, 2.0).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN_OUT)
	
	if run_data.current_level == run_data.max_level:
		tween.tween_callback(view_summary_button.show)
	else:
		rewards = get_rewards()
		reward_button_1.text = rewards[0].title
		reward_button_2.text = rewards[1].title
		reward_button_3.text = rewards[2].title
		tween.tween_callback(rewards_container.show)

func get_rewards() -> Array[Modifier]:
	var possible_rewards : Array[Modifier]
	if not run_data.commando_enabled:
		possible_rewards.append(CommandoModifier.new())
	if not run_data.wrap_around_enabled:
		possible_rewards.append(WrapAroundModifier.new())
	if not run_data.just_color_enabled:
		possible_rewards.append(JustColorModifier.new())
	
	possible_rewards.append(IncreaseTimeModifier.new(10, 15))
	possible_rewards.append(AddLifeModifier.new(randi_range(1, 2)))
	possible_rewards.append(IncreaseScoreModifier.new())
	
	possible_rewards.shuffle()
	return possible_rewards.slice(0, 3)

func accept_reward(index : int):
	var reward := rewards[index]
	run_data.apply_modifier(reward)
	panel_container.hide()
	start()

func on_board_failed():
	var tween = create_tween()
	tween.tween_interval(1.0)
	tween.tween_callback(lose_life)
	
func lose_life():
	run_data.num_lives -= 1
	if run_data.num_lives <= 0:
		game_over()
	else:
		start()

func game_over():
	print("Run ended at level %d with score : %d" % [run_data.current_level, run_data.total_score])
	get_tree().change_scene_to_file("res://scenes/title.tscn")
	
func on_view_summary():
	get_tree().change_scene_to_file("res://scenes/title.tscn")

func get_time_left_text() -> String:
	if timer.is_stopped():
		return ""
	var seconds_remaining : float = timer.time_left
	var minutes_remaining : int = seconds_remaining / 60
	return "%02d:%05.2f" % [minutes_remaining, seconds_remaining - (minutes_remaining * 60)]
