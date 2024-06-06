extends RefCounted
class_name BaseModuleCompresser

func compress(bit_packer : OutputMemoryBitStream, netcode) -> void:
	bit_packer.compress_class_instance(netcode.class_instance_id)
	# TO DO -> This info only needs to be passed on object creation
	bit_packer.compress_class_id(netcode.owner_class_id)
	bit_packer.compress_class_instance(netcode.owner_instance_id)

func decompress(bit_packer : OutputMemoryBitStream):
	assert(false) #,"must be overwritten")
