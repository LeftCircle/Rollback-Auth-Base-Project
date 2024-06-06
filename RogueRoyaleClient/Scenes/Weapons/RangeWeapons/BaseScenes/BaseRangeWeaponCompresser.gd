extends BaseModuleCompresser
class_name BaseRangeWeaponCompresser

func _init_server_data():
	server_data = BaseRangeWeaponData.new()

func compress(bit_packer : OutputMemoryBitStream, module_data) -> void:
	bit_packer.compress_unit_vector(module_data.aiming_direction)
	bit_packer.compress_bool(module_data.is_holstered)
	bit_packer.compress_bool(module_data.fired_this_frame)

func decompress(bit_packer : OutputMemoryBitStream, netcode : NetcodeForModules):
	super.decompress(bit_packer, netcode)
	server_data.aiming_direction = bit_packer.decompress_unit_vector()
	server_data.is_holstered = bit_packer.decompress_bool()
	server_data.fired_this_frame = bit_packer.decompress_bool()
	return server_data

#func remote_decompress(bit_reader : BitArrayReader):
#	return decompress(bit_reader)
