class_name RunHistory
extends MarginContainer

@export var history_base_label : Resource = preload("res://scenes/history_base_label.tscn")
@onready var grid : GridContainer = $VBoxContainer/ScrollContainer/GridContainer
@onready var back_button : Button = $VBoxContainer/HistoryButtonsContainer/BackButton
@onready var clear_button : Button = $VBoxContainer/HistoryButtonsContainer/ClearButton

func _ready():
	clear_button.pressed.connect(delete_all_history)
	load_history()

func load_history():
	var run_history : Array[RunData] = SaveData.get_run_history()
	run_history.sort_custom(func(a : RunData, b : RunData): return b.time_started - a.time_started)
	for run_data in run_history:
		print("run data")
		var date_label : RichTextLabel = history_base_label.instantiate() as RichTextLabel
		var date_str = Time.get_datetime_string_from_unix_time(run_data.time_started / 1000, true)
		date_label.text = "[center]%s" % [date_str]
		grid.add_child(date_label)
		
		var difficulty_label : RichTextLabel = history_base_label.instantiate() as RichTextLabel
		difficulty_label.text = difficulty_label(run_data)
		grid.add_child(difficulty_label)
		
		var duration_label : RichTextLabel = history_base_label.instantiate() as RichTextLabel
		var duration_ms : int = run_data.time_ended - run_data.time_started
		var minutes : int = duration_ms / 60000
		var seconds : int = (duration_ms / 1000) % 60
		var ms : int = duration_ms % 1000
		duration_label.text = "[center]%02d:%02d.%03d" % [minutes, seconds, ms]
		grid.add_child(duration_label)
		
		var levels_label : RichTextLabel = history_base_label.instantiate() as RichTextLabel
		levels_label.text = "[center]%d/%d" % [run_data.current_level, run_data.max_level]
		grid.add_child(levels_label)
		
		var score_label : RichTextLabel = history_base_label.instantiate() as RichTextLabel
		score_label.text = "[center][color=green]%d" % [run_data.total_score]
		grid.add_child(score_label)

func difficulty_label(run_data : RunData) -> String:
	match run_data.difficulty:
		"Easy":
			return "[center][color=green]%s" % [run_data.difficulty]
		"Normal":
			return "[center][color=yellow]%s" % [run_data.difficulty]
		"Hard":
			return "[center][color=red]%s" % [run_data.difficulty]
		"Nightmare":
			return "[center][color=purple]%s" % [run_data.difficulty]
		_:
			return ""

func delete_all_history():
	SaveData.purge_save_data()
	get_tree().reload_current_scene()

func _process(delta):
	pass
