extends DoorCompresser
class_name TileDoorCompresser

const BITS_FOR_N_TILES = 4

func compress(bit_packer : OutputMemoryBitStream, class_instance_id : int, state_data):
	super.compress(bit_packer, class_instance_id, state_data)
	bit_packer.compress_int_into_x_bits(state_data.n_tiles, BITS_FOR_N_TILES)
	bit_packer.compress_bool(state_data.is_horizontal)

#func test_decompress(bit_packer : OutputMemoryBitStream):
#	var data_container = TileDoorData.new()
#	var instance_id = bit_packer.decompress_int(BaseCompression.n_class_instance_bits)
#	data_container.global_position = bit_packer.variable_decompress(TYPE_INT, true)
#	data_container.is_open = bit_packer.decompress_bool()
#	data_container.n_tiles = bit_packer.decompress_int(BITS_FOR_N_TILES)
#	data_container.is_horizontal = bit_packer.decompress_bool()
#	return data_container
