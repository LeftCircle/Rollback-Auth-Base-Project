extends RefCounted
class_name NetworkInstanceCounter

var class_id : String
var next_available_id : int = 0


func assign_instance_id(entity) -> void:
	entity.class_instance_id = next_available_id
	next_available_id += 1
