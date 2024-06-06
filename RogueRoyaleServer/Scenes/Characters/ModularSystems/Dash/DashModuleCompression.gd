extends BaseModuleCompresser
class_name DashModuleCompression

const DASH_FRAME_BITS = 6

func compress(bit_packer : OutputMemoryBitStream, netcode : NetcodeForModules) -> void:
	super.compress(bit_packer, netcode)
	var module_data = netcode.state_data
	bit_packer.variable_compress(module_data.dash_speed)
	bit_packer.compress_int_into_x_bits(module_data.dash_frames, DASH_FRAME_BITS)
	bit_packer.compress_int_into_x_bits(module_data.current_dash_frames, DASH_FRAME_BITS)
	bit_packer.compress_unit_vector(module_data.dash_direction)
	bit_packer.compress_bool(module_data.is_dashing)

# ClassID will have been read by the player state to get here
func decompress(bit_packer : OutputMemoryBitStream):
	var server_data = DashModuleData.new()
	server_data.dash_speed = bit_packer.variable_decompress(TYPE_INT)
	server_data.dash_frames = bit_packer.decompress_int(DASH_FRAME_BITS)
	server_data.current_dash_frames = bit_packer.decompress_int(DASH_FRAME_BITS)
	server_data.dash_direction = bit_packer.decompress_unit_vector()
	server_data.is_dashing = bit_packer.decompress_bool()
	return server_data



