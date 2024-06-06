extends EntityBaseCompresser
class_name DoorCompresser

func compress(bit_packer : OutputMemoryBitStream, class_instance_id : int, state_data):
	super.compress(bit_packer, class_instance_id, state_data)
	bit_packer.variable_compress(state_data.global_position, true)
	bit_packer.compress_bool(state_data.is_open)
	bit_packer.compress_int_array(state_data.connected_doors)
