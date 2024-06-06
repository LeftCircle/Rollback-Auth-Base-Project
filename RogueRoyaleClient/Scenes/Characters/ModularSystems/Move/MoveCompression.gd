extends BaseModuleCompresser
class_name MoveCompression


func _init_server_data():
	server_data = MoveData.new()

func compress(bit_packer : OutputMemoryBitStream, module_data : MoveData):
	bit_packer.variable_compress(module_data.friction)
	bit_packer.variable_compress(module_data.acceleration)
	bit_packer.variable_compress(module_data.max_speed)
	bit_packer.variable_compress(module_data.velocity, true)
	bit_packer.variable_compress(module_data.global_position, true)

# ClassID will have been read by the player state to get here
func decompress(bit_packer : OutputMemoryBitStream, netcode : NetcodeForModules):
	super.decompress(bit_packer, netcode)
	server_data.friction = bit_packer.variable_decompress(TYPE_INT)
	server_data.acceleration = bit_packer.variable_decompress(TYPE_INT)
	server_data.max_speed = bit_packer.variable_decompress(TYPE_INT)
	server_data.velocity = bit_packer.variable_decompress(TYPE_VECTOR2, true)
	server_data.global_position = bit_packer.variable_decompress(TYPE_VECTOR2, true)
	return server_data

