extends NetcodeForModules
class_name NetcodeForFXManager

func compress() -> void:
	netcode_bit_stream.reset()
	netcode_bit_stream.compress_class_instance(class_instance_id)
	state_compresser.compress(netcode_bit_stream, state_data)
	netcode_bit_stream.finish_compress()
	#entity.reset(state_data)
