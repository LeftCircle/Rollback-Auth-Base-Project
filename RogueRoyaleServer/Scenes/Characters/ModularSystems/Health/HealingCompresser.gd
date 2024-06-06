extends BaseModuleCompresser
class_name HealingCompresser

const N_USES_BITS = 3

func compress(bit_packer : OutputMemoryBitStream, netcode) -> void:
	super.compress(bit_packer, netcode)
	var healing_data : HealingData = netcode.state_data
	bit_packer.compress_int_into_x_bits(healing_data.max_uses, N_USES_BITS)
	bit_packer.compress_int_into_x_bits(healing_data.uses_left, N_USES_BITS)
	bit_packer.compress_timer_data(healing_data.heal_timer)

#var server_data = HealingData.new()
#func decompress(bit_reader : BitArrayReader) -> HealingData:
#	server_data.max_uses = BaseCompression.decompress_int_from_x_bits(bit_reader, N_USES_BITS)
#	server_data.uses_left = BaseCompression.decompress_int_from_x_bits(bit_reader, N_USES_BITS)
#	BaseCompression.decompress_timer_data_into(server_data.heal_timer, bit_reader)
#	return server_data
