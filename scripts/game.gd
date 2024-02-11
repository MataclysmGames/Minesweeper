class_name Game
extends HBoxContainer

@onready var row_label : Label = $VBoxContainer/RowLabel
@onready var row_slider : HSlider = $VBoxContainer/RowSlider
@onready var column_label : Label = $VBoxContainer/ColumnLabel
@onready var column_slider : HSlider = $VBoxContainer/ColumnSlider
@onready var mines_label : Label = $VBoxContainer/MinesLabel
@onready var mines_slider : HSlider = $VBoxContainer/MinesSlider
@onready var start_button = $VBoxContainer/StartButton

@onready var sweeper_board : SweeperBoard = $CenterContainer/SweeperBoard

func _ready():
	print("Game ready")
	row_slider.value_changed.connect(func(value : float): row_label.text = "%d Rows" % value)
	column_slider.value_changed.connect(func(value : float): column_label.text = "%d Columns" % value)
	mines_slider.value_changed.connect(func(value : float): mines_label.text = "%d Mines" % value)
	start_button.pressed.connect(start)
	sweeper_board.board_cleared.connect(on_board_cleared)
	sweeper_board.board_failed.connect(on_board_failed)

func _process(delta):
	if Input.is_action_just_pressed("restart"):
		get_tree().reload_current_scene()
		
func start():
	sweeper_board.initialize(column_slider.value, row_slider.value, mines_slider.value)

func on_board_cleared():
	sweeper_board.initialize(column_slider.value, row_slider.value, mines_slider.value)

func on_board_failed():
	sweeper_board.initialize(column_slider.value, row_slider.value, mines_slider.value)
