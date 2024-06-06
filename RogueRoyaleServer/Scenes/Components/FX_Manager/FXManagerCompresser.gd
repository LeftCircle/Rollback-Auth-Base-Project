extends BaseModuleCompresser
class_name FXManagerCompresser


func compress(bit_packer : OutputMemoryBitStream, module_data : FXManagerData) -> void:
	var n_fx_resources = module_data.fx_resources.size()
	bit_packer.variable_compress(n_fx_resources)
	for fx_res in module_data.fx_resources:
		var class_id = ObjectCreationRegistry.synced_fx_id_to_int_id[fx_res.resource_id]
		bit_packer.compress_class_id(class_id)

func decompress(bit_packer : OutputMemoryBitStream):
	assert(false) #,"must be overwritten")
