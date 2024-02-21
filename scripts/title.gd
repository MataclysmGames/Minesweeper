extends Control

const tween_duration : float = 0.6

@onready var title_container : VBoxContainer = $TitleContainer
@onready var title_buttons_container = $TitleButtonsContainer
@onready var exit_button : Button = $TitleButtonsContainer/ExitButton
@onready var start_button : Button = $TitleButtonsContainer/StartButton

@onready var difficulty_select_container : HBoxContainer = $DifficultySelectContainer
@onready var difficulty_select_buttons_container : MarginContainer = $DifficultySelectButtonsContainer
@onready var back_button : Button = $DifficultySelectButtonsContainer/BackButton
@onready var run_history_button = $DifficultySelectButtonsContainer/RunHistoryButton

@onready var easy_button : Button = $DifficultySelectContainer/EasyContainer/Button
@onready var normal_button : Button = $DifficultySelectContainer/NormalContainer/Button
@onready var hard_button : Button = $DifficultySelectContainer/HardContainer/Button
@onready var nightmare_button : Button = $DifficultySelectContainer/NightmareContainer/Button

@onready var easy_label : RichTextLabel = $DifficultySelectContainer/EasyContainer/Label
@onready var normal_label : RichTextLabel = $DifficultySelectContainer/NormalContainer/Label
@onready var hard_label : RichTextLabel = $DifficultySelectContainer/HardContainer/Label
@onready var nightmare_label : RichTextLabel = $DifficultySelectContainer/NightmareContainer/Label

@onready var background_particles : CPUParticles2D = $BackgroundParticles

@onready var run_history : RunHistory = $RunHistory

func _ready():
	SaveData.reload()
	BackgroundAudio.play_main_theme(0.66)
	exit_button.pressed.connect(exit_game)
	start_button.pressed.connect(show_difficulty_select)
	back_button.pressed.connect(show_title)
	run_history_button.pressed.connect(show_history)
	run_history.back_button.pressed.connect(show_difficulty_select_from_history)
	
	if SaveData.get_run_history().size() == 0:
		run_history_button.set_deferred("disabled", true)
	
	easy_button.pressed.connect(start_game.bind(Global.RunDifficulty.EASY))
	normal_button.pressed.connect(start_game.bind(Global.RunDifficulty.NORMAL))
	hard_button.pressed.connect(start_game.bind(Global.RunDifficulty.HARD))
	nightmare_button.pressed.connect(start_game.bind(Global.RunDifficulty.NIGHTMARE))
	
	# Move difficulty container off screen
	difficulty_select_container.position.x += 1000
	difficulty_select_buttons_container.position.x += 1000
	run_history.position.y -= 1000
	
	var best_easy_run : RunData = SaveData.get_saved_run(Global.RunDifficulty.EASY)
	var best_normal_run : RunData = SaveData.get_saved_run(Global.RunDifficulty.NORMAL)
	var best_hard_run : RunData = SaveData.get_saved_run(Global.RunDifficulty.HARD)
	var best_nightmare_run : RunData = SaveData.get_saved_run(Global.RunDifficulty.NIGHTMARE)
	
	easy_label.text = format_run(best_easy_run)
	normal_label.text = format_run(best_normal_run)
	hard_label.text = format_run(best_hard_run)
	nightmare_label.text = format_run(best_nightmare_run)
	
	background_particles.emitting = true

func exit_game():
	SaveData.save_to_disk()
	get_tree().quit()

func show_title():
	var tween = create_tween()
	tween.tween_property(difficulty_select_container, "position", difficulty_select_container.position + Vector2(1000, 0), tween_duration).set_trans(Tween.TRANS_EXPO)
	tween.parallel().tween_property(difficulty_select_buttons_container, "position", difficulty_select_buttons_container.position + Vector2(1000, 0), tween_duration).set_trans(Tween.TRANS_EXPO)
	tween.parallel().tween_property(title_container, "position", title_container.position + Vector2(1000, 0), tween_duration).set_trans(Tween.TRANS_EXPO)
	tween.parallel().tween_property(title_buttons_container, "position", title_buttons_container.position + Vector2(1000, 0), tween_duration).set_trans(Tween.TRANS_EXPO)

func show_difficulty_select():
	var tween = create_tween()
	tween.tween_property(difficulty_select_container, "position", difficulty_select_container.position + Vector2(-1000, 0), tween_duration).set_trans(Tween.TRANS_EXPO)
	tween.parallel().tween_property(difficulty_select_buttons_container, "position", difficulty_select_buttons_container.position + Vector2(-1000, 0), tween_duration).set_trans(Tween.TRANS_EXPO)
	tween.parallel().tween_property(title_container, "position", title_container.position + Vector2(-1000, 0), tween_duration).set_trans(Tween.TRANS_EXPO)
	tween.parallel().tween_property(title_buttons_container, "position", title_buttons_container.position + Vector2(-1000, 0), tween_duration).set_trans(Tween.TRANS_EXPO)
	
func show_history():
	var tween = create_tween()
	tween.tween_property(difficulty_select_container, "position", difficulty_select_container.position + Vector2(0, 1000), tween_duration).set_trans(Tween.TRANS_EXPO)
	tween.parallel().tween_property(difficulty_select_buttons_container, "position", difficulty_select_buttons_container.position + Vector2(0, 1000), tween_duration).set_trans(Tween.TRANS_EXPO)
	tween.parallel().tween_property(run_history, "position", run_history.position + Vector2(0, 1000), tween_duration).set_trans(Tween.TRANS_EXPO)
	
func show_difficulty_select_from_history():
	var tween = create_tween()
	tween.tween_property(difficulty_select_container, "position", difficulty_select_container.position + Vector2(0, -1000), tween_duration).set_trans(Tween.TRANS_EXPO)
	tween.parallel().tween_property(difficulty_select_buttons_container, "position", difficulty_select_buttons_container.position + Vector2(0, -1000), tween_duration).set_trans(Tween.TRANS_EXPO)
	tween.parallel().tween_property(run_history, "position", run_history.position + Vector2(0, -1000), tween_duration).set_trans(Tween.TRANS_EXPO)
	
func start_game(difficulty : Global.RunDifficulty):
	Global.current_difficulty = difficulty
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func format_run(run_data : RunData) -> String:
	if not run_data:
		return "[center]No save data"
	if run_data.current_level >= run_data.max_level:
		return "[center][color=green]Full Clear![/color][p][center]Best Score: %d" % [run_data.total_score]
	return "[center][color=orange]Cleared %d/%d[/color][p][center]Best Score: %d" % [run_data.current_level, run_data.max_level, run_data.total_score]
