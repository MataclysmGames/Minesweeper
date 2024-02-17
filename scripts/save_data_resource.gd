class_name SaveDataResource
extends Resource

@export_group("Best Runs")
@export var easy : RunData
@export var normal : RunData
@export var hard : RunData
@export var nightmare : RunData

@export_group("Global Stats")
@export var total_runs : int = 0
@export var total_mines_hit : int = 0
