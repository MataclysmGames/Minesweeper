class_name RunData

var total_score : int = 0
var num_lives : int = 3

var current_level : int = 11

func get_rows() -> int:
	var rows = 5 + current_level
	return min(rows, 20)

func get_columns() -> int:
	var columns = 10 + current_level * 2
	return min(columns, 40)

func get_mines() -> int:
	var mines = 2 + current_level * 3
	return min(mines, 60)
