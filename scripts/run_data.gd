class_name RunData
extends Resource

# Information about the run that gets saved
@export var time_started : int
@export var time_ended : int
@export var current_level : int = 0
@export var max_level : int = 30
@export var total_score : int = 0
@export var difficulty : String
@export var mines_hit : int = 0

# Attributes
var num_lives : int = 3
var score_multiplier : float = 1.0
var extra_time : int = 0
var extra_mines : int = 0

var commando_enabled : bool = false
var wrap_around_enabled : bool = false
var just_color_enabled : bool = false
var first_one_is_free : bool = false
var auto_select_empty : bool = false

var modifiers : Array[Modifier]

# Configuration
var base_time : int = 60
var progress_time : float = 0

var mine_ratio : float = 0.08
var mine_ratio_progress : float = 0.01
var max_mine_ratio : float = 0.10

var base_rows : int = 8
var progress_rows : float = 0.5
var max_rows : int = 20

var base_columns : int = 14
var progress_columns : float = 1.0
var max_columns : int = 40

func _init():
	var unix_time: float = Time.get_unix_time_from_system()
	var unix_time_ms: int = unix_time * 1000.0
	time_started = unix_time_ms

func set_end_time():
	var unix_time: float = Time.get_unix_time_from_system()
	var unix_time_ms: int = unix_time * 1000.0
	time_ended = unix_time_ms

func get_rows() -> int:
	var rows : int = base_rows + current_level * progress_rows
	return min(rows, max_rows)

func get_columns() -> int:
	var columns : int = base_columns + current_level * progress_columns
	return min(columns, max_columns)

func get_mines() -> int:
	var size : int = get_rows() * get_columns()
	var current_mine_ratio : float = mine_ratio + (current_level * mine_ratio_progress)
	var effective_mine_ratio : float = min(max_mine_ratio, current_mine_ratio)
	var mines : int = ceil((size * effective_mine_ratio) + extra_mines)
	return mines

func get_allowed_seconds() -> float:
	var seconds = base_time + extra_time
	if just_color_enabled:
		seconds *= 1.2
	return seconds

func apply_modifier(modifier : Modifier):
	modifier.apply(self)
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
	run_data.difficulty = "Easy"
	run_data.num_lives = 5
	run_data.mine_ratio = 0.05
	run_data.mine_ratio_progress = 0.005
	run_data.max_mine_ratio = 0.08
	run_data.base_time = 120
	run_data.progress_time = 0
	run_data.max_level = 10
	run_data.progress_columns = 0.6
	run_data.progress_rows = 0.3
	return run_data

static func create_normal() -> RunData:
	var run_data := RunData.new()
	run_data.difficulty = "Normal"
	run_data.num_lives = 5
	run_data.mine_ratio = 0.06
	run_data.mine_ratio_progress = 0.005
	run_data.max_mine_ratio = 0.10
	run_data.base_time = 90
	run_data.progress_time = 0
	run_data.max_level = 15
	run_data.progress_columns = 0.7
	run_data.progress_rows = 0.35
	return run_data

static func create_hard() -> RunData:
	var run_data := RunData.new()
	run_data.difficulty = "Hard"
	run_data.num_lives = 4
	run_data.mine_ratio = 0.08
	run_data.mine_ratio_progress = 0.005
	run_data.max_mine_ratio = 0.12
	run_data.base_time = 60
	run_data.progress_time = 0
	run_data.max_level = 15
	run_data.progress_columns = 0.8
	run_data.progress_rows = 0.4
	return run_data

static func create_nightmare() -> RunData:
	var run_data := RunData.new()
	run_data.difficulty = "Nightmare"
	run_data.num_lives = 3
	run_data.mine_ratio = 0.08
	run_data.mine_ratio_progress = 0.005
	run_data.max_mine_ratio = 0.15
	run_data.base_time = 60
	run_data.progress_time = 0
	run_data.max_level = 20
	run_data.progress_columns = 0.9
	run_data.progress_rows = 0.45
	return run_data
