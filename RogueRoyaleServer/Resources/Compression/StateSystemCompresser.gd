extends BaseModuleCompresser
class_name StateSystemCompresser

func compress(bit_packer : OutputMemoryBitStream, netcode) -> void:
	super.compress(bit_packer, netcode)
	bit_packer.compress_int_into_x_bits(netcode.state_data.state, SystemController.n_bits_for_states)
	bit_packer.compress_int_into_x_bits(netcode.state_data.queued_state, SystemController.n_bits_for_states)
	bit_packer.compress_int_into_x_bits(netcode.state_data.queued_unregister, SystemController.n_bits_for_states)
