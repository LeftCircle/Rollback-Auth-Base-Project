extends EntityBaseCompresser
class_name RoomOutlineCompresser

func compress(bit_packer : OutputMemoryBitStream, class_instance_id : int, state_data : RoomOutlineData):
	super.compress(bit_packer, class_instance_id, state_data)
	bit_packer.variable_compress(state_data.global_position, true)

func test_decompress(bit_packer : OutputMemoryBitStream):
	var data_container = RoomOutlineData.new()
	var instance_id = bit_packer.decompress_int(BaseCompression.n_class_instance_bits)
	data_container.global_position = bit_packer.variable_decompress(TYPE_VECTOR2, true)
	return data_container
