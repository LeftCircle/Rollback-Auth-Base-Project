extends BaseModuleCompresser
class_name InputQueueCompression

const BITS_FOR_HELD_FRAMES = 8
const BITS_FOR_INPUT = 3

func _init_server_data():
	server_data = InputQueueData.new()

func compress(bit_packer : OutputMemoryBitStream, module_data : InputQueueData):
	bit_packer.compress_int_into_x_bits(module_data.input, BITS_FOR_INPUT)
	bit_packer.compress_bool(module_data.is_released)
	bit_packer.compress_int_into_x_bits(module_data.held_frames, BITS_FOR_HELD_FRAMES)

func decompress(bit_packer : OutputMemoryBitStream, netcode : NetcodeForModules):
	super.decompress(bit_packer, netcode)
	server_data.input = bit_packer.decompress_int(BITS_FOR_INPUT)
	server_data.is_released = bit_packer.decompress_bool()
	server_data.held_frames = bit_packer.decompress_int(BITS_FOR_HELD_FRAMES)
	return server_data
