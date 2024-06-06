extends RefCounted
class_name EntityBaseCompresser

const BITS_FOR_N_MODULAR_ABILTIES = 4

# Set in the module when netcode is initialized
var class_id
var server_data

func _init():
	_init_server_data()

func _init_server_data():
	assert(false) #,"Server data must be set")

func compress(bit_packer : OutputMemoryBitStream, module_data):
	assert(false) #,"must be overwritten")

# The class_id and isntance_id have already been pulled by the time we hit here
func decompress(frame : int, bit_packer : OutputMemoryBitStream):
	server_data.frame = frame
	server_data.modular_abilties_this_frame = bit_packer.decompress_int(BITS_FOR_N_MODULAR_ABILTIES)
