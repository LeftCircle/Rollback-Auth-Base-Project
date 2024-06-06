extends RefCounted
class_name EntityBaseCompresser

func compress(bit_packer : OutputMemoryBitStream, class_instance_id : int, state_data):
	bit_packer.compress_class_instance(class_instance_id)

#func test_decompress(bit_packer : OutputMemoryBitStream):
#	assert(false) #,"to be overwritten. BE SURE TO RETURN THE DATA CONTAINER")
