extends RefCounted
class_name StateSystemData

var state : int = SystemController.STATES.MOVE
var queued_state : int = SystemController.STATES.NULL
var queued_unregister : int = SystemController.STATES.NULL

func set_data_with_obj(other_obj):
	state = other_obj.state
	queued_state = other_obj.queued_state
	queued_unregister = other_obj.queued_unregister

func set_obj_with_data(other_obj):
	other_obj.state = state
	other_obj.queued_state = queued_state
	other_obj.queued_unregister = queued_unregister

func matches(other_obj) -> bool:
	return (
	(ModularDataComparer.compare_values(state, other_obj.state) == true) and
	(ModularDataComparer.compare_values(queued_state, other_obj.queued_state) == true) and
	(ModularDataComparer.compare_values(queued_unregister, other_obj.queued_unregister) == true)
	)
