@tool
class_name SweeperBoard
extends Control

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
var hover_texture : Resource = preload("res://assets/cell-hover.png")

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
]

var just_color_textures : Array[Resource] = [
	preload("res://assets/cell-0.png"),
	preload("res://assets/cell-color-1.png"),
	preload("res://assets/cell-color-2.png"),
	preload("res://assets/cell-color-3.png"),
	preload("res://assets/cell-color-4.png"),
	preload("res://assets/cell-color-5.png"),
	preload("res://assets/cell-color-6.png"),
	preload("res://assets/cell-color-7.png"),
	preload("res://assets/cell-color-8.png"),
]

var run_data : RunData
var grid_data : Array[CellData]
var adjacent_cell_offsets : Array
var last_mouse_action : String = "left"
var reject_input : bool = false
var undiscovered_cell_count : int = 0
var discover_tween : Tween

func _process(_delta):
	if undiscovered_cell_count == 0 and not reject_input:
		win()

func _ready():
	initialize_with_run_data(RunData.create_casual())

func initialize_with_run_data(run_data : RunData):
	self.run_data = run_data
	num_columns = run_data.get_columns()
	num_rows = run_data.get_rows()
	num_mines = run_data.get_mines()
	var x_scale : float = 20.0 / num_columns
	var y_scale : float = 10.0 / num_rows
	var xy_scale : float = min(x_scale, y_scale)
	grid_container.scale = Vector2(xy_scale, xy_scale)
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
	reject_input = false

func _input(event : InputEvent):
	if event is InputEventMouseButton:
		var mouse_event = event as InputEventMouseButton
		last_mouse_action = "left" if mouse_event.button_index == MOUSE_BUTTON_LEFT else "right"

func win():
	reject_input = true
	board_cleared.emit()

func hit_mine():
	run_data.num_lives -= 1
	if run_data.num_lives <= 0:
		reject_input = true
		for cell in grid_data:
			cell.button.set_deferred("disabled", true)
			if cell.value == -1:
				cell.button.texture_normal = mine_texture
			else:
				cell.button.texture_normal = get_cell_texture(cell.value)
		board_failed.emit()

func generate_grid_data():
	# Create grid with buttons
	grid_data.resize(num_columns * num_rows)
	for i in range(num_columns * num_rows):
		var button = config_button.instantiate() as TextureButton
		button.show()
		button.pressed.connect(on_button_pressed.bind(i))
		grid_container.add_child(button)
		grid_data[i] = CellData.new(button, i)
		
	# Assign Mines
	grid_data.shuffle()
	grid_data.shuffle()
	for i in num_mines:
		grid_data[i].value = -1
	grid_data.sort_custom(func(a, b): return a.index < b.index)
	
	# Set non-mine values
	for i in range(num_columns * num_rows):
		if grid_data[i].value != -1:
			grid_data[i].value = calculate_value_for_cell(i)

func on_button_pressed(index : int):
	if reject_input:
		return

	var cell_data : CellData = grid_data[index]
	var button = cell_data.button
	if last_mouse_action == "left":
		if not cell_data.activated and not cell_data.flagged:
			if cell_data.value == -1: # Bomb
				button.set_deferred("disabled", true)
				button.focus_mode = Control.FOCUS_NONE
				button.texture_normal = mine_texture
				hit_mine()
			else:
				discover_tween = create_tween()
				discover_bfs(cell_data)
				
	elif last_mouse_action == "right" and not run_data.commando_enabled:
		if not cell_data.flagged:
			button.texture_normal = flagged_texture
			button.texture_hover = null
			cell_data.flagged = true
		else:
			button.texture_normal = default_texture
			button.texture_hover = hover_texture
			cell_data.flagged = false

func discover_bfs(cell_data : CellData):
	var found_cells : Array[CellData] = []
	found_cells.append(cell_data)
	var index = 0
	while index < len(found_cells):
		var curr_cell = found_cells[index]
		curr_cell.activated = true
		if curr_cell.value == 0:
			var adjacent_cells = get_adjacent_cells(curr_cell.index)
			for next_index in adjacent_cells:
				var next_cell = grid_data[next_index]
				if not next_cell.activated:
					next_cell.activated = true
					found_cells.append(next_cell)
		index += 1
		
	for cell in found_cells:
		cell.button.set_deferred("disabled", true)
		cell.button.focus_mode = Control.FOCUS_NONE
		discover_tween.tween_callback(cell.button.set_texture_normal.bind(get_cell_texture(cell.value)))
		discover_tween.tween_callback(decrement_undiscovered_cells)
		discover_tween.tween_interval(0.0025)

func get_cell_texture(value : int) -> Resource:
	if run_data.just_color_enabled:
		return just_color_textures[value]
	else:
		return textures[value]

func decrement_undiscovered_cells(amount : int = 1):
	undiscovered_cell_count -= amount

func calculate_value_for_cell(index : int) -> int:
	var mine_count = 0
	var adjacent_cells = get_adjacent_cells(index)
	for next_index in adjacent_cells:
		if grid_data[next_index].value == -1:
			mine_count += 1
	return mine_count
	
func get_adjacent_cells(index : int) -> Array[int]:
	if run_data.wrap_around_enabled:
		return get_adjacent_cells_with_wrap(index)
	else:
		return get_adjacent_cells_no_wrap(index)

func get_adjacent_cells_no_wrap(index : int) -> Array[int]:
	var adjacent_cells : Array[int] = []
	var coords = coords_from_index(index)
	for offset in adjacent_cell_offsets:
		var next_col = offset[0] + coords[0]
		var next_row = offset[1] + coords[1]
		if 0 <= next_col and next_col < num_columns and 0 <= next_row and next_row < num_rows:
			var next_index = index_from_coords([next_col, next_row])
			adjacent_cells.append(next_index)
	return adjacent_cells

func get_adjacent_cells_with_wrap(index : int) -> Array[int]:
	var adjacent_cells : Array[int] = []
	var coords = coords_from_index(index)
	for offset in adjacent_cell_offsets:
		var next_col = (offset[0] + coords[0] + num_columns) % num_columns
		var next_row = (offset[1] + coords[1] + num_rows) % num_rows
		var next_index = index_from_coords([next_col, next_row])
		adjacent_cells.append(next_index)
	return adjacent_cells

func index_from_coords(coords : Array[int]) -> int:
	return coords[0] + num_columns * coords[1]

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
