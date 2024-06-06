extends RefCounted
class_name PlayerHistoryData

var frame : int = -1
var player_state = PlayerState.new()
var input_actions = InputActions.new()

#func get_class():
#	return "PlayerHistoryData"

func duplicate(player_history : PlayerHistoryData) -> void:
	frame = player_history.frame
	player_state.duplicate(player_history.player_state)
	input_actions.duplicate(player_history.input_actions)

func log_history():
	Logging.log_line("History " + str(frame))
	player_state.log_state()

func get_current_action():
	return input_actions.current_actions

func update(new_frame : int, p_state : PlayerState, actions : InputActions) -> void:
	Logging.log_line("Setting player history frame to " + str(new_frame))
	frame = new_frame
	player_state = p_state
	input_actions = actions

func add_inputs(new_frame : int, inputs : InputActions) -> void:
	frame = new_frame
	input_actions.duplicate(inputs)

func set_state(new_frame : int, with_state : PlayerState) -> void:
	new_frame = frame
	player_state.set_data_with_obj(with_state)
