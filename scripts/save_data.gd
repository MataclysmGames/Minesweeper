extends Node

const save_resource_name : String = "user://save.tres"

var save_resource : SaveDataResource

func _ready():
	reload()

func reload():
	save_resource = ResourceLoader.load(save_resource_name, "", ResourceLoader.CACHE_MODE_IGNORE) as SaveDataResource
	if not save_resource:
		save_resource = SaveDataResource.new()
		save_to_disk()

func save_to_disk():
	ResourceSaver.save(save_resource, save_resource_name)

func purge_save_data():
	save_resource = SaveDataResource.new()
	save_to_disk()

func get_saved_run(difficulty : Global.RunDifficulty) -> RunData:
	match difficulty:
		Global.RunDifficulty.EASY:
			return save_resource.easy
		Global.RunDifficulty.NORMAL:
			return save_resource.normal
		Global.RunDifficulty.HARD:
			return save_resource.hard
		Global.RunDifficulty.NIGHTMARE:
			return save_resource.nightmare
		_:
			push_error("Invalid difficulty")
			return null

func save_run_if_better(run_data : RunData, difficulty : Global.RunDifficulty):
	match difficulty:
		Global.RunDifficulty.EASY:
			if run_is_better(save_resource.easy, run_data):
				save_resource.easy = run_data
				save_to_disk()
		Global.RunDifficulty.NORMAL:
			if run_is_better(save_resource.normal, run_data):
				save_resource.normal = run_data
				save_to_disk()
		Global.RunDifficulty.HARD:
			if run_is_better(save_resource.hard, run_data):
				save_resource.hard = run_data
				save_to_disk()
		Global.RunDifficulty.NIGHTMARE:
			if run_is_better(save_resource.nightmare, run_data):
				save_resource.nightmare = run_data
				save_to_disk()
		_:
			push_error("Invalid difficulty")

func run_is_better(saved_run : RunData, current_run : RunData) -> bool:
	if not saved_run:
		return true
	if current_run.current_level > saved_run.current_level:
		return true
	if current_run.current_level == saved_run.current_level:
		return current_run.total_score > saved_run.total_score
	return false
	
func record_run(run_data : RunData):
	save_resource.run_history.append(run_data)
	save_to_disk()

func get_run_history() -> Array[RunData]:
	return save_resource.run_history
