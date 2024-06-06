extends EntityBaseCompresser
class_name DummyCompresser

const N_BITS_FOR_STATE = 2

func _init_server_data():
	server_data = ServerEnemyState.new()

func compress(bit_packer : OutputMemoryBitStream, state_data) -> void:
	super.compress(bit_packer, state_data)
	#bit_packer.compress_int_into_x_bits(state_data.state, N_BITS_FOR_STATE)
	#bit_packer.variable_compress(state_data.global_position, true)

func decompress(frame : int, bit_packer : OutputMemoryBitStream):
	#server_data.state = bit_packer.decompress_int(N_BITS_FOR_STATE)
	#server_data.global_position = bit_packer.variable_decompress(TYPE_VECTOR2, true)
	#.decompress(frame, bit_packer)
	server_data.frame = frame
	return server_data
