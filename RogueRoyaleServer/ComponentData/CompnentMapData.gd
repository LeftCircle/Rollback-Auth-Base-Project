extends RefCounted
class_name ComponentMapData

var component
var added_frame : int

func set_data_with_obj(other_obj):
	component = other_obj.component
	added_frame = other_obj.added_frame

func set_obj_with_data(other_obj):
	other_obj.component = component
	other_obj.added_frame = added_frame

func matches(other_obj) -> bool:
	return (
	(ModularDataComparer.compare_values(component, other_obj.component) == true) and
	(ModularDataComparer.compare_values(added_frame, other_obj.added_frame) == true)
	)
