class_name SweeperBoard
extends Node2D

@export var num_columns : int = 8
@export var num_rows : int = 8
@export var num_mines : int = 8
@export var config_button : PackedScene

@onready var grid_container : GridContainer = $GridContainer

signal board_cleared()
signal board_failed()

var default_texture : Resource = preload("res://assets/default-cell.png")
var flagged_texture : Resource = preload("res://assets/cell-flagged.png")
var mine_texture : Resource = preload("res://assets/cell-mine.png")

var textures : Array[Resource] = [
	preload("res://assets/cell-0.png"),
	preload("res://assets/cell-1.png"),
	preload("res://assets/cell-2.png"),
	preload("res://assets/cell-3.png"),
	preload("res://assets/cell-4.png"),
	preload("res://assets/cell-5.png"),
	preload("res://assets/cell-6.png"),
	preload("res://assets/cell-7.png"),
	preload("res://assets/cell-8.png"),
]#540x360

var grid_data : Array[CellData]
var adjacent_cell_offsets : Array
var last_mouse_action : String = "left"
var game_over : bool = false
var undiscovered_cell_count : int = 0
var button_scale : Vector2 = Vector2(0.7, 0.7)

func _ready():
	initialize(num_columns, num_rows, num_mines)
	
func initialize(cols : int, rows : int, mines : int):
	num_columns = cols
	num_rows = rows
	num_mines = mines
	var x_scale : float = 12.0 / num_columns
	var y_scale : float = 9.0 / num_rows
	var xy_scale : float = min(x_scale, y_scale)
	scale = Vector2(xy_scale, xy_scale)
	undiscovered_cell_count = (num_columns * num_rows) - num_mines
	grid_container.columns = num_columns
	grid_container.modulate = Color(1, 1, 1, 1)
	for child in grid_container.get_children():
		grid_container.remove_child(child)
	adjacent_cell_offsets = [
		[-1, -1], [0, -1], [1, -1],
		[-1, 0],           [1, 0],
		[-1, 1],  [0, 1],  [1, 1]
	]
	generate_grid_data()

func _process(_delta):
	pass
	
func _input(event : InputEvent):
	if event is InputEventMouseButton:
		var mouse_event = event as InputEventMouseButton
		last_mouse_action = "left" if mouse_event.button_index == MOUSE_BUTTON_LEFT else "right"
	
func win():
	var tween = create_tween()
	tween.tween_property(grid_container, "modulate", Color(0, 1, 0, 1), 1.0)
	tween.tween_callback(func(): board_cleared.emit())

func lose():
	var tween = create_tween()
	tween.tween_property(grid_container, "modulate", Color(1, 0, 0, 1), 1.0)
	tween.tween_callback(func(): board_failed.emit())

func generate_grid_data():
	# Create grid with buttons
	grid_data.resize(num_columns * num_rows)
	for i in range(num_columns * num_rows):
		var button = config_button.instantiate() as TextureButton
		button.show()
		button.scale = button_scale
		button.pressed.connect(on_button_pressed.bind(i))
		grid_container.add_child(button)
		grid_data[i] = CellData.new(button, i)
	# Assign Mines
	grid_data.shuffle()
	for i in num_mines:
		grid_data[i].value = -1
	grid_data.sort_custom(func(a, b): return a.index < b.index)
	# Set non-mine values
	for i in range(num_columns * num_rows):
		if grid_data[i].value != -1:
			grid_data[i].value = calculate_value_for_cell(i)

func on_button_pressed(index : int):
	var cell_data : CellData = grid_data[index]
	var button = cell_data.button
	if last_mouse_action == "left":
		if not cell_data.activated and not cell_data.flagged:
			if cell_data.value == -1: # Bomb
				button.set_deferred("disabled", true)
				button.focus_mode = Control.FOCUS_NONE
				button.texture_normal = mine_texture
				lose()
			else:
				discover(cell_data)
				if undiscovered_cell_count == 0:
					win()
				
	elif last_mouse_action == "right":
		if not cell_data.flagged:
			button.texture_normal = flagged_texture
			cell_data.flagged = true
		else:
			button.texture_normal = default_texture
			cell_data.flagged = false

func discover(cell_data : CellData):
	if cell_data.activated:
		return
	undiscovered_cell_count -= 1
	cell_data.activated = true
	cell_data.button.set_deferred("disabled", true)
	cell_data.button.focus_mode = Control.FOCUS_NONE
	cell_data.button.texture_normal = textures[cell_data.value]
	var adjacent_cells = get_adjacent_cells(cell_data.index)
	if cell_data.value == 0:
		for next_index in adjacent_cells:
			discover(grid_data[next_index])

func calculate_value_for_cell(index : int) -> int:
	var mine_count = 0
	var adjacent_cells = get_adjacent_cells(index)
	for next_index in adjacent_cells:
		if grid_data[next_index].value == -1:
			mine_count += 1
	return mine_count

func get_adjacent_cells(index : int) -> Array[int]:
	var adjacent_cells : Array[int] = []
	var coords = coords_from_index(index)
	for offset in adjacent_cell_offsets:
		var next_col = (offset[0] + coords[0]) % num_columns
		var next_row = (offset[1] + coords[1]) % num_rows
		var next_index = index_from_coords([next_row, next_col])
		adjacent_cells.append(next_index)
	return adjacent_cells

func index_from_coords(coords : Array[int]) -> int:
	return coords[0] * num_columns + coords[1]

func coords_from_index(index : int) -> Array[int]:
	return [index % num_columns, index / num_columns]

class CellData:
	var index : int
	var value : int
	var button : TextureButton
	var flagged : bool = false
	var activated : bool = false

	func _init(button : TextureButton, index : int):
		self.button = button
		self.index = index
