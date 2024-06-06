extends Node2D
class_name NetcodeNode2DComponent

var netcode = NetcodeForModules.new()
var execution_frame : int = 0
var data_container = null
var entity

func _init():
	_netcode_init()
	_data_container_init()

func add_owner(new_entity) -> void:
	entity = new_entity
	netcode.add_owner(entity)

func _data_container_init():
	pass

func _netcode_init():
	assert(false) #,"Child classes must override _netcode_init()")

func set_state_data():
	if is_instance_valid(data_container):
		pass
	else:
		netcode.state_data.set_data_with_obj(self)