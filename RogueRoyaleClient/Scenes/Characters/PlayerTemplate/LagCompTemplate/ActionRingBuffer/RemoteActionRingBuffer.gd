extends ActionRingBuffer
class_name RemoteActionRingBuffer

var remote_action_receiver = RemoteActionReceiver.new()

func _init():
	super._init()
	remote_action_receiver.init(self)

func get_custom_class() -> String:
	return "RemoteActionRingBuffer"

func get_action_or_duplicate_for_frame(frame : int) -> ActionFromClient:
	if already_received_action(frame):
		return history[frame % history_size]
	else:
		return _copy_previous_actions_into_action_for(frame)

func _copy_previous_actions_into_action_for(frame : int) -> ActionFromClient:
	var previous_action : ActionFromClient = get_action_for_frame(CommandFrame.get_previous_frame(frame))
	var action_at_frame_pos : ActionFromClient = get_action_for_frame(frame)
	action_at_frame_pos.duplicate(previous_action)
	action_at_frame_pos.is_from_client = false
	return action_at_frame_pos

func receive_action(frame : int, action : ActionFromClient) -> void:
	if not already_received_action(frame):
		Logging.log_line("Received action for frame %s" % [frame])
		_on_action_received(frame, action)

func already_received_action(frame : int) -> bool:
	var action = history[frame % history_size]
	return action.frame == frame and action.is_from_client

func _on_action_received(frame : int, action : ActionFromClient) -> void:
	var old_action : ActionFromClient = history[frame % history_size]
	var mismatch : ActionFromClientComparer.MISSMATCH_TYPE = ActionFromClientComparer.compare(action, old_action)
	if mismatch == ActionFromClientComparer.MISSMATCH_TYPE.ROLLBACK:
		_on_rollback_missmatch(frame, old_action, action)
	elif mismatch == ActionFromClientComparer.MISSMATCH_TYPE.SILENT:
		_on_silent_missmatch(frame, old_action, action)
	old_action.is_from_client = true
	old_action.frame = frame

func _on_rollback_missmatch(frame : int, predicted_action : ActionFromClient, actual_action : ActionFromClient) -> void:
	predicted_action.duplicate(actual_action)
	var reset_frame : int = CommandFrame.get_previous_frame(frame)
	Logging.log_line("Rollback missmatch due to incorrectly predicted actions. Adding reset frame %s" % [reset_frame])
	MissPredictFrameTracker.add_reset_frame(reset_frame)
	_set_all_future_actions_to(frame, predicted_action)

func _on_silent_missmatch(frame : int, predicted_action : ActionFromClient, actual_action : ActionFromClient) -> void:
	predicted_action.duplicate(actual_action)
	_copy_looking_vector_to_all_future_actions_from(frame, predicted_action)

func _copy_looking_vector_to_all_future_actions_from(frame : int, new_action : ActionFromClient) -> void:
	if CommandFrame.frame_difference(CommandFrame.frame, frame) > history_size:
		frame = CommandFrame.get_previous_frame(CommandFrame.frame, history_size)
	while frame < CommandFrame.frame:
		frame += 1
		var action = history[frame % history_size]
		if action.frame == frame and action.is_from_client:
			break
		else:
			action.action_data.looking_vector = new_action.action_data.looking_vector

func _set_all_future_actions_to(frame : int, new_action : ActionFromClient) -> void:
	while frame < CommandFrame.frame:
		frame += 1
		var action = history[frame % history_size]
		if action.frame == frame and action.is_from_client:
			break
		else:
			action.duplicate(new_action)

func receive_action_history_sliding_buffer(sliding_buffer : Array) -> void:
	remote_action_receiver.receive_action_history_sliding_buffer(sliding_buffer)

func get_most_recent_received_frame() -> int:
	return remote_action_receiver.most_recent_received_frame

func get_most_recent_action() -> ActionFromClient:
	var most_recent_frame = get_most_recent_received_frame()
	return history[most_recent_frame % history_size]
