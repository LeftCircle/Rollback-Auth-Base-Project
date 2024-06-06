extends RefCounted
class_name BaseRangeWeaponData

var aiming_direction = Vector2.ZERO
var is_holstered = true
var fired_this_frame = false

func set_data_with_obj(other_obj):
	aiming_direction = other_obj.aiming_direction
	is_holstered = other_obj.is_holstered
	fired_this_frame = other_obj.fired_this_frame

func set_obj_with_data(other_obj):
	other_obj.aiming_direction = aiming_direction
	other_obj.is_holstered = is_holstered
	other_obj.fired_this_frame = fired_this_frame

func matches(other_obj) -> bool:
	return (
	(ModularDataComparer.compare_values(aiming_direction, other_obj.aiming_direction) == true) and
	(ModularDataComparer.compare_values(is_holstered, other_obj.is_holstered) == true) and
	(ModularDataComparer.compare_values(fired_this_frame, other_obj.fired_this_frame) == true)
	)
