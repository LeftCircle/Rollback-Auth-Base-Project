extends Node2D
class_name NodeInterpolater

var next_global_pos : Vector2 = Vector2.ZERO
var previous_global_pos : Vector2 = Vector2.ZERO

@onready var parent = get_parent()

func _ready():
	previous_global_pos = global_position

func _process(delta):
	_smooth_positions()

func _physics_process(delta):
	ready_next_frame(parent.global_position)

func _smooth_positions():
	global_position = lerp(previous_global_pos, next_global_pos, Engine.get_physics_interpolation_fraction())

func ready_next_frame(new_pos : Vector2) -> void:
	_set_unbuffered_global_pos(new_pos)

func _set_unbuffered_global_pos(new_pos : Vector2) -> void:
	previous_global_pos = next_global_pos
	next_global_pos = new_pos
	global_position = previous_global_pos
