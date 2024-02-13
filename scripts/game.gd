class_name Game
extends Control

@onready var time_left_label = $MainContainer/InfoContainer/TimeLabel
@onready var score_label = $MainContainer/InfoContainer/ScoreLabel
@onready var lives_label = $MainContainer/InfoContainer/LivesLabel
@onready var level_label = $MainContainer/InfoContainer/LevelLabel

@onready var sweeper_board : SweeperBoard = $MainContainer/SweeperBoard

var timer : Timer
var run_data : RunData

func _ready():
	sweeper_board.board_cleared.connect(progress_level)
	sweeper_board.board_failed.connect(lose_life)
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
	time_left_label.text = get_time_left_text()
	score_label.text = "Score: %d" % [run_data.total_score]
	lives_label.text = "Lives: %d" % [run_data.num_lives]
	level_label.text = "Level: %d" % [run_data.current_level]

func start():
	sweeper_board.hide()
	sweeper_board.initialize_with_run_data(run_data)
	sweeper_board.show()
	timer.wait_time = 120
	timer.start()

func progress_level():
	var seconds_remaining = timer.time_left
	var score = seconds_remaining * seconds_remaining * 3
	run_data.total_score += score
	run_data.current_level += 1
	start()

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
		return "Not Started"
	var seconds_remaining = timer.time_left
	var minutes_remaining : int = seconds_remaining / 60
	return "%02d:%02.3f" % [minutes_remaining, seconds_remaining - (minutes_remaining * 60)]
