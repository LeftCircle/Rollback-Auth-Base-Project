extends InputActions
class_name InputActionsFromServer

var is_current_set = false
var is_past_set = false

func set_current_actions(new_action : ActionFromClient) -> void:
	super.set_current_actions(new_action)
	is_current_set = true

func set_previous_actions(past_action : ActionFromClient) -> void:
	super.set_previous_actions(past_action)
	is_past_set = true

func is_fully_received() -> bool:
	return is_current_set == true and is_past_set == true

