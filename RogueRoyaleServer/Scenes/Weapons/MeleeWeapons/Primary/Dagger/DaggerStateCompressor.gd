extends BaseCompression
class_name DaggerStateCompresser

var is_executing_bits = 1
var sequence_bits = 4


func compress_state(class_instance_id : int, state : DaggerState) -> Array:
	var class_instance_bits = compress_class_instance(class_instance_id)
	var execuitng_bit = [1] if state.is_executing else [0]
	var sequence_bits = compress_int_into_x_bits(state.attack_sequence, sequence_bits)
	var attack_direction_bits = compress_unit_vector(state.attack_direction)
	var player_speed_bits = variable_compress(state.player_speed)
	var frames_since_attack_bits = variable_compress(state.frames_since_attack)
	var animation_pos_bits = variable_compress(state.animation_position)
	var bit_array = (class_instance_bits + execuitng_bit + sequence_bits + attack_direction_bits +
					player_speed_bits + frames_since_attack_bits + animation_pos_bits)
	return bit_array

# Class instance has already been read
func decompress(dagger_state : DaggerState, bit_array_reader : BitArrayReader) -> void:
	var is_executing_bit = bit_array_reader.get_x_bits(is_executing_bits)
	dagger_state.is_executing = is_executing_bit[0]
	var sequence_bits = bit_array_reader.get_x_bits(sequence_bits)
	dagger_state.attack_sequence = decompress_int_from_bits(sequence_bits)
	dagger_state.attack_direction = decompress_unit_vec_with_bit_reader(bit_array_reader)
	dagger_state.player_speed = variable_decompress(bit_array_reader, TYPE_INT)
	dagger_state.frames_since_attack = variable_decompress(bit_array_reader, TYPE_INT)
	dagger_state.animation_position = variable_decompress(bit_array_reader, TYPE_FLOAT)
