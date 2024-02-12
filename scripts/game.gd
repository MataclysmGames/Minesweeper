class_name Game
extends HBoxContainer

@onready var row_label : Label = $VBoxContainer/RowLabel
@onready var row_slider : HSlider = $VBoxContainer/RowSlider
@onready var column_label : Label = $VBoxContainer/ColumnLabel
@onready var column_slider : HSlider = $VBoxContainer/ColumnSlider
@onready var mines_label : Label = $VBoxContainer/MinesLabel
@onready var mines_slider : HSlider = $VBoxContainer/MinesSlider
@onready var start_button = $VBoxContainer/StartButton
@onready var time_left_label = $VBoxContainer/TimeLeftLabel
@onready var score_label = $VBoxContainer/ScoreLabel

@onready var sweeper_board : SweeperBoard = $CenterContainer/SweeperBoard

var timer : Timer
var time_started : int = -1
var time_finished : int = -1
var total_score : int = 0

func _ready():
	row_slider.value_changed.connect(update_row_label)
	column_slider.value_changed.connect(update_column_label)
	mines_slider.value_changed.connect(update_mines_label)
	start_button.pressed.connect(start)
	sweeper_board.board_cleared.connect(on_board_cleared)
	sweeper_board.board_failed.connect(on_board_failed)
	sweeper_board.hide()
	timer = Timer.new()
	timer.one_shot = true
	timer.autostart = false
	timer.timeout.connect(on_timeout)
	add_child(timer)
	
func _process(delta):
	if Input.is_action_just_pressed("restart"):
		get_tree().reload_current_scene()
	time_left_label.text = get_time_left_text()
	score_label.text = "Score: %d" % [total_score]

func update_row_label(value : float):
	row_label.text = "%d Rows" % value

func update_column_label(value : float):
	column_label.text = "%d Columns" % value
	
func update_mines_label(value : float):
	mines_label.text = "%d Mines" % value
	
func start():
	sweeper_board.show()
	sweeper_board.initialize(column_slider.value, row_slider.value, mines_slider.value)
	timer.wait_time = mines_slider.value * 7.5
	timer.start()

func on_board_cleared():
	var seconds_remaining = timer.time_left
	var score = pow(mines_slider.value + 2, 3) + (seconds_remaining * seconds_remaining * 3)
	total_score += score
	reset()

func on_board_failed():
	total_score = 0
	reset()

func on_timeout():
	total_score = 0
	reset()

func reset():
	timer.stop()
	sweeper_board.hide()
	sweeper_board.initialize(column_slider.value, row_slider.value, mines_slider.value)
	
func get_time_left_text():
	if timer.is_stopped():
		return "Not Started"
	var seconds_remaining = timer.time_left
	var minutes_remaining : int = seconds_remaining / 60
	return "%02d:%02.3f" % [minutes_remaining, seconds_remaining - (minutes_remaining * 60)]
