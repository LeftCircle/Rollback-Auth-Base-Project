extends RefCounted
class_name RoomOutlineData

var global_position

func set_data_with_obj(other_obj):
	global_position = other_obj.global_position

func set_obj_with_data(other_obj):
	other_obj.global_position = global_position

func matches(other_obj) -> bool:
	return (
	(ModularDataComparer.compare_values(global_position, other_obj.global_position) == true)
	)
