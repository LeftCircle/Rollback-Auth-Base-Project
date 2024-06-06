extends NetcodeBase
class_name MobNetcodeBase


var entity

func init(new_entity, new_class_id : String, new_state_data, new_state_compresser) -> void:
	entity = new_entity
	set_class_id(new_class_id)
	state_data = new_state_data
	state_compresser = new_state_compresser
	entity.connect("ready",Callable(self,"_on_ready"))
	#entity.connect("physics_process_started",Callable(self,"_on_entity_physics_process_started"))

func _on_ready():
	ObjectCreationRegistry.assign_class_instance_id(entity)

func _on_entity_physics_process_started():
	_reset()
	WorldState.add_netcode_to_compress(self)

func compress():
	Logging.log_line("start of compress process for netcode")
	state_compresser.compress(netcode_bit_stream, class_instance_id, state_data)
	netcode_bit_stream.finish_compress()
