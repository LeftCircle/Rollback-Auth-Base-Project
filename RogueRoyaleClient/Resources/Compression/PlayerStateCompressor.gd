extends RefCounted
class_name PlayerStateCompresser

const state_bits = 4
const BITS_FOR_N_MODULAR_ABILTIES = 4

var bitfield = {
	"position" : 1 <<0,
	"looking_vector" : 1 << 1,
	"state" : 1 << 2
}
var bitfield_bits = 3

var health_bits = 8
var position_vec_bits = 40
var velocity_vec_bits = 32
var max_stamina_bits = 4
var current_stamina_bits = 4
var ammo_bits = 5

var server_player_state = ServerPlayerState.new()


func compress(bit_packer : OutputMemoryBitStream, class_instance_id : int, player_state) -> void:
	bit_packer.compress_class_instance(class_instance_id)
	# TO DO -> actually implement the bitfield for further compression
	bit_packer.compress_int_into_x_bits(player_state.state, state_bits)
	#bit_packer.compress_unit_vector(player_state.looking_vector)
	#bit_packer.variable_compress(player_state.position, true)

# To do -> We will have to check to see if states have changed, and determine the delta from the
# last acknowledged state from the server. For now, just return all 1's
func _get_bitfield() -> Array:
	var array = []
	for _i in range(bitfield_bits):
		array.append(1)
	return array

func decompress(frame : int, bit_packer : OutputMemoryBitStream):
	#server_player_state.state = bit_packer.decompress_int(state_bits)
	#server_player_state.position = bit_packer.variable_decompress(TYPE_VECTOR2, true)
	server_player_state.frame = frame
	return server_player_state

## class_instance_id has already been read. That's how we got here
#func decompress_into(server_state : ServerPlayerState, bit_array_reader : BitArrayReader) -> void:
#	# Get the bitfield
#	var bitfield_bits_array = bit_array_reader.get_x_bits(bitfield_bits)
#	var bitfield_int = BaseCompression.bit_array_to_int(bitfield_bits_array)
#	if bitfield_int & bitfield["state"] != 0:
#		var state_bit_array = bit_array_reader.get_x_bits(state_bits)
#		server_state.state = BaseCompression.decompress_int_from_bits(state_bit_array)
#	if bitfield_int & bitfield["looking_vector"] != 0:
#		#var looking_vec_bit_array = bit_array_reader.get_x_bits(2 * BaseCompression.unit_vector_float_bits)
#		#server_state.looking_vector = BaseCompression.decompress_unit_vector(looking_vec_bit_array)
#		server_state.looking_vector = BaseCompression.decompress_unit_vec_with_bit_reader(bit_array_reader)
#	if bitfield_int & bitfield["position"] != 0:
#		var position_bit_array = bit_array_reader.get_x_bits(position_vec_bits)
#		server_state.position = BaseCompression.decompress_vector(position_bit_array, true)
#	var modular_ability_bits = bit_array_reader.get_x_bits(BITS_FOR_N_MODULAR_ABILTIES)
#	server_state.modular_abilties_this_frame = BaseCompression.decompress_int_from_bits(modular_ability_bits)
