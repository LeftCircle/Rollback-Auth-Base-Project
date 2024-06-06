extends BaseModuleCompresser
class_name MeleeWeaponCompresser

const N_BITS_FOR_ANIM_FRAME = 8

var n_sequence_bits = 4


func compress(bit_packer : OutputMemoryBitStream, netcode):
	super.compress(bit_packer, netcode)
	var weapon_data = netcode.state_data
	bit_packer.compress_int_into_x_bits(weapon_data.attack_sequence, n_sequence_bits)
	bit_packer.compress_bool(weapon_data.is_executing)
	bit_packer.compress_unit_vector(weapon_data.attack_direction)
	bit_packer.compress_int_into_x_bits(weapon_data.animation_frame, N_BITS_FOR_ANIM_FRAME)
	bit_packer.compress_bool(weapon_data.is_in_parry)
	bit_packer.compress_bool(weapon_data.stamina_check_occured)
	bit_packer.compress_bool(weapon_data.combo_to_occur)

#func remote_compress(weapon_data) -> Array:
#	var execuitng_bit = [1] if weapon_data.is_executing else [0]
#	var anim_frame_bits = BaseCompression.compress_int_into_x_bits(weapon_data.animation_frame, N_BITS_FOR_ANIM_FRAME)
#	var sequence_bits = BaseCompression.compress_int_into_x_bits(weapon_data.attack_sequence, n_sequence_bits)
#	var attack_direction_bits = BaseCompression.compress_unit_vector(weapon_data.attack_direction)
#	return execuitng_bit + anim_frame_bits + sequence_bits + attack_direction_bits


#func decompress(bit_packer : OutputMemoryBitStream):
#	server_data.attack_sequence = bit_packer.decompress_int(n_sequence_bits)
#	server_data.is_executing = bit_packer.decompress_bool()
#	server_data.attack_direction = bit_packer.decompress_unit_vector()
#	server_data.animation_frame = bit_packer.decompress_int(N_BITS_FOR_ANIM_FRAME)
#	server_data.is_in_parry = bit_packer.decompress_bool()
#	server_data.stamina_check_occured = bit_packer.decompress_bool()
#	return server_data
