extends RefCounted
class_name NetworkInstanceCounter

var class_id : String
var next_available_id : int = 0


func assign_instance_id(entity) -> void:
	Logging.log_line("class_id " + str(entity.netcode.class_id) + " assigned instance id " + str(next_available_id))
	entity.netcode.class_instance_id = next_available_id
	next_available_id += 1
