extends EntityBaseCompresser
class_name PlayerStateCompresser

const state_bits = 4
const BITS_FOR_N_MODULAR_ABILTIES = 4

var bitfield = {
	"position" : 1 <<0,
	"looking_vector" : 1 << 1,
	"state" : 1 << 2
}
#	"health" : 1 << 0,
#	"state" : 1 << 1,
#	"looking_vector" : 1 << 2,
#	"position" : 1 << 3,
#	"velocity" : 1 << 4,
#	"max_stamina" : 1 << 5,
#	"current_stamina" : 1 << 6,
#	"max_ammo" : 1 << 7,
#	"current_ammo" : 1 << 8
#}
var bitfield_bits = 3

var health_bits = 8
var position_vec_bits = 40
var velocity_vec_bits = 32
var max_stamina_bits = 4
var current_stamina_bits = 4
var ammo_bits = 5

func compress(bit_packer : OutputMemoryBitStream, class_instance_id : int, player_state) -> void:
	super.compress(bit_packer, class_instance_id, player_state)
	#bit_packer.compress_int_into_x_bits(player_state.state, state_bits)
	#bit_packer.variable_compress(player_state.position, true)

#func decompress(frame : int, bit_packer : OutputMemoryBitStream):
#	var server_player_state = ServerPlayerStateOnClient.new()
#	var class_instance = bit_packer.decompress_int(BaseCompression.n_class_instance_bits)
#	server_player_state.state = bit_packer.decompress_int(state_bits)
#	#server_player_state.looking_vector = bit_packer.decompress_unit_vector()
#	server_player_state.position = bit_packer.variable_decompress(TYPE_VECTOR2, true)
#	server_player_state.frame = frame
#	server_player_state.modular_abilties_this_frame = bit_packer.decompress_int(BITS_FOR_N_MODULAR_ABILTIES)
#	return server_player_state

#func compress_state(class_instance_id : int, player_state) -> Array:
#	#Logging.log_line("Compressing class instance id " + str(class_instance_id))
#	var class_instance_bits = compress_class_instance(class_instance_id)
#	var bitfield_bits = _get_bitfield()
#	var bitfield_int = bit_array_to_int(bitfield_bits)
#	var bit_array = class_instance_bits + bitfield_bits
#	if bitfield_int & bitfield["state"] != 0:
#		var state_bit_array = compress_int_into_x_bits(player_state.state, state_bits)
#		bit_array += state_bit_array
#	if bitfield_int & bitfield["looking_vector"] != 0:
#		var looking_vec_bit_array = compress_unit_vector(player_state.looking_vector)
#		bit_array += looking_vec_bit_array
#	if bitfield_int & bitfield["position"] != 0:
#		var position_bit_array = compress_vector_into_x_bits(player_state.position, position_vec_bits, true)
#		var decomp_position = BaseCompression.decompress_vector(position_bit_array, true)
#		Logging.log_line("Compressing position from " + str(player_state.position) + " to " + str(decomp_position))
#		bit_array += position_bit_array
#	return bit_array

# To do -> We will have to check to see if states have changed, and determine the delta from the
# last acknowledged state from the server. For now, just return all 1's
func _get_bitfield() -> Array:
	var array = []
	for i in range(bitfield_bits):
		array.append(1)
	return array

#func remote_compress(class_instance_id : int, player_state) -> Array:
#	var class_instance_bits = compress_class_instance(class_instance_id)
#	var state_bit_array = compress_int_into_x_bits(player_state.state, state_bits)
#	var looking_vec_bit_array = BaseCompression.compress_unit_vector(player_state.looking_vector)
#	var position_bits = BaseCompression.variable_compress(player_state.position)
#	return class_instance_bits + state_bit_array + looking_vec_bit_array + position_bits
