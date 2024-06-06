extends BaseModuleCompresser
class_name KnockbackCompresser

func compress(bit_packer : OutputMemoryBitStream, netcode):
	super.compress(bit_packer, netcode)
	var knockback_data : KnockbackData = netcode.state_data
	bit_packer.compress_unit_vector(knockback_data.knockback_direction)
	bit_packer.variable_compress(knockback_data.knockback_speed)
	bit_packer.variable_compress(knockback_data.knockback_decay)

#var server_data = KnockbackData.new()
#func decompress(bit_reader : BitArrayReader) -> KnockbackData:
#    server_data.knockback_direction = BaseCompression.decompress_unit_vec_with_bit_reader(bit_reader)
#    server_data.knockback_speed = BaseCompression.variable_decompress(bit_reader, TYPE_INT)
#    server_data.knockback_decay = BaseCompression.variable_decompress(bit_reader, TYPE_INT)
#    server_data.knockback_frames = BaseCompression.variable_decompress(bit_reader, TYPE_INT)
#    server_data.current_knockback_frames = BaseCompression.variable_decompress(bit_reader, TYPE_INT)
#    return server_data
