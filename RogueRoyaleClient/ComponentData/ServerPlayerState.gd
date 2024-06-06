extends PlayerState
class_name ServerPlayerState


func set_data_with_obj(other_obj): 
	state = other_obj.state
	frame = other_obj.frame

func set_obj_with_data(other_obj): 
	other_obj.state = state
	other_obj.frame = frame

func matches(other_obj) -> bool: 
	return (
	(ModularDataComparer.compare_values(state, other_obj.state) == true) and
	(ModularDataComparer.compare_values(frame, other_obj.frame) == true)
	)
