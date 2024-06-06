extends BaseModuleCompresser
class_name DodgeCompresser

const N_STAMINA_COST_BITS = 3

func compress(bit_packer : OutputMemoryBitStream, netcode):
	super.compress(bit_packer, netcode)
	var module_data = netcode.state_data
	bit_packer.compress_int_into_x_bits(module_data.stamina_cost, N_STAMINA_COST_BITS)
	bit_packer.compress_bool(module_data.is_executing)
	bit_packer.compress_int_into_x_bits(module_data.animation_frame, BaseCompression.N_BITS_FOR_ANIM_FRAME)

#func remote_compress(module_data : DodgeData) -> Array:
#	var is_exec_bits = BaseCompression.compress_bool(module_data.is_executing)
#	var anim_frame_bits = BaseCompression.compress_int_into_x_bits(module_data.animation_frame, BaseCompression.N_BITS_FOR_ANIM_FRAME)
#	return is_exec_bits + anim_frame_bits

#var server_data = DodgeData.new()
#func decompress(bit_reader : BitArrayReader) -> DodgeData:
#	server_data.stamina_cost = BaseCompression.decompress_int_from_x_bits(bit_reader, N_STAMINA_COST_BITS)
#	server_data.is_executing = bit_reader.get_bool()
#	server_data.is_animation_finished = bit_reader.get_bool()
#	return server_data
