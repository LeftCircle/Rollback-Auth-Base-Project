extends BaseModuleCompresser
class_name BaseRangeWeaponCompresser

func compress(bit_packer : OutputMemoryBitStream, netcode) -> void:
	super.compress(bit_packer, netcode)
	var module_data = netcode.state_data
	bit_packer.compress_unit_vector(module_data.aiming_direction)
	bit_packer.compress_bool(module_data.is_holstered)
	bit_packer.compress_bool(module_data.fired_this_frame)

func decompress(bit_packer : OutputMemoryBitStream):
	var server_data = BaseRangeWeaponData.new()
	server_data.aiming_direction = bit_packer.decompress_unit_vector()
	server_data.is_holstered = bit_packer.decompress_bool()
	server_data.fired_this_frame = bit_packer.decompress_bool()
	if server_data.is_holstered == false:
		Logging.log_line("Pistol is drawn")
	return server_data
