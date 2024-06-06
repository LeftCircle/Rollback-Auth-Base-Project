extends Node
class_name BaseNodeComponent

var frame : int = 0
var is_entity = false
var entity
var data_container = null
var component_data = ComponentData.new()

func _init():
	_data_container_init()

func _data_container_init():
	#print("No data container for ", self.name)
	pass

func reset_to(data) -> void:
	if is_instance_valid(data_container):
		data_container.set_data_with_obj(data)
	else:
		data.set_obj_with_data(self)

func connect_to_entity(connected_entity):
	entity = connected_entity

func disconnect_from_entity() -> void:
	#entity = null
	pass

func save_history(frame : int) -> void:
	pass

func reset_to_frame(frame : int) -> void:
	pass
