extends RefCounted
class_name NetcodeBase
# Functions that _must_ be defined in the child class of a netcode object

var class_id : String : set = set_class_id
var class_instance_id : int = -1
var state_data # BaseStateData
var state_compresser #BaseStateCompresser

var from_spawner : bool = false
var entity

func set_class_id(new_id : String) -> void:
	class_id = new_id.substr(0, 3)

func init(new_entity, new_class_id : String, new_state_data, new_state_compresser) -> void:
	set_entity(new_entity)
	set_class_id(new_class_id)
	state_data = new_state_data
	state_compresser = new_state_compresser

func set_entity(new_obj):
	entity = new_obj
	entity.connect("tree_exited",Callable(self,"_on_exit_tree"))

func decompress(bit_reader : BitArrayReader):
	return state_compresser.decompress(bit_reader)
