@tool
extends Marker2D
class_name Pivot2D

@export var set_global_scale_to_one: bool = true
@export var pivot_degrees: float = 0

func _process(_delta):
	global_rotation_degrees = pivot_degrees
	if set_global_scale_to_one:
		global_scale = Vector2.ONE

func rotate_degrees(degrees : float) -> void:
	pivot_degrees = degrees

func rotate_radians(radians : float) -> void:
	pivot_degrees = rad_to_deg(radians)
