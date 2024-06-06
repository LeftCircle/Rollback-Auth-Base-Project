extends Resource
class_name ActionFromClientCompression

# Compresses to:
# frame, input_vector, looking_vector, bitfield
func compress_action(bit_packer : OutputMemoryBitStream, action : ActionFromClient):
	#bit_packer.compress_unit_vector(action.get_input_vector())
	bit_packer.compress_quantized_input_vec(action.get_input_vector())
	bit_packer.compress_unit_vector(action.get_looking_vector())
	var actions_flag = action.has_actions()
	bit_packer.compress_bool(actions_flag)
	if actions_flag:
		var action_bitfield = action.get_action_bitmap()
		bit_packer.compress_int_into_x_bits(action_bitfield, action.bitmap_bits)

func decompress_actions_into(action : ActionFromClient, bit_packer : OutputMemoryBitStream) -> void:
	action.reset()
	action.action_data.input_vector = bit_packer.decompress_quantized_input_vec()
	#action.action_data.input_vector = bit_packer.decompress_unit_vector()
	action.action_data.looking_vector = bit_packer.decompress_unit_vector()
	var action_flag = bit_packer.decompress_bool()
	if action_flag:
		var action_bitmap = bit_packer.decompress_int(action.bitmap_bits)
		action.set_actions_from_bitmap_int(action_bitmap)
