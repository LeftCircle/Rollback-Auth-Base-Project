extends MeleeWeaponCompresser
class_name StarterShieldCompresser

const N_BITS_FOR_SHIELD_STATE = 2

func compress(bit_packer : OutputMemoryBitStream, weapon_data):
	super.compress(bit_packer, weapon_data)
	bit_packer.compress_int_into_x_bits(weapon_data.state, N_BITS_FOR_SHIELD_STATE)
	bit_packer.compress_bool(weapon_data.just_raised)
