extends BaseModuleData
class_name RoomOutlineData

var global_position

func set_data_with_obj(other_obj): 
	global_position = other_obj.global_position
	frame = other_obj.frame

func set_obj_with_data(other_obj): 
	other_obj.global_position = global_position
	other_obj.frame = frame

func matches(other_obj) -> bool: 
	return (
	(ModularDataComparer.compare_values(global_position, other_obj.global_position) == true) and
	(ModularDataComparer.compare_values(frame, other_obj.frame) == true)
	)
