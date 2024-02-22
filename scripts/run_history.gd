class_name RunHistory
extends MarginContainer

@export var history_base_label : Resource = preload("res://scenes/history_base_label.tscn")
@onready var grid : GridContainer = $VBoxContainer/ScrollContainer/GridContainer
@onready var back_button : Button = $VBoxContainer/HistoryButtonsContainer/BackButton
@onready var clear_button : Button = $VBoxContainer/HistoryButtonsContainer/ClearButton

@onready var confirmation_label : Label = $ConfirmationContainer/Label

func _ready():
	confirmation_label.visible = false
	clear_button.pressed.connect(clear_button_pressed)
	load_history()

func load_history():
	var run_history : Array[RunData] = SaveData.get_run_history()
	var entries : Array[Entry]
	for run_data in run_history:
		var entry : Entry = Entry.new()
		entry.date_str = "[center]%s" % [Time.get_datetime_string_from_unix_time(run_data.time_started / 1000, true)]
		entry.difficulty = difficulty_label(run_data)
		var duration_ms : int = run_data.time_ended - run_data.time_started
		var minutes : int = duration_ms / 60000
		var seconds : int = (duration_ms / 1000) % 60
		var ms : int = duration_ms % 1000
		entry.duration = "[center]%02d:%02d.%03d" % [minutes, seconds, ms]
		entry.levels = "[center]%d/%d" % [run_data.current_level, run_data.max_level]
		entry.score = "[center][color=green]%d" % [run_data.total_score]
		entries.append(entry)
		
	entries.sort_custom(func(a : Entry, b : Entry): return a.date_str > b.date_str)
	for entry in entries:
		var date_label : RichTextLabel = history_base_label.instantiate() as RichTextLabel
		date_label.text = entry.date_str
		grid.add_child(date_label)
		
		var difficulty_label : RichTextLabel = history_base_label.instantiate() as RichTextLabel
		difficulty_label.text = entry.difficulty
		grid.add_child(difficulty_label)
		
		var duration_label : RichTextLabel = history_base_label.instantiate() as RichTextLabel
		duration_label.text = entry.duration
		grid.add_child(duration_label)
		
		var levels_label : RichTextLabel = history_base_label.instantiate() as RichTextLabel
		levels_label.text = entry.levels
		grid.add_child(levels_label)
		
		var score_label : RichTextLabel = history_base_label.instantiate() as RichTextLabel
		score_label.text = entry.score
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

func clear_button_pressed():
	if confirmation_label.visible:
		delete_all_history()
	else:
		confirmation_label.visible = true
		clear_button.text = "Yes"

func delete_all_history():
	SaveData.purge_save_data()
	get_tree().reload_current_scene()

class Entry:
	var date_str : String
	var difficulty : String
	var duration : String
	var levels : String
	var score : String
	
