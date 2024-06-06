extends BaseModuleCompresser
class_name StateSystemCompresser

func _init_server_data():
	server_data = StateSystemData.new()

func compress(bit_packer : OutputMemoryBitStream, module_data):
	bit_packer.compress_int_into_x_bits(module_data.state, SystemController.n_bits_for_states)
	bit_packer.compress_int_into_x_bits(module_data.queued_state, SystemController.n_bits_for_states)
	bit_packer.compress_int_into_x_bits(module_data.queued_unregister, SystemController.n_bits_for_states)

func decompress(bit_packer : OutputMemoryBitStream, netcode : NetcodeForModules):
	super.decompress(bit_packer, netcode)
	server_data.state = bit_packer.decompress_int(SystemController.n_bits_for_states)
	server_data.queued_state = bit_packer.decompress_int(SystemController.n_bits_for_states)
	server_data.queued_unregister = bit_packer.decompress_int(SystemController.n_bits_for_states)
	return server_data
