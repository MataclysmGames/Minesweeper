class_name Game
extends Control

const music_pitch : float = 0.70

@onready var time_left_label : RichTextLabel = $MainContainer/InfoContainer/TimeLabel
@onready var score_label : RichTextLabel = $MainContainer/InfoContainer/ScoreLabel
@onready var lives_label : RichTextLabel = $MainContainer/InfoContainer/LivesLabel
@onready var level_label : RichTextLabel = $MainContainer/InfoContainer/LevelLabel

@onready var sweeper_board : SweeperBoard = $MainContainer/SweeperBoard
@onready var panel_container : MarginContainer = $PanelContainer

@onready var level_complete_label : RichTextLabel = $PanelContainer/LevelUpContainer/HeaderLabel
@onready var level_score_label : Label = $PanelContainer/LevelUpContainer/GainedPointsContainer/PointsLabel
@onready var level_points_label : Label = $PanelContainer/LevelUpContainer/GainedPointsContainer/PointsValueLabel
@onready var total_points_label : Label = $PanelContainer/LevelUpContainer/TotalPointsContainer/PointsValueLabel

@onready var rewards_container : MarginContainer = $PanelContainer/LevelUpContainer/Margin
@onready var reward_button_1 : Button = $PanelContainer/LevelUpContainer/Margin/Rewards/Container/Button1
@onready var reward_button_2 : Button = $PanelContainer/LevelUpContainer/Margin/Rewards/Container/Button2
@onready var reward_button_3 : Button = $PanelContainer/LevelUpContainer/Margin/Rewards/Container/Button3
@onready var reward_explanation_text : TextEdit = $PanelContainer/LevelUpContainer/Margin/Rewards/Explanation

@onready var return_to_title_button : Button = $PanelContainer/LevelUpContainer/ReturnToTitleButton
@onready var reward_manager : RewardManager = $RewardManager

var timer : Timer
var run_data : RunData
var level_score : int = 0
var rewards : Array[Modifier]
var explanation_tween : Tween

func _ready():
	panel_container.hide()
	sweeper_board.board_cleared.connect(progress_level)
	sweeper_board.board_failed.connect(on_board_failed)
	reward_button_1.pressed.connect(accept_reward.bind(0))
	reward_button_2.pressed.connect(accept_reward.bind(1))
	reward_button_3.pressed.connect(accept_reward.bind(2))
	return_to_title_button.pressed.connect(on_view_summary)
	
	timer = Timer.new()
	timer.one_shot = true
	timer.autostart = false
	timer.timeout.connect(lose_life)
	add_child(timer)
	run_data = RunData.create_by_difficulty()
	start()

func _process(_delta):
	var timer_text : String = get_time_left_text()
	if timer_text:
		time_left_label.text = timer_text
	#level_score_label.text = "Level Score (x%3.2f)" % [run_data.score_multiplier]
	#level_score_label.text = "Level Score"
	score_label.text = " Score[color=gray][font_size=10] %d" % [run_data.total_score]
	lives_label.text = "[right]Lives[color=#ddd][font_size=10] %d " % [run_data.num_lives]
	level_label.text = "Level[color=#ddd][font_size=10] %d" % [run_data.current_level]
	total_points_label.text = str(run_data.total_score)
	level_points_label.text = str(level_score)
	
	if reward_button_1.is_hovered() or reward_button_1.button_pressed:
		explanation_tween.kill()
		reward_explanation_text.text = rewards[0].explanation
		reward_explanation_text.modulate = Color(1, 1, 1, 1)
	elif reward_button_2.is_hovered()  or reward_button_2.button_pressed:
		explanation_tween.kill()
		reward_explanation_text.text = rewards[1].explanation
		reward_explanation_text.modulate = Color(1, 1, 1, 1)
	elif reward_button_3.is_hovered()  or reward_button_3.button_pressed:
		explanation_tween.kill()
		reward_explanation_text.text = rewards[2].explanation
		reward_explanation_text.modulate = Color(1, 1, 1, 1)
	else:
		if reward_explanation_text.text != "":
			reward_explanation_text.text = ""
			explanation_tween = create_tween()
			explanation_tween.tween_property(reward_explanation_text, "modulate", Color(1, 1, 1, 0), 0.5).set_trans(Tween.TRANS_EXPO)

func start():
	run_data.current_level += 1
	sweeper_board.hide_grid()
	sweeper_board.initialize_with_run_data(run_data)
	sweeper_board.modulate = Color(1, 1, 1, 0)
	sweeper_board.show_grid()
	var tween = create_tween()
	tween.tween_property(sweeper_board, "modulate", Color(1, 1, 1, 1), 1)
	timer.wait_time = run_data.get_allowed_seconds()
	timer.start()
	var current_pitch : float = music_pitch + (run_data.current_level / 50.0)
	BackgroundAudio.play_main_theme(clampf(current_pitch, music_pitch, 1.05))

func progress_level():
	var seconds_remaining = timer.time_left
	timer.stop()
	level_score = seconds_remaining * 10 + 1000 * run_data.current_level
	level_score *= run_data.score_multiplier
	var new_total_score = run_data.total_score + level_score

	level_complete_label.text = "[wave][center]Level Cleared!"
	if run_data.current_level >= run_data.max_level:
		level_complete_label.text = "[wave][center]Run Completed!"
	
	set_rewards()
	
	return_to_title_button.hide()
	panel_container.modulate = Color(1, 1, 1, 0)
	panel_container.show()
	var tween = create_tween()
	tween.tween_property(sweeper_board, "modulate", Color(1, 1, 1, 0), 0.45).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN_OUT)
	tween.parallel().tween_property(panel_container, "modulate", Color(1, 1, 1, 1), 0.45).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN_OUT)
	tween.tween_callback(sweeper_board.hide_grid)
	tween.tween_property(run_data, "total_score", new_total_score, 1.6).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN_OUT)
	tween.parallel().tween_property(self, "level_score", 0, 1.6).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN_OUT)
	
	if run_data.current_level >= run_data.max_level:
		run_data.set_end_time()
		tween.tween_callback(return_to_title_button.show)
	else:
		tween.tween_callback(enable_rewards)
		tween.tween_property(rewards_container, "modulate", Color(1, 1, 1, 1), 1)
	
	tween.tween_callback(update_save_data)

func set_rewards():
	rewards_container.modulate = Color(1, 1, 1, 0)
	rewards = reward_manager.get_rewards(run_data)
	reward_button_1.text = rewards[0].title
	reward_button_2.text = rewards[1].title
	reward_button_3.text = rewards[2].title
	
	reward_button_1.set_deferred("disabled", true)
	reward_button_2.set_deferred("disabled", true)
	reward_button_3.set_deferred("disabled", true)
	
func enable_rewards():
	reward_button_1.set_deferred("disabled", false)
	reward_button_2.set_deferred("disabled", false)
	reward_button_3.set_deferred("disabled", false)
	
func update_save_data():
	SaveData.save_run_if_better(run_data, Global.current_difficulty)

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
	run_data.set_end_time()
	run_data.current_level -= 1 # Didn't finish the level
	SaveData.record_run(run_data)
	print("Run ended at level %d with score : %d" % [run_data.current_level, run_data.total_score])
	get_tree().change_scene_to_file("res://scenes/title.tscn")
	
func on_view_summary():
	SaveData.record_run(run_data)
	get_tree().change_scene_to_file("res://scenes/title.tscn")

func get_time_left_text() -> String:
	if timer.is_stopped():
		return ""
	var seconds_remaining : float = timer.time_left
	var minutes_remaining : int = seconds_remaining / 60
	
	var seconds_int : int = seconds_remaining - (minutes_remaining * 60)
	var ms_int : int = (seconds_remaining - (minutes_remaining * 60) - seconds_int) * 100
	if seconds_remaining < 10:
		return "[color=red]%02d:%02d[color=800].[font_size=10]%02d" % [minutes_remaining, seconds_int, ms_int]
	elif seconds_remaining < 30:
		return "[color=fa0]%02d:%02d[color=840].[font_size=10]%02d" % [minutes_remaining, seconds_int, ms_int]
	else:
		return "%02d:%02d[color=bbb].[font_size=10]%02d" % [minutes_remaining, seconds_int, ms_int]
