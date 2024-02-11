extends CanvasLayer

@export var num_columns : int = 8
@export var num_rows : int = 8
@export var num_mines : int = 8
@export var config_button : PackedScene

@onready var grid_container : GridContainer = $Control/GridContainer

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
]

var grid_data : Array[CellData]
var adjacent_cell_offsets : Array[int]
var last_mouse_action : String = "left"
var accepting_input : bool = true
var undiscovered_cell_count : int = 0
var button_scale : Vector2 = Vector2(0.7, 0.7)

func _input(event : InputEvent):
	if event is InputEventMouseButton:
		var mouse_event = event as InputEventMouseButton
		last_mouse_action = "left" if mouse_event.button_index == MOUSE_BUTTON_LEFT else "right"

func _ready():
	undiscovered_cell_count = (num_columns * num_rows) - num_mines
	grid_container.columns = num_columns
	adjacent_cell_offsets = [
		-1, 1, # Left, Right
		-num_columns, num_columns, # Up, Down
		-num_columns - 1, -num_columns + 1, # Up-Left, Up-Right
		num_columns - 1, num_columns + 1, # Down-Left, Down-Right
	]
	generate_grid_data()

func _process(_delta):
	if undiscovered_cell_count == 0:
		var tween = create_tween()
		tween.tween_interval(1.5)
		tween.tween_callback(get_tree().reload_current_scene)

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
	if not accepting_input:
		return

	var cell_data : CellData = grid_data[index]
	var button = cell_data.button
	if last_mouse_action == "left":
		if not cell_data.activated and not cell_data.flagged:
			if cell_data.value == -1:
				# Bomb
				accepting_input = false
				button.set_deferred("disabled", true)
				button.focus_mode = Control.FOCUS_NONE
				button.texture_normal = mine_texture
				var tween = create_tween()
				tween.tween_interval(2.0)
				tween.tween_callback(get_tree().reload_current_scene)
			else:
				discover(cell_data)
				
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
	if cell_data.value == 0:
		for offset in adjacent_cell_offsets:
			var pos = cell_data.index + offset
			if 0 <= pos and pos < num_columns * num_rows:
				discover(grid_data[pos])

func calculate_value_for_cell(i : int) -> int:
	var mine_count = 0
	for offset in adjacent_cell_offsets:
		var pos = i + offset
		if 0 <= pos and pos < num_columns * num_rows - 1:
			if grid_data[pos].value == -1:
				mine_count += 1
	return mine_count

class CellData:
	var index : int
	var value : int
	var button : TextureButton
	var flagged : bool = false
	var activated : bool = false
	
	func _init(button : TextureButton, index : int):
		self.button = button
		self.index = index
		
