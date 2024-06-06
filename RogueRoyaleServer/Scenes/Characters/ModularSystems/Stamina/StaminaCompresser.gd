extends BaseModuleCompresser
class_name StaminaCompresser

var n_stamina_bits = 4

func compress(bit_packer : OutputMemoryBitStream, netcode) -> void:
	super.compress(bit_packer, netcode)
	var module_data = netcode.state_data
	bit_packer.compress_int_into_x_bits(module_data.stamina, n_stamina_bits)
	bit_packer.compress_int_into_x_bits(module_data.current_stamina, n_stamina_bits)
	bit_packer.compress_timer_data(module_data.stamina_refill_delay_timer)
	bit_packer.compress_timer_data(module_data.stamina_refill_speed_timer)

func decompress(bit_packer : OutputMemoryBitStream) -> StaminaData:
	var server_data = StaminaData.new()
	server_data.stamina = bit_packer.decompress_int(n_stamina_bits)
	server_data.current_stamina = bit_packer.decompress_int(n_stamina_bits)
	bit_packer.decompress_timer_data_into(server_data.stamina_refill_delay_timer)
	bit_packer.decompress_timer_data_into(server_data.stamina_refill_speed_timer)
	return server_data
