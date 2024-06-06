extends RefCounted
class_name ClassAndInstanceID

var class_id : int
var class_instance_id : int

func set_data_with_obj(other_obj):
	class_id = other_obj.class_id
	class_instance_id = other_obj.class_instance_id

func set_obj_with_data(other_obj):
	other_obj.class_id = class_id
	other_obj.class_instance_id = class_instance_id

func matches(other_obj) -> bool:
	return (
	(ModularDataComparer.compare_values(class_id, other_obj.class_id) == true) and
	(ModularDataComparer.compare_values(class_instance_id, other_obj.class_instance_id) == true)
	)
