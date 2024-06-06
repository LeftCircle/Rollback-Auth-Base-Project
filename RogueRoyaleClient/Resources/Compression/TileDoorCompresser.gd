extends DoorCompresser
class_name TileDoorCompresser

const BITS_FOR_N_TILES = 4

func _init_server_data():
	server_data = TileDoorData.new()

func decompress(frame : int, bit_packer : OutputMemoryBitStream):
	server_data = super.decompress(frame, bit_packer)
	server_data.n_tiles = bit_packer.decompress_int(BITS_FOR_N_TILES)
	server_data.is_horizontal = bit_packer.decompress_bool()
	return server_data
