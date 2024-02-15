class_name Game
extends Control

@onready var time_left_label = $MainContainer/InfoContainer/TimeLabel
@onready var score_label = $MainContainer/InfoContainer/ScoreLabel
@onready var lives_label = $MainContainer/InfoContainer/LivesLabel
@onready var level_label = $MainContainer/InfoContainer/LevelLabel

@onready var sweeper_board : SweeperBoard = $MainContainer/SweeperBoard
@onready var level_up_container = $PanelContainer

@onready var total_points_label = $PanelContainer/LevelUpContainer/TotalPointsContainer/PointsValueLabel
@onready var level_points_label = $PanelContainer/LevelUpContainer/GainedPointsContainer/PointsValueLabel

@onready var rewards_container = $PanelContainer/LevelUpContainer/Rewards
@onready var reward_button_1 = $PanelContainer/LevelUpContainer/Rewards/Container/Button1
@onready var reward_button_2 = $PanelContainer/LevelUpContainer/Rewards/Container/Button2
@onready var reward_button_3 = $PanelContainer/LevelUpContainer/Rewards/Container/Button3
@onready var reward_explanation_text = $PanelContainer/LevelUpContainer/Rewards/Explanation

var timer : Timer
var run_data : RunData
var level_score : int = 0
var rewards : Array[Modifier]

func _ready():
	level_up_container.hide()
	sweeper_board.board_cleared.connect(progress_level)
	sweeper_board.board_failed.connect(on_board_failed)
	reward_button_1.pressed.connect(accept_reward.bind(0))
	reward_button_2.pressed.connect(accept_reward.bind(1))
	reward_button_3.pressed.connect(accept_reward.bind(2))
	
	timer = Timer.new()
	timer.one_shot = true
	timer.autostart = false
	timer.timeout.connect(lose_life)
	add_child(timer)
	run_data = RunData.new()
	start()

func _process(_delta):
	if Input.is_action_just_pressed("restart"):
		get_tree().reload_current_scene()
	var timer_text = get_time_left_text()
	if timer_text:
		time_left_label.text = timer_text
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
	sweeper_board.show()
	timer.wait_time = run_data.get_allowed_seconds()
	timer.start()

func progress_level():
	var seconds_remaining = timer.time_left
	timer.stop()
	level_score = seconds_remaining * seconds_remaining * 3
	var new_total_score = run_data.total_score + level_score
	rewards = run_data.get_rewards()
	reward_button_1.text = rewards[0].title
	reward_button_2.text = rewards[1].title
	reward_button_3.text = rewards[2].title
	
	rewards_container.hide()
	level_up_container.scale = Vector2(0, 0)
	level_up_container.show()
	var tween = create_tween()
	tween.tween_property(level_up_container, "scale", Vector2(1, 1), 0.5).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "level_score", 0, 2.0).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN_OUT)
	tween.parallel().tween_property(run_data, "total_score", new_total_score, 2.0).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN_OUT)
	tween.tween_callback(rewards_container.show)

func accept_reward(index : int):
	var reward = rewards[index]
	run_data.apply_modifier(reward)
	level_up_container.hide()
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
	
func get_time_left_text():
	if timer.is_stopped():
		return null
	var seconds_remaining = timer.time_left
	var minutes_remaining : int = seconds_remaining / 60
	return "%02d:%05.2f" % [minutes_remaining, seconds_remaining - (minutes_remaining * 60)]
