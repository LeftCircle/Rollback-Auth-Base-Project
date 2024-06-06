extends BaseModuleData
class_name ModularPlayerState

var state = PlayerStateManager.IDLE
var looking_vector = Vector2.ZERO
var position = Vector2.ZERO

func set_data_with_obj(other_obj): 
	state = other_obj.state
	looking_vector = other_obj.looking_vector
	position = other_obj.position
	frame = other_obj.frame

func set_obj_with_data(other_obj): 
	other_obj.state = state
	other_obj.looking_vector = looking_vector
	other_obj.position = position
	other_obj.frame = frame

func matches(other_obj) -> bool: 
	return (
	(ModularDataComparer.compare_values(state, other_obj.state) == true) and
	(ModularDataComparer.compare_values(looking_vector, other_obj.looking_vector) == true) and
	(ModularDataComparer.compare_values(position, other_obj.position) == true) and
	(ModularDataComparer.compare_values(frame, other_obj.frame) == true)
	)
