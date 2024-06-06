extends BaseModuleCompresser
class_name KnockbackCompresser

func _init_server_data():
	server_data = KnockbackData.new()

func compress(bit_packer : OutputMemoryBitStream, knockback_data : KnockbackData):
	bit_packer.compress_unit_vector(knockback_data.knockback_direction)
	bit_packer.variable_compress(knockback_data.knockback_speed)
	bit_packer.variable_compress(knockback_data.knockback_decay)

#var server_data = KnockbackData.new()
func decompress(bit_packer : OutputMemoryBitStream, netcode : NetcodeForModules):
	super.decompress(bit_packer, netcode)
	server_data.knockback_direction = bit_packer.decompress_unit_vector()
	server_data.knockback_speed = bit_packer.variable_decompress(TYPE_INT)
	server_data.knockback_decay = bit_packer.variable_decompress(TYPE_INT)
	return server_data
