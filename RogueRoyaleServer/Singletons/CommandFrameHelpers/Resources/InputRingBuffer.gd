extends Resource
class_name InputRingBuffer

#const BUFFER_SIZE = 180
#const DIFFERENCE_THRESHOLD = BUFFER_SIZE / 2
#
#var buffer : Array = []
## Head is the oldest -> where data is read from
#var head : int = 0
#var last_executed_frame : int = 0
#var compression_functions = ActionFromClientCompression.new()
#
#
#func _init():
#	for _i in range(BUFFER_SIZE):
#		var action_from_client = ActionFromClient.new()
#		buffer.append(action_from_client)
#
#func update_actions(action_history : PackedByteArray) -> void:
#	if action_history.is_empty():
#		Logging.log_line("Received an empty action history")
#		return
#	var frame = compression_functions.get_frame_from_compressed_actions(action_history)
#	if CommandFrame.command_frame_greater_than_previous(frame, last_executed_frame):
#		var action_from_client = buffer[frame % BUFFER_SIZE]
#		compression_functions.decompress_actions_into(action_from_client, action_history)
#		Logging.log_line("Uncompressed action for frame " + str(frame))
#		action_from_client.log_action()
##	else:
##		Logging.log_line("Received old command frame")
##		Logging.log_line("Last executed = " + str(last_executed_frame) + " received: " + str(frame))
#
#
#func get_unexecuted_actions_including(frame : int):
#	if not CommandFrame.command_frame_greater_than_previous(frame, last_executed_frame):
#		return []
#	var end_position = frame % BUFFER_SIZE
#	Logging.log_line("Trying to get unexecuted frames including " + str(frame) + " at pos " + str(end_position))
#	var results = []
#	var position_difference = get_position_difference(end_position, head)
#	if position_difference > DIFFERENCE_THRESHOLD:
#		position_difference = 0
#	Logging.log_line("Position difference between frames " + str(end_position) + " " + str(head) + " = " + str(position_difference))
#	for i in range(position_difference + 1):
#		var expected_frame_n = frame - position_difference + i
#		var frame_n = CommandFrame.get_frame_number_from_expected(expected_frame_n)
#		var actions = get_action_or_duplicate_for_frame(frame_n)
#		results.append(actions)
#	last_executed_frame = frame
#	head = (end_position + 1) % BUFFER_SIZE
#	Logging.log_line("Setting head to " + str(head) + " Last executed = " + str(end_position))
#	return results
#
#func get_position_difference(ahead_pos, behind_pos):
#	if ahead_pos == 0:
#		head = 0
#		return 0
#	if ahead_pos < behind_pos:
#		return BUFFER_SIZE - behind_pos + ahead_pos
#	else:
#		return ahead_pos - behind_pos
#
#func get_action_or_duplicate_for_frame(frame : int):
#	var actions = buffer[frame % BUFFER_SIZE]
#	if not actions.frame == frame:
#		_redo_last_actions_or_set_to_none(frame, actions)
#		Logging.log_line("Duplicating previous actions for frame " + str(frame))
#	else:
#		Logging.log_line("Actions found! Actions are: ")
#		actions.log_action()
#	return actions
#
#func _redo_last_actions_or_set_to_none(frame : int, actions : ActionFromClient):
#	Logging.log_line("No actions for frame " + str(frame))
#	var previous_frame = CommandFrame.get_past_frame(frame, 1)
#	var previous_actions = buffer[previous_frame % BUFFER_SIZE]
#	if previous_actions.frame != previous_frame:
#		actions.reset()
#		actions.frame = frame
#		Logging.log_line("No previous frame. Setting this frame to unexecuted")
#		actions.log_action()
#	else:
#		actions.duplicate(previous_actions, true)
#		actions.frame = frame
#		Logging.log_line("Duplicating previous frame. Actions are " + str(actions.action_dict))
#		actions.log_action()
