extends Node
class_name BaseNetcodeModule

var netcode = NetcodeForModules.new()
var execution_frame : int = 0
var data_container = null
var entity
var is_entity = false

func _init():
	_data_container_init()
	_netcode_init()

func add_owner(new_entity) -> void:
	entity = new_entity
	netcode.add_owner(new_entity)

func _data_container_init():
	pass

func _netcode_init():
	assert(false) #,"Child classes must override _netcode_init()")

func connect_timer():
	pass

func set_state_data():
	if is_instance_valid(data_container):
		pass
	else:
		netcode.state_data.set_data_with_obj(self)
