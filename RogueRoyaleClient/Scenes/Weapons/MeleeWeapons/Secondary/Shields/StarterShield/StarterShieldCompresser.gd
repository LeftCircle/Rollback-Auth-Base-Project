extends MeleeWeaponCompresser
class_name StarterShieldCompresser

const N_BITS_FOR_SHIELD_STATE = 2

func _init_server_data():
	server_data = MeleeWeaponData.new()

func compress(bit_packer : OutputMemoryBitStream, weapon_data):
	super.compress(bit_packer, weapon_data)
	bit_packer.compress_int_into_x_bits(weapon_data.state, N_BITS_FOR_SHIELD_STATE)
	bit_packer.compress_bool(weapon_data.just_raised)

func decompress(bit_packer : OutputMemoryBitStream, netcode : NetcodeForModules):
	server_data = super.decompress(bit_packer, netcode)
	server_data.state = bit_packer.decompress_int(N_BITS_FOR_SHIELD_STATE)
	server_data.just_raised = bit_packer.decompress_bool()
	return server_data
