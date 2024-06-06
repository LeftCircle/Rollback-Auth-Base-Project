extends Resource
class_name NetcodeBaseResource

#export var class_id: String : set = set_class_id
#export var state_data: Resource # BaseStateData
#export var state_compresser: Resource #BaseStateCompresser
#
## The data for this entity and all of the components get packed into this bitsream
#var netcode_bit_stream = DynamicOutputBitStream.new()
#var class_instance_id = null
#var entity
#
#func set_class_id(new_id : String) -> void:
#	class_id = new_id.substr(0, 3)
#	#class_id = new_id
#
#func set_entity(new_obj) -> void:
#	entity = new_obj
#
#func init(new_entity, new_class_id : String, new_state_data, new_state_compresser) -> void:
#	entity = new_entity
#	set_class_id(new_class_id)
#	state_data = new_state_data
#	state_compresser = new_state_compresser
#
#func _ready():
#	entity.connect("ready",Callable(self,"_on_ready"))
#
#func compress():
#	_reset()
#	state_compresser.compress(netcode_bit_stream, state_data)
#
#func write_compressed_data_to_stream(bit_stream : OutputMemoryBitStream) -> void:
#	netcode_bit_stream.write_into_other_stream(bit_stream)
#
#func _on_ready():
#	ObjectCreationRegistry.assign_class_instance_id(entity)
#
#func _reset():
#	netcode_bit_stream.reset()
