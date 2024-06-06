extends RefCounted
class_name BaseModuleCompresser

# Set in the module when netcode is initialized
var class_id
var server_data

func _init():
	_init_server_data()

func _init_server_data():
	assert(false) #,"Server data must be set")

func compress(bit_packer : OutputMemoryBitStream, module_data):
	assert(false) #,"must be overwritten")

func decompress(bit_packer : OutputMemoryBitStream, netcode : NetcodeForModules):
	netcode.owner_class_id = bit_packer.decompress_class_id()
	netcode.owner_instance_id = bit_packer.decompress_int(BaseCompression.n_class_instance_bits)
