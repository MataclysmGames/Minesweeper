extends Node2D

@onready var audio_stream_player : AudioStreamPlayer = $AudioStreamPlayer

var main_theme : Resource = load("res://external_assets/100870__xythe__loop.wav")
var current_audio_resource = "none"

func _ready():
	pass

func play_main_theme(pitch : float = 1.0):
	play_audio(main_theme, -30.0, pitch)

func play_audio(audio : AudioStream, volume : float = 0.0, pitch : float = 1.0, transition_duration : float = 2.0):
	if not audio:
		return
	if audio.resource_path == current_audio_resource:
		audio_stream_player.create_tween().tween_property(audio_stream_player, "volume_db", volume, transition_duration)
		audio_stream_player.create_tween().tween_property(audio_stream_player, "pitch_scale", pitch, transition_duration)
	else:
		current_audio_resource = audio.resource_path
		var tween = audio_stream_player.create_tween()
		if audio_stream_player.playing:
			tween.tween_property(audio_stream_player, "volume_db", -100, transition_duration)
		tween.tween_callback(func(): audio_stream_player.stream = audio)
		tween.tween_callback(func(): audio_stream_player.volume_db = -30)
		tween.tween_callback(func(): audio_stream_player.pitch_scale = pitch)
		tween.tween_callback(audio_stream_player.play)
		tween.tween_property(audio_stream_player, "volume_db", volume, transition_duration)
		
func stop_audio(fade_duration : float = 1.0):
	current_audio_resource = "none"
	var tween = audio_stream_player.create_tween()
	tween.tween_property(audio_stream_player, "volume_db", -100, fade_duration)
	tween.tween_callback(audio_stream_player.stop)
