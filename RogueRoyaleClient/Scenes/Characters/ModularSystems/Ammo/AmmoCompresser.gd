extends BaseModuleCompresser
class_name AmmoCompresser

func _init_server_data():
	server_data = AmmoData.new()

const n_ammo_bits = 6

func compress(bit_packer : OutputMemoryBitStream, module_data) -> void:
	bit_packer.compress_int_into_x_bits(module_data.max_ammo, n_ammo_bits)
	bit_packer.compress_int_into_x_bits(module_data.current_ammo, n_ammo_bits)

func decompress(bit_packer : OutputMemoryBitStream, netcode : NetcodeForModules):
	super.decompress(bit_packer, netcode)
	server_data.max_ammo = bit_packer.decompress_int(n_ammo_bits)
	server_data.current_ammo = bit_packer.decompress_int(n_ammo_bits)
	return server_data
