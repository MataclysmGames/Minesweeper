class_name RunData
extends Resource

@export var time_started : int
@export var current_level : int = 0
@export var max_level : int = 30
@export var total_score : int = 0

# Configuration
var num_lives : int = 3
var score_multiplier : float = 1.0

var base_time : int = 60
var progress_time : float = 5
var extra_time : int = 0

var base_mines : int = 2
var progress_mines : float = 2.5
var extra_mines : int = 0
var max_mines : int = 50

var base_rows : int = 5
var progress_rows : float = 0.6
var max_rows : int = 15

var base_columns : int = 10
var progress_columns : float = 1.2
var max_columns : int = 30

var commando_enabled : bool = false
var wrap_around_enabled : bool = false
var just_color_enabled : bool = false

var modifiers : Array[Modifier]

func _init():
	var unix_time: float = Time.get_unix_time_from_system()
	var unix_time_ms: int = unix_time * 1000.0
	time_started = unix_time_ms

func get_rows() -> int:
	var rows : int = base_rows + current_level * progress_rows
	return min(rows, max_rows)

func get_columns() -> int:
	var columns : int = base_columns + current_level * progress_columns
	return min(columns, max_columns)

func get_mines() -> int:
	var mines : int = base_mines + current_level * progress_mines + extra_mines
	return min(mines, max_mines)

func get_allowed_seconds() -> float:
	var seconds = base_time + extra_time
	if just_color_enabled:
		seconds *= 1.5
	return seconds

func apply_modifier(modifier : Modifier):
	if modifier is IncreaseTimeModifier:
		extra_time += modifier.amount
	elif modifier is AddLifeModifier:
		num_lives += modifier.amount
	elif modifier is IncreaseScoreModifier:
		score_multiplier *= 1 + (modifier.percent_increase / 100.0)
	elif modifier is CommandoModifier and not commando_enabled:
		extra_mines -= 3
		commando_enabled = true
	elif modifier is WrapAroundModifier:
		wrap_around_enabled = true
	elif modifier is JustColorModifier:
		just_color_enabled = true
	else:
		modifiers.append(modifier)

static func create_by_difficulty() -> RunData:
	match Global.current_difficulty:
		Global.RunDifficulty.EASY:
			return create_easy()
		Global.RunDifficulty.NORMAL:
			return create_normal()
		Global.RunDifficulty.HARD:
			return create_hard()
		Global.RunDifficulty.NIGHTMARE:
			return create_nightmare()
		_:
			push_error("Invalid difficulty!")
			return create_normal()

static func create_easy() -> RunData:
	var run_data := RunData.new()
	run_data.num_lives = 5
	run_data.progress_mines = 2.2
	run_data.base_time = 90
	run_data.progress_time = 0
	run_data.max_level = 10
	run_data.progress_columns = 1.2
	run_data.progress_rows = 0.6
	return run_data

static func create_normal() -> RunData: #13899
	var run_data := RunData.new()
	run_data.num_lives = 4
	run_data.progress_mines = 2.3
	run_data.base_time = 60
	run_data.progress_time = 0
	run_data.max_level = 15
	run_data.progress_columns = 1.2
	run_data.progress_rows = 0.6
	return run_data

static func create_hard() -> RunData:
	var run_data := RunData.new()
	run_data.num_lives = 3
	run_data.progress_mines = 2.4
	run_data.base_time = 45
	run_data.progress_time = 0
	run_data.max_level = 20
	run_data.progress_columns = 1.2
	run_data.progress_rows = 0.6
	return run_data

static func create_nightmare() -> RunData:
	var run_data := RunData.new()
	run_data.num_lives = 3
	run_data.progress_mines = 2.5
	run_data.base_time = 30
	run_data.progress_time = 0
	run_data.max_level = 30
	run_data.progress_columns = 1.0
	run_data.progress_rows = 0.5
	return run_data
