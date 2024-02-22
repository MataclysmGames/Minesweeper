class_name BackgroundNoise
extends Node2D

const tween_duration : float = 150.0

@onready var texture_rect : TextureRect = $TextureRect

var tween : Tween

func _ready():
	tween = create_tween()
	tween.tween_property(texture_rect, "rotation_degrees", 0, 0).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(texture_rect, "rotation_degrees", 360, tween_duration).set_ease(Tween.EASE_IN_OUT)
	tween.parallel().tween_property(texture_rect, "scale", Vector2(2, 2), tween_duration).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(texture_rect, "rotation_degrees", 0, 0).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(texture_rect, "rotation_degrees", 360, tween_duration).set_ease(Tween.EASE_IN_OUT)
	tween.parallel().tween_property(texture_rect, "scale", Vector2(1, 1), tween_duration).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
	tween.set_loops()
