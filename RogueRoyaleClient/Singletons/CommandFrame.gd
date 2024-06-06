extends Node

const MAX_FRAME_NUMBER = 16777215
const MAX_FRAME_FOR_MOD = MAX_FRAME_NUMBER + 1

var half_max_frame = MAX_FRAME_NUMBER / 2
var frame_length_sec : float = 1.0 / float(ProjectSettings.get_setting("physics/common/physics_ticks_per_second"))
var frame_length_msec : float = frame_length_sec * 1000
var frame : int = 0
var execution_frame : int = 0
var last_frame_number = 0
var command_step_buffer : int = 0
var sync_frame_difference : int
var previous_command_frame = -1
var game_start_step : int = 0

var input_buffer_frame : int = 0
var compressed_frame

var iteration_speed_manager : IterationSpeedManager
var input_buffer : int

var debug_world_states_received_last_frame = 0

func _ready():
	process_priority = ProjectSettings.get_setting("global/CF_PROCESS_PRIORITY")
	iteration_speed_manager = IterationSpeedManager.new()
	add_child(iteration_speed_manager)
	input_buffer = ProjectSettings.get_setting("global/input_buffer")

func set_buffer(client_buffer) -> void:
	print("Buffered frame = ", client_buffer)
	command_step_buffer = client_buffer

func sync_command_frame(synced_frame : int) -> void:
	print("Syncing command frame to " + str(synced_frame))
	sync_frame_difference = synced_frame - frame
	last_frame_number = frame + sync_frame_difference - 1
	frame = frame + sync_frame_difference
	previous_command_frame = frame - 10

func execute() -> int:
	previous_command_frame = frame
	frame = (frame + 1) % MAX_FRAME_NUMBER
	execution_frame = frame
	input_buffer_frame = get_previous_frame(frame, input_buffer)
	compressed_frame = BaseCompression.compress_frame_into_3_bytes(frame)
	assert(frame <= MAX_FRAME_NUMBER)
	Logging.log_line("------------------------------------------------ COMMAND FRAME " + str(frame) + " ------------------------------------------------")
	_debug_stuff()
	iteration_speed_manager.execute()
	return frame

func _debug_stuff():
	Logging.log_line("Received " + str(debug_world_states_received_last_frame) + " World States last frame")
	debug_world_states_received_last_frame = 0

func command_frame_greater_than_previous(frame_n : int, previous_frame : int) -> bool:
	return (((frame_n > previous_frame) and (frame_n - previous_frame <= half_max_frame)) or
			(frame_n < previous_frame) and (previous_frame - frame_n > half_max_frame))

func frame_greater_than_or_equal_to(frame_n : int, smaller_frame : int) -> bool:
	if frame_n == smaller_frame:
		return true
	return command_frame_greater_than_previous(frame_n, smaller_frame)

func is_fame_greater_than(larger_frame : int, smaller_frame : int) -> bool:
	return (((larger_frame > smaller_frame) and (larger_frame - smaller_frame <= half_max_frame)) or
			(larger_frame < smaller_frame) and (smaller_frame - larger_frame > half_max_frame))

func difference_when_actual_is_ahead(expected_frame : int, actual_frame : int) -> int:
	assert(!command_frame_greater_than_previous(expected_frame, actual_frame))
	var diff = 0
	if abs(actual_frame - expected_frame) > half_max_frame:
		diff = MAX_FRAME_NUMBER - expected_frame + actual_frame
	else:
		diff = actual_frame - expected_frame
	return diff

func frame_difference(future_frame : int, past_frame : int) -> int:
	if abs(past_frame - future_frame) > half_max_frame:
		# Frame wraparound has occured.
		if past_frame < future_frame:
			# The past frame is actually ahead!
			var frames_till_wrap = MAX_FRAME_NUMBER - future_frame
			return -(frames_till_wrap + past_frame)
		else:
			var frames_till_wrap = MAX_FRAME_NUMBER - past_frame
			return future_frame + frames_till_wrap
	else:
		return future_frame - past_frame

func frame_difference_float(future_frame : float, past_frame : float) -> float:
	if abs(past_frame - future_frame) > half_max_frame:
		# Frame wraparound has occured.
		if past_frame < future_frame:
			# The past frame is actually ahead!
			var frames_till_wrap = MAX_FRAME_NUMBER - future_frame
			return -(frames_till_wrap + past_frame)
		else:
			var frames_till_wrap = MAX_FRAME_NUMBER - past_frame
			return future_frame + frames_till_wrap
	else:
		return future_frame - past_frame

func get_next_frame(frame_n : int = frame) -> int:
	return (frame_n + 1) % MAX_FRAME_NUMBER

func get_previous_frame(frame_n : int, n_frames_back = 1) -> int:
	return posmod(frame_n - n_frames_back, MAX_FRAME_FOR_MOD)

func equal_or_greater(frame_a, other_frame) -> bool:
	if frame_a == other_frame:
		return true
	return command_frame_greater_than_previous(frame_a, other_frame)

func get_command_frame_number() -> int:
	#return int((float(Time.get_ticks_msec()) / frame_length_msec)) + frame_difference
	return frame

func node_uses_command_frames(node : Node):
	node.process_priority = ProjectSettings.get_setting("global/PROCESS_AFTER_CF")
#	if node.get_class() == "CharacterBody2D":
#		node.set_command_frame_sec(frame_length_sec)
