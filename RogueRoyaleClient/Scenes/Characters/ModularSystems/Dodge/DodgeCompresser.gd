extends BaseModuleCompresser
class_name DodgeCompresser

const N_STAMINA_COST_BITS = 3

func _init_server_data():
	server_data = DodgeData.new()

func compress(bit_packer : OutputMemoryBitStream, module_data : DodgeData):
	bit_packer.compress_int_into_x_bits(module_data.stamina_cost, N_STAMINA_COST_BITS)
	bit_packer.compress_bool(module_data.is_executing)
	bit_packer.compress_int_into_x_bits(module_data.animation_frame, BaseCompression.N_BITS_FOR_ANIM_FRAME)

func decompress(bit_packer : OutputMemoryBitStream, netcode : NetcodeForModules):
	super.decompress(bit_packer, netcode)
	server_data.stamina_cost = bit_packer.decompress_int(N_STAMINA_COST_BITS)
	server_data.is_executing = bit_packer.decompress_bool()
	server_data.animation_frame = bit_packer.decompress_int(BaseCompression.N_BITS_FOR_ANIM_FRAME)
	return server_data

#func remote_decompress(bit_reader : BitArrayReader) -> DodgeData:
#	server_data.is_executing = bit_reader.get_bool()
#	server_data.animation_frame = BaseCompression.decompress_int_from_x_bits(bit_reader, BaseCompression.N_BITS_FOR_ANIM_FRAME)
#	return server_data
