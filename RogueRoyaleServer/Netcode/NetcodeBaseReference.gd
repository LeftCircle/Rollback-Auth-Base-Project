extends NetcodeBase
class_name NetcodeBaseEntity

var entity

func init(new_entity, new_class_id : String, new_state_data, new_state_compresser) -> void:
	entity = new_entity
	if not entity.is_connected("ready",Callable(self,"_on_ready")):
		entity.connect("ready",Callable(self,"_on_ready"))
	set_class_id(new_class_id)
	state_data = new_state_data
	state_compresser = new_state_compresser

func compress():
	_reset()
	state_compresser.compress(netcode_bit_stream, class_instance_id, state_data)
	netcode_bit_stream.finish_compress()

func write_compressed_data_to_stream(bit_stream : OutputMemoryBitStream) -> void:
	netcode_bit_stream.write_into_other_stream(bit_stream)

func _on_ready():
	ObjectCreationRegistry.assign_class_instance_id(entity)

func _reset():
	netcode_bit_stream.reset()
