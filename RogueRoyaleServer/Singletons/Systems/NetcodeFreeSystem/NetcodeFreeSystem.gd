extends RefCounted
class_name NetcodeFreeSystem

const BITS_FOR_N_OBJECTS : int = 10
const BYTES_FOR_FRAME : int = 3
const BYTES_FOR_N_BITS = 2

func execute(frame : int) -> void:
	var components_to_free : Dictionary = NetcodeFreeComponent.class_id_to_instances
	var bit_packer : OutputMemoryBitStream = NetcodeFreeComponent.bit_packer
	if not components_to_free.is_empty():
		_send_objects_to_free(frame, components_to_free, bit_packer)
		_reset_for_next_frame(components_to_free, bit_packer)

func _send_objects_to_free(frame : int, components_to_free : Dictionary, bit_packer : OutputMemoryBitStream) -> void:
	for class_id in components_to_free.keys():
		var instances = components_to_free[class_id]
		var n_instances : int = instances.size()
		bit_packer.compress_class_id(ObjectCreationRegistry.class_id_to_int_id[class_id])
		bit_packer.compress_int_into_x_bits(n_instances, BITS_FOR_N_OBJECTS)
		for i in range(n_instances):
			bit_packer.compress_class_instance(instances[i])
	bit_packer.flush_scratch_to_buffer()
	var byte_array = bit_packer.get_byte_array()
	byte_array += BaseCompression.compress_int_to_x_bytes(CommandFrame.frame, BYTES_FOR_FRAME)
	byte_array += BaseCompression.compress_int_to_x_bytes(bit_packer.total_bits, BYTES_FOR_N_BITS)
	# For now just send to all players
	for player_id in Server.connected_players:
		Server.send_objects_to_free(player_id, byte_array)

func _reset_for_next_frame(components_to_free : Dictionary, bit_packer : OutputMemoryBitStream) -> void:
	components_to_free.clear()
	bit_packer.reset()



