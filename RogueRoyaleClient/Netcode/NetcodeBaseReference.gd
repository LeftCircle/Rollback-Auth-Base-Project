extends RefCounted
class_name NetcodeBaseReference

@export var class_id: String : set = set_class_id
#@export var state_data # BaseStateData
#@export var state_compresser #BaseStateCompresser

var state_data : RefCounted
var state_compresser : RefCounted
var class_instance_id = -1
var entity

func set_class_id(new_id : String) -> void:
	class_id = new_id.substr(0, 3)
	#class_id = new_id

func set_entity(new_obj):
	entity = new_obj
	if not entity.is_connected("tree_exited",Callable(self,"_on_exit_tree")):
		entity.connect("tree_exited",Callable(self,"_on_exit_tree"))

func init(new_entity, new_class_id : String, new_state_data, new_state_compresser) -> void:
	set_entity(new_entity)
	set_class_id(new_class_id)
	state_data = new_state_data
	state_compresser = new_state_compresser

func decompress(frame : int, bit_reader : OutputMemoryBitStream):
	return state_compresser.decompress(frame, bit_reader)
