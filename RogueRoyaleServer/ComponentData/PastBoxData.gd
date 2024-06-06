extends PastCollisionShapeData
class_name PastBoxData

var frame : int

func set_data_with_obj(other_obj):
	frame = other_obj.frame
	disabled = other_obj.disabled
	global_position = other_obj.global_position
	global_rotation = other_obj.global_rotation
	global_scale = other_obj.global_scale

func set_obj_with_data(other_obj):
	other_obj.frame = frame
	other_obj.disabled = disabled
	other_obj.global_position = global_position
	other_obj.global_rotation = global_rotation
	other_obj.global_scale = global_scale

func matches(other_obj) -> bool:
	return (
	(ModularDataComparer.compare_values(frame, other_obj.frame) == true) and
	(ModularDataComparer.compare_values(disabled, other_obj.disabled) == true) and
	(ModularDataComparer.compare_values(global_position, other_obj.global_position) == true) and
	(ModularDataComparer.compare_values(global_rotation, other_obj.global_rotation) == true) and
	(ModularDataComparer.compare_values(global_scale, other_obj.global_scale) == true)
	)
