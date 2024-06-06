extends NetcodeBase
class_name NetcodeForModules

var component
var owner_class_id : int
var owner_instance_id : int
var entity

func init(new_component, new_class_id, new_state_data, new_state_compresser) -> void:
	set_class_id(new_class_id)
	state_data = new_state_data
	state_compresser = new_state_compresser
	component = new_component
	component.connect("ready",Callable(self,"_on_ready"))

func add_owner(new_entity) -> void:
	entity = new_entity
	owner_class_id = ObjectCreationRegistry.class_id_to_int_id[entity.netcode.class_id]
	owner_instance_id = entity.netcode.class_instance_id
	send_to_clients()

func set_class_id(new_id : String) -> void:
	class_id = new_id.substr(0, 3)

func set_state_data(with_module) -> void:
	state_data.set_data_with_obj(with_module)

func _on_ready():
	ObjectCreationRegistry.assign_class_instance_id(component)

func _on_entity_ready():
	pass

func compress():
	_set_state_data()
	_reset()
	state_compresser.compress(netcode_bit_stream, self)
	netcode_bit_stream.finish_compress()

func send_to_clients(clients : Array = [WorldState.SEND_TO_ALL]):
	if entity.is_in_group("Players"):
		PlayerStateSync.add_netcode_to_compress(self, clients)
	else:
		WorldState.add_netcode_to_compress(self, clients)

func _set_state_data():
	component.set_state_data()
