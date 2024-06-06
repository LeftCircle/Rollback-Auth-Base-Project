extends RefCounted
class_name InputActions
# All input processing logic from ActionFromClients occurs here

var current_actions = ActionFromClient.new()
var previous_actions = ActionFromClient.new()

func get_current_action():
	return current_actions

func receive_action(new_action : ActionFromClient) -> void:
	previous_actions.duplicate(current_actions)
	current_actions.duplicate(new_action)

func is_action_just_pressed(action : String) -> bool:
	return current_actions.is_action_pressed(action) and not previous_actions.is_action_pressed(action)

func is_action_just_released(action : String) -> bool:
	return not current_actions.is_action_pressed(action) and previous_actions.is_action_pressed(action)

func is_action_pressed(action : String) -> bool:
	return current_actions.is_action_pressed(action)

func is_action_released(action : String) -> bool:
	return !current_actions.is_action_pressed(action)

func get_looking_vector():
	return current_actions.get_looking_vector()

func get_input_vector():
	return current_actions.get_input_vector()

func get_direction_vector() -> Vector2:
	var input_vec = current_actions.get_input_vector()
	if input_vec == Vector2.ZERO:
		return current_actions.get_looking_vector()
	else:
		return input_vec

func duplicate(input_action : InputActions) -> void:
	current_actions.duplicate(input_action.current_actions)
	previous_actions.duplicate(input_action.previous_actions)

func set_current_actions(new_action : ActionFromClient) -> void:
	current_actions.duplicate(new_action)

func set_previous_actions(past_action : ActionFromClient) -> void:
	previous_actions.duplicate(past_action)

func reset():
	current_actions.reset()
	previous_actions.reset()

func log_input_actions():
	Logging.log_line("Previous = ")
	previous_actions.log_action()
	Logging.log_line("Current  = ")
	current_actions.log_action()
