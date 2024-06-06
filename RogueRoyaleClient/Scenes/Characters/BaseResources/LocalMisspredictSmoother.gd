extends Node2D
class_name LocalMisspredictSmoother

@export var snap_if_dist_less_than: int = 5
@export var to_buffer: bool = true
@export var to_log: bool = false
@export var speed = 200
@export var catchup_speed : int = 25

var next_global_pos : Vector2 = Vector2.ZERO
var previous_global_pos : Vector2 = Vector2.ZERO
var smoothed_pos : Vector2 = Vector2.ZERO

var miss_predict_just_occured = false
var is_in_misspredict = false
var snap_reached = false

var frame_length_sec = CommandFrame.frame_length_sec
var current_speed = speed

@onready var parent = get_parent()

func _ready():
	previous_global_pos = global_position
	smoothed_pos = global_position
	next_global_pos = global_position
	add_to_group("NewMisspredictSmoothing")

func execute():
	ready_next_frame(parent.global_position)
	if is_in_misspredict:
		current_speed += catchup_speed

func on_misspredict():
	miss_predict_just_occured = true
	snap_reached = false

func _process(delta):
	if to_buffer and is_in_misspredict:
		if to_log:
			print("In misspredict!!")
		#smoothed_pos.move_toward(next_global_pos, speed * delta)
		var move_dist = current_speed * delta
		if smoothed_pos.distance_squared_to(next_global_pos) <= pow(move_dist, 2):
			smoothed_pos = next_global_pos
			snap_reached = true
			current_speed = speed
		else:
			smoothed_pos = smoothed_pos + move_dist * smoothed_pos.direction_to(next_global_pos)
		global_position = smoothed_pos
		#position = position.move_toward(Vector2.ZERO, speed * delta)
	else:
		var lerp_t = Engine.get_physics_interpolation_fraction()
		global_position = lerp(previous_global_pos, next_global_pos, lerp_t)
		smoothed_pos = global_position

func ready_next_frame(new_pos : Vector2) -> void:
	if not is_in_misspredict and not miss_predict_just_occured:
		previous_global_pos = next_global_pos
		next_global_pos = new_pos
		smoothed_pos = previous_global_pos
	elif is_in_misspredict and not snap_reached:
		previous_global_pos = smoothed_pos
		next_global_pos = new_pos
		if smoothed_pos.distance_to(next_global_pos) < snap_if_dist_less_than:
			snap_reached = true
	elif miss_predict_just_occured and not is_in_misspredict:
		previous_global_pos = next_global_pos
		next_global_pos = new_pos
		smoothed_pos = previous_global_pos
		miss_predict_just_occured = false
		is_in_misspredict = true
	elif is_in_misspredict and snap_reached:
		is_in_misspredict = false
		snap_reached = false
		previous_global_pos = next_global_pos
		next_global_pos = new_pos
		smoothed_pos = previous_global_pos
