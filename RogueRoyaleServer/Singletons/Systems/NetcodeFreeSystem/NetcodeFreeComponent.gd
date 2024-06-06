extends Node


var class_id_to_instances = {}
var bit_packer = OutputMemoryBitStream.new()

func add_component_to_free(class_id : String, class_instance : int) -> void:
	if class_id_to_instances.has(class_id):
		class_id_to_instances[class_id].append(class_instance)
	else:
		class_id_to_instances[class_id] = [class_instance]

func get_queue_free_count(class_id : String) -> int:
	if class_id_to_instances.has(class_id):
		return class_id_to_instances[class_id].size()
	else:
		return 0

func has_component(class_id : String, instance_id : int) -> bool:
	if class_id_to_instances.has(class_id):
		return class_id_to_instances[class_id].has(instance_id)
	else:
		return false
