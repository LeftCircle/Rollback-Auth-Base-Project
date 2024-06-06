extends RefCounted
class_name FXManagerCompresser

func compress(bit_packer : OutputMemoryBitStream, module_data : FXManagerData) -> void:
	var n_fx_resources = module_data.fx_resources.size()
	bit_packer.variable_compress(n_fx_resources)
	for fx_res in module_data.fx_resources:
		bit_packer.compress_class_str_id(fx_res.resource_id)

func decompress(bit_packer : OutputMemoryBitStream):
	var n_fx = bit_packer.variable_decompress(TYPE_INT)
	for i in range(n_fx):
		var fx_id = bit_packer.decompress_class_id()
		var fx = ObjectCreationRegistry.synced_fx_int_id_to_res[fx_id]
		if fx.type == BaseSyncedResource.RES_TYPE.SFX:
			AudioQueue.queue_audio(fx.res)
		else:
			assert(false) #,"only sfx is supported at the moment")
