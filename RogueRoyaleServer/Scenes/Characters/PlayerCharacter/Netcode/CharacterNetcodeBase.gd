extends NetcodeBase
class_name CharacterNetcodeBase

var entity

func init(new_entity, new_class_id : String, new_state_data, new_state_compresser) -> void:
	entity = new_entity
	set_class_id(new_class_id)
	state_data = new_state_data
	state_compresser = new_state_compresser
	#entity.connect("ready",Callable(self,"_on_ready"))
	#entity.connect("physics_process_started",Callable(self,"_on_entity_physics_process_started"))

func assign_class_instance_id():
	ObjectCreationRegistry.assign_class_instance_id(entity)
	ObjectCreationRegistry.network_id_to_instance_id[entity.player_id] = class_instance_id

func compress():
	_reset()
	Logging.log_line("start of compress process for netcode")
	state_compresser.compress(netcode_bit_stream, class_instance_id, state_data)
	netcode_bit_stream.finish_compress()

func send_to_clients(clients : Array = [WorldState.SEND_TO_ALL]):
	if entity.is_in_group("Players"):
		PlayerStateSync.add_netcode_to_compress(self, clients)
	else:
		WorldState.add_netcode_to_compress(self, clients)
