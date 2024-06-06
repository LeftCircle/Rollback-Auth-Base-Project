extends Resource
class_name ActionRingBuffer

signal received_action(action)

const history_size = 180

var history : Array[ActionFromClient] = []

var player_id : int

var input_buffer = ProjectSettings.get_setting("global/input_buffer")

func _init():
	for i in range(history_size):
		history.append(ActionFromClient.new())

func get_action_or_duplicate_for_frame(frame : int):
	var actions = history[frame % history_size]
	if not actions.frame == frame:
		_redo_last_actions_or_set_to_none(frame, actions)
	return actions

func get_action_for_frame(frame : int) -> ActionFromClient:
	return history[frame % history_size]

func _redo_last_actions_or_set_to_none(frame : int, actions : ActionFromClient):
	Logging.log_line("No actions for frame " + str(frame))
	var previous_frame = CommandFrame.get_previous_frame(frame)
	var previous_actions = history[previous_frame % history_size]
	if previous_actions.frame != previous_frame:
		actions.reset()
		_set_action_to_predicted(frame, actions)
		Logging.log_line("No previous frame. Setting this frame to unexecuted")
		actions.log_action()
	else:
		actions.duplicate(previous_actions)
		_set_action_to_predicted(frame, actions)
		actions.log_action()

func _set_action_to_predicted(frame : int, action : ActionFromClient) -> void:
	action.is_from_client = false
	action.frame = frame

func has_received_action_for_frame(frame : int) -> bool:
	var hist = history[frame % history_size] as ActionFromClient
	if hist.frame == frame:
		return hist.is_from_client
	return false

func has_received_current_and_previous_for_frame(frame : int) -> bool:
	var received_current = has_received_action_for_frame(frame)
	var received_previous = has_received_action_for_frame(CommandFrame.get_previous_frame(frame))
	return received_current == true and received_previous == true

func copy_input_actions_for_frame_into(frame : int, into_actions : InputActions) -> void:
	var curr_actions = get_action_or_duplicate_for_frame(frame)
	var past_actions = get_action_or_duplicate_for_frame(CommandFrame.get_previous_frame(frame))
	into_actions.set_current_actions(curr_actions)
	into_actions.set_previous_actions(past_actions)

func receive_action(frame : int, action : ActionFromClient) -> void:
	var old_action = history[frame % history_size]
	old_action.duplicate(action)
	old_action.frame = frame
	old_action.is_from_client = true

func get_custom_class() -> String:
	return "ActionRingBuffer"
