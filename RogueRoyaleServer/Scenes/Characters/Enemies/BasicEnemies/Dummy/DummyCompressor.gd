extends EntityBaseCompresser
class_name DummyCompresser

const N_BITS_FOR_STATE = 2
const N_BITS_FOR_HEALTH = 10

func compress(bit_packer : OutputMemoryBitStream, class_instance_id : int, state_data) -> void:
	super.compress(bit_packer, class_instance_id, state_data)
	#bit_packer.compress_int_into_x_bits(state_data.state, N_BITS_FOR_STATE)
	#bit_packer.variable_compress(state_data.global_position, true)
