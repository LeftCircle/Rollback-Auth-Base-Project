extends BaseModuleCompresser
class_name HealthCompresser

const N_SEG_BITS = 6

# TO DO -> optimize! The client might not even be using the timers in their health scripit
func compress(bit_packer : OutputMemoryBitStream, netcode) -> void:
	super.compress(bit_packer, netcode)
	var health_data : HealthData = netcode.state_data
	bit_packer.compress_int_into_x_bits(health_data.health_segments, N_SEG_BITS)
	bit_packer.compress_int_into_x_bits(health_data.armor_segments, N_SEG_BITS)
	bit_packer.compress_int_into_x_bits(health_data.shield_segments, N_SEG_BITS)
	bit_packer.variable_compress(health_data.current_health)
	bit_packer.variable_compress(health_data.current_armor)
	bit_packer.variable_compress(health_data.current_shields)
	bit_packer.compress_bool(health_data.regenerating_shield)
	bit_packer.compress_timer_data(health_data.shield_regen_start_timer)
	bit_packer.compress_timer_data(health_data.shield_regen_heal_timer)

#func remote_compress(health_data : HealthData) -> Array:
#	return compress(health_data)

#func decompress(bit_array : BitArrayReader) -> HealthData:
#	server_data.health_segments = BaseCompression.decompress_x_bits_into_int(bit_array, N_SEG_BITS)
#	server_data.armor_segments = BaseCompression.decompress_x_bits_into_int(bit_array, N_SEG_BITS)
#	server_data.shield_segments = BaseCompression.decompress_x_bits_into_int(bit_array, N_SEG_BITS)
#	server_data.current_health = BaseCompression.variable_decompress(bit_array, TYPE_INT)
#	server_data.current_armor = BaseCompression.variable_decompress(bit_array, TYPE_INT)
#	server_data.current_shields = BaseCompression.variable_decompress(bit_array, TYPE_INT)
#	server_data.regenerating_shield = bit_array.get_bool()
#	BaseCompression.decompress_timer_data_into(server_data.shield_regen_start_timer, bit_array)
#	BaseCompression.decompress_timer_data_into(server_data.shield_regen_heal_timer, bit_array)
#	return server_data
