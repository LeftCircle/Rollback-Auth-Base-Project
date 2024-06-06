extends Node
#class_name PlayerInputHandler
#
#var input_sender
#var previous_command_frame : int
#var current_frame_data = []
#var current_inputs = ActionFromClient.new()
#
#func _ready():
#	input_sender = InputSenderOld.new()
#	input_sender.name = "InputSender"
#	previous_command_frame = CommandFrame.frame - 1
#	add_child(input_sender, true)
#
#func get_and_send_inputs(looking_vector : Vector2):
#	current_frame_data.clear()
#	var command_frame = CommandFrame.frame
#	var n_frames_to_execute = _get_n_frames_to_execute(command_frame)
#	current_inputs = _track_inputs(command_frame, looking_vector)
#	input_sender.receive_current_frame_data(current_frame_data)
#	_create_empty_inputs(command_frame, n_frames_to_execute)
#	input_sender.send_input_history_and_swap_buffers()
#	previous_command_frame = command_frame
#	return current_inputs
#
#func _get_n_frames_to_execute(command_frame) -> int:
#	var n_frames_to_execute = command_frame - previous_command_frame
#	if n_frames_to_execute <= 0:
#		Logging.log_line("NEGATIVE FRAME. CF = " + str(command_frame) + " PREVIOUS = " + str(previous_command_frame) + " DIFF + " + str(n_frames_to_execute))
#		command_frame = previous_command_frame + 1
#		n_frames_to_execute = 1
#	if n_frames_to_execute > 1:
#		Logging.log_line("SKIPPED " + str(n_frames_to_execute - 1) + " FRAMES")
#	return n_frames_to_execute
#
## Executing multiple frames is a byproduct of our hybrid time/physics frame
## approaches. According to https://godotengine.org/article/agile-input-processing-is-here-for-smoother-gameplay
## Each physics frame SHOULD have inputs for it. We track unsent command frames to
## let the server know that no inputs were entered for the TIME version of a frame.
#func _create_empty_inputs(current_frame : int, n_frames : int) -> void:
#	for i in range(n_frames - 1):
#		var frame_n = current_frame - i - 1
#		input_sender.create_empty_input(frame_n)
#
#func _track_inputs(command_frame_n : int, looking_vector : Vector2):
#	var frame_data = {command_frame_n : current_inputs.action_dict.duplicate(true)}
#	current_inputs.track_inputs(looking_vector)
#	frame_data = {command_frame_n : current_inputs.action_dict.duplicate(true)}
#	current_frame_data.append(frame_data)
#	return current_inputs
