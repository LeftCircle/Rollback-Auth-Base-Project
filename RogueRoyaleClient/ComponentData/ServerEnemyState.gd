extends EnemyState
class_name ServerEnemyState

var modular_abilties_this_frame : int

func set_data_with_obj(other_obj): 
	modular_abilties_this_frame = other_obj.modular_abilties_this_frame
	state = other_obj.state
	global_position = other_obj.global_position
	frame = other_obj.frame

func set_obj_with_data(other_obj): 
	other_obj.modular_abilties_this_frame = modular_abilties_this_frame
	other_obj.state = state
	other_obj.global_position = global_position
	other_obj.frame = frame

func matches(other_obj) -> bool: 
	return (
	(ModularDataComparer.compare_values(modular_abilties_this_frame, other_obj.modular_abilties_this_frame) == true) and
	(ModularDataComparer.compare_values(state, other_obj.state) == true) and
	(ModularDataComparer.compare_values(global_position, other_obj.global_position) == true) and
	(ModularDataComparer.compare_values(frame, other_obj.frame) == true)
	)
