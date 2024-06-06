extends Node2D
class_name MissPredictSmoother

@export var snap_if_dist_less_than: int = 5
@export var to_buffer: bool = false
@export var to_log: bool = false
@export var angular_freq: float = 25.0
@export var damping_ratio = 0.5 # (float, 0, 1)

var next_global_pos : Vector2 = Vector2.ZERO
var previous_global_pos : Vector2 = Vector2.ZERO
var smoothed_pos : Vector2 = Vector2.ZERO

var miss_predict_just_occured = false
var is_in_misspredict = false
var snap_reached = false

var frame_length_sec = CommandFrame.frame_length_sec
var spring = CriticallyDampedSpring.new()

@onready var parent = get_parent()

func _ready():
	spring.starting_ang_freq = angular_freq
	spring.dampingRatio = damping_ratio
	#next_frame_sec = float(Time.get_ticks_msec()) / 1000.0
	previous_global_pos = global_position
	smoothed_pos = global_position
	next_global_pos = global_position
	add_to_group("NewMisspredictSmoothing")

func execute():
	#_set_unbuffered_global_pos(parent.global_position)
	ready_next_frame(parent.global_position)
	pass

func _set_unbuffered_global_pos(new_pos : Vector2) -> void:
	previous_global_pos = next_global_pos
	next_global_pos = new_pos
	global_position = previous_global_pos

func on_misspredict():
	miss_predict_just_occured = true
	snap_reached = false

func _process(delta):
	if to_buffer and is_in_misspredict:
		if to_log:
			print("In misspredict!!")
		_set_position_with_spring(delta)
	else:
		var lerp_t = Engine.get_physics_interpolation_fraction()
		global_position = lerp(previous_global_pos, next_global_pos, lerp_t)
		smoothed_pos = global_position

func _set_position_with_spring(delta : float):
	var direction_to_new = smoothed_pos.direction_to(next_global_pos)
	var starting_length = spring.length_to_eq
	spring.advance(delta)
	if to_log:
		print(spring.vel)
	var delta_length = starting_length - spring.length_to_eq
	smoothed_pos += delta_length * direction_to_new
	global_position = smoothed_pos
	if spring.length_to_eq < snap_if_dist_less_than:
		snap_reached = true
		#previous_global_pos = smoothed_pos
		if to_log:
			print("Out of misspredict on frame " + str(CommandFrame.frame))

func ready_next_frame(new_pos : Vector2) -> void:
	if not is_in_misspredict and not miss_predict_just_occured:
		previous_global_pos = next_global_pos
		next_global_pos = new_pos
	elif is_in_misspredict and not snap_reached:
		var vel = (new_pos - smoothed_pos) / frame_length_sec
		previous_global_pos = smoothed_pos
		next_global_pos = new_pos
		spring.set_start_and_end(smoothed_pos, next_global_pos)
		#spring.vel += vel / 8
		miss_predict_just_occured = false
	elif miss_predict_just_occured and not is_in_misspredict:
		previous_global_pos = next_global_pos
		next_global_pos = new_pos
		var local_pos = position
		smoothed_pos = previous_global_pos
		spring.set_start_and_end(smoothed_pos, next_global_pos)
		miss_predict_just_occured = false
		is_in_misspredict = true
	elif is_in_misspredict and snap_reached:
		is_in_misspredict = false
		snap_reached = false
		previous_global_pos = next_global_pos
		next_global_pos = new_pos
		global_position = previous_global_pos
		spring.zero_velocity()

func _set_new_spring_values(new_pos) -> void:
	spring.set_start_and_end(next_global_pos, new_pos)



