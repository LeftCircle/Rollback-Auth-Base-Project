extends BaseModuleCompresser
class_name AmmoCompresser

const n_ammo_bits = 6

func compress(bit_packer : OutputMemoryBitStream, netcode) -> void:
	super.compress(bit_packer, netcode)
	var module_data = netcode.state_data
	bit_packer.compress_int_into_x_bits(module_data.max_ammo, n_ammo_bits)
	bit_packer.compress_int_into_x_bits(module_data.current_ammo, n_ammo_bits)

#func decompress(bit_packer : OutputMemoryBitStream):
#	var server_data
#	server_data.max_ammo = bit_packer.decompress_int(n_ammo_bits)
#	server_data.current_ammo = bit_packer.decompress_int(n_ammo_bits)
#	return server_data
