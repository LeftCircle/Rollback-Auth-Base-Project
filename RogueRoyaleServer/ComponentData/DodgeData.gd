extends RefCounted
class_name DodgeData

var stamina_cost : int = 1
var is_executing : bool = false
var animation_frame : int = 0

func set_data_with_obj(other_obj):
	stamina_cost = other_obj.stamina_cost
	is_executing = other_obj.is_executing
	animation_frame = other_obj.animation_frame

func set_obj_with_data(other_obj):
	other_obj.stamina_cost = stamina_cost
	other_obj.is_executing = is_executing
	other_obj.animation_frame = animation_frame

func matches(other_obj) -> bool:
	return (
	(ModularDataComparer.compare_values(stamina_cost, other_obj.stamina_cost) == true) and
	(ModularDataComparer.compare_values(is_executing, other_obj.is_executing) == true) and
	(ModularDataComparer.compare_values(animation_frame, other_obj.animation_frame) == true)
	)
