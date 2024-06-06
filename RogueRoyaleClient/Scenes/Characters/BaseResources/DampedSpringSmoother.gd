extends Node2D
class_name DampedSpringSmoother

@export var to_log: bool = false
@export var angular_freq: float = 25.0
@export var damping_ratio = 0.5 # (float, 0, 1)


var next_global_pos : Vector2 = Vector2.ZERO
# This is the position with the spring applied to it?
var smoothed_pos : Vector2 = Vector2.ZERO
var frame_length_sec = CommandFrame.frame_length_sec
var spring = CriticallyDampedSpring.new()

func _ready():
	spring.starting_ang_freq = angular_freq
	spring.dampingRatio = damping_ratio
	smoothed_pos = global_position
	set_process(false)

func ready_next_frame(new_pos : Vector2) -> void:
	next_global_pos = new_pos
	spring.set_start_and_end(smoothed_pos, next_global_pos)
	#spring.vel = (next_global_pos - smoothed_pos) / frame_length_sec
	set_process(true)

func _process(delta : float) -> void:
#	var direction_to_new = smoothed_pos.direction_to(next_global_pos)
#	var starting_length = spring.length_to_eq
#	spring.advance(delta)
#	var delta_length = starting_length - spring.length_to_eq
#	smoothed_pos += delta_length * direction_to_new
#	global_position = smoothed_pos
	pass


