extends EntityBaseCompresser
class_name RoomOutlineCompresser

func _init_server_data():
	server_data = RoomOutlineData.new()

func decompress(frame : int, _bit_packer : OutputMemoryBitStream):
	server_data.global_position = _bit_packer.variable_decompress(TYPE_VECTOR2, true)
	return server_data
