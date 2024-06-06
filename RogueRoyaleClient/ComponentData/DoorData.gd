extends BaseModuleData
class_name DoorData

var is_open : bool = false
var global_position : Vector2
var connected_doors = []

func set_data_with_obj(other_obj): 
	is_open = other_obj.is_open
	global_position = other_obj.global_position
	connected_doors = other_obj.connected_doors.duplicate(true)
	frame = other_obj.frame

func set_obj_with_data(other_obj): 
	other_obj.is_open = is_open
	other_obj.global_position = global_position
	other_obj.connected_doors = connected_doors.duplicate(true)
	other_obj.frame = frame

func matches(other_obj) -> bool: 
	return (
	(ModularDataComparer.compare_values(is_open, other_obj.is_open) == true) and
	(ModularDataComparer.compare_values(global_position, other_obj.global_position) == true) and
	(ModularDataComparer.compare_values(frame, other_obj.frame) == true)
	)
