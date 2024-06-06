extends BaseModuleCompresser
class_name HealingCompresser

const N_USES_BITS = 3

func _init_server_data():
	server_data = HealingData.new()

func compress(bit_packer : OutputMemoryBitStream, healing_data : HealingData) -> void:
	bit_packer.compress_int_into_x_bits(healing_data.max_uses, N_USES_BITS)
	bit_packer.compress_int_into_x_bits(healing_data.uses_left, N_USES_BITS)
	bit_packer.compress_timer_data(healing_data.heal_timer)

#var server_data = HealingData.new()
func decompress(bit_packer : OutputMemoryBitStream, netcode : NetcodeForModules):
	super.decompress(bit_packer, netcode)
	server_data.max_uses = bit_packer.decompress_int(N_USES_BITS)
	server_data.uses_left = bit_packer.decompress_int(N_USES_BITS)
	bit_packer.decompress_timer_data_into(server_data.heal_timer)
	return server_data
