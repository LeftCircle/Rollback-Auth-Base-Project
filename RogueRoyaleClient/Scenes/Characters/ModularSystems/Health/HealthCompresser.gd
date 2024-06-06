extends BaseModuleCompresser
class_name HealthCompresser

const N_SEG_BITS = 6

func _init_server_data():
	server_data = HealthData.new()

# TO DO -> optimize! The client might not even be using the timers in their health scripit
#func compress(bit_packer : OutputMemoryBitStream, health_data : HealthData) -> void:
#	bit_packer.compress_int_into_x_bits(health_data.health_segments, N_SEG_BITS)
#	bit_packer.compress_int_into_x_bits(health_data.armor_segments, N_SEG_BITS)
#	bit_packer.compress_int_into_x_bits(health_data.shield_segments, N_SEG_BITS)
#	bit_packer.variable_compress(health_data.current_health)
#	bit_packer.variable_compress(health_data.current_armor)
#	bit_packer.variable_compress(health_data.current_shields)
#	bit_packer.compress_bool(health_data.regenerating_shield)
#	bit_packer.compress_timer_data(health_data.shield_regen_start_timer)
#	bit_packer.compress_timer_data(health_data.shield_regen_heal_timer)


func decompress(bit_packer : OutputMemoryBitStream, netcode : NetcodeForModules):
	super.decompress(bit_packer, netcode)
	server_data.health_segments = bit_packer.decompress_int(N_SEG_BITS)
	server_data.armor_segments = bit_packer.decompress_int(N_SEG_BITS)
	server_data.shield_segments = bit_packer.decompress_int(N_SEG_BITS)
	server_data.current_health = bit_packer.variable_decompress(TYPE_INT)
	server_data.current_armor = bit_packer.variable_decompress(TYPE_INT)
	server_data.current_shields = bit_packer.variable_decompress(TYPE_INT)
	server_data.regenerating_shield = bit_packer.decompress_bool()
	bit_packer.decompress_timer_data_into(server_data.shield_regen_start_timer)
	bit_packer.decompress_timer_data_into(server_data.shield_regen_heal_timer)
	return server_data

func remote_decompress(bit_packer : OutputMemoryBitStream, netcode : NetcodeForModules) -> HealthData:
	return decompress(bit_packer, netcode)
