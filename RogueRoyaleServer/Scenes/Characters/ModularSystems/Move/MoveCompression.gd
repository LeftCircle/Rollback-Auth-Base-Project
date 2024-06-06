extends BaseModuleCompresser
class_name MoveCompression

#export var friction = 7500 # (int, 0, 10000)
#export var acceleration = 7500 # (int, 0, 10000)
#export var max_speed = 250 # (int, 0, 10000)

#var velocity = Vector2.ZERO
#var input_vector = Vector2.ZERO

# Start by compressing the class_id and then compress all attributes of the DashModuleData
# TO DO -> have a bitfield for the friction, max speed, and acceleration variables
func compress(bit_packer : OutputMemoryBitStream, netcode):
	super.compress(bit_packer, netcode)
	var module_data = netcode.state_data
	bit_packer.variable_compress(module_data.friction)
	bit_packer.variable_compress(module_data.acceleration)
	bit_packer.variable_compress(module_data.max_speed)
	bit_packer.variable_compress(module_data.velocity, true)
	bit_packer.variable_compress(module_data.global_position, true)

func decompress(bit_packer : OutputMemoryBitStream) -> MoveData:
	var decompressed_data = MoveData.new()
	decompressed_data.friction = bit_packer.variable_decompress(TYPE_INT)
	decompressed_data.acceleration = bit_packer.variable_decompress(TYPE_INT)
	decompressed_data.max_speed = bit_packer.variable_decompress(TYPE_INT)
	decompressed_data.velocity = bit_packer.variable_decompress(TYPE_VECTOR2, true)
	decompressed_data.global_position = bit_packer.variable_decompress(TYPE_VECTOR2, true)
	return decompressed_data

# ClassID will have been read by the player state to get here
#func decompress_into(module_data : MoveData, bit_reader : BitArrayReader) -> void:
#	module_data.friction = BaseCompression.variable_decompress(bit_reader, TYPE_INT)
#	module_data.acceleration = BaseCompression.variable_decompress(bit_reader, TYPE_INT)
#	module_data.max_speed = BaseCompression.variable_decompress(bit_reader, TYPE_INT)
#	module_data.velocity = BaseCompression.variable_decompress(bit_reader, TYPE_VECTOR2, true)
#
#func remote_compress(module_data : MoveData) -> Array:
#	return BaseCompression.variable_compress(module_data.velocity, true)
