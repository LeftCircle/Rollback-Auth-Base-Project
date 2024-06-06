extends EntityBaseCompresser
class_name DoorCompresser

#func compress(bit_packer : OutputMemoryBitStream, class_instance_id : int, state_data):
#	super.compress(bit_packer, class_instance_id, state_data)
#	bit_packer.variable_compress(state_data.global_position, true)
#	bit_packer.compress_bool(state_data.is_open)
#	bit_packer.compress_int_array(state_data.connected_doors)

func _init_server_data():
	server_data = DoorData.new()

func decompress(frame : int, bit_packer : OutputMemoryBitStream):
	server_data.global_position = bit_packer.variable_decompress(TYPE_VECTOR2, true)
	server_data.is_open = bit_packer.decompress_bool()
	server_data.connected_doors = bit_packer.decompress_int_array()
	return server_data
