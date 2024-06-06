extends RefCounted
class_name NetcodeBase
# For the object creation registry to function, the NetcodeBase must be added
# in the ready funciton of whatever class it is connected to

var class_id : String : set = set_class_id
var class_instance_id : int
var state_data # BaseStateData
var state_compresser #BaseStateCompresser

# The data for this entity and all of the components get packed into this bitsream
var netcode_bit_stream = DynamicOutputBitStream.new()

func set_class_id(new_id : String) -> void:
	class_id = new_id.substr(0, 3)

func compress():
	assert(false) #,"To be overwritten")

func write_compressed_data_to_stream(bit_stream : OutputMemoryBitStream) -> void:
	netcode_bit_stream.write_into_other_stream(bit_stream)

func _reset():
	netcode_bit_stream.reset()

func _on_entity_physics_process_started():
	pass # To be overwritten
