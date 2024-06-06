extends Node

@export var file_lister: Resource
@export var synced_fx_file_lister: Resource

#var file_lister = FileLister.new()
var id_to_path = {}
var class_id_to_class_counter = {}
var class_id_to_int_id = {}
var class_id_to_compressed_id = {}
var network_id_to_instance_id = {}
var str_id_to_path = {}
var int_id_to_str_id = {}
var int_id_to_loaded_scene = {}


var synced_fx_id_to_res = {}
var synced_fx_int_id_to_res = {}
var synced_fx_id_to_int_id = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	_serialize_entities_and_components()
	_serialize_fx_resources()

func _serialize_entities_and_components():
	file_lister.load_resources()
	var paths = file_lister.get_file_paths()
	for path in paths:
		serialize_class_id(path)

func serialize_class_id(path : String) -> void:
	if path.ends_with(".tmp"):
		return
	var loaded_scene = load(path)
	var scene = loaded_scene.instantiate()
	var netcode_ref = scene.get("netcode")
	if netcode_ref != null:
		var class_id = netcode_ref.class_id
		var num_id = id_to_int(class_id)
		if num_id in id_to_path.keys():
			assert(false) #,"This class_id already exists: " + str(class_id))
		else:
			#print(path, " ", class_id)
			id_to_path[num_id] = path
			str_id_to_path[class_id] = path
			class_id_to_int_id[class_id] = num_id
			var class_counter = NetworkInstanceCounter.new()
			class_counter.class_id = class_id
			class_id_to_class_counter[class_id] = class_counter
			var comp_id = BaseCompression.compress_class_id(num_id)
			class_id_to_compressed_id[class_id] = comp_id
			int_id_to_str_id[num_id] = class_id
			int_id_to_loaded_scene[num_id] = loaded_scene
	scene.queue_free()

func _serialize_fx_resources():
	synced_fx_file_lister.load_resources()
	var paths = synced_fx_file_lister.get_file_paths()
	for path in paths:
		var res = load(path)
		var num_id = id_to_int(res.resource_id)
		if synced_fx_int_id_to_res.has(num_id):
			assert(false, "Resource already named " + res.resource_id + " Paths are "
			+ str(res.resource_path) + " " + str(synced_fx_int_id_to_res[num_id].res.resource_path))
		else:
			print(path, " ", res.resource_id)
			synced_fx_int_id_to_res[num_id] = res
			synced_fx_id_to_res[res.resource_id] = res
			synced_fx_id_to_int_id[res.resource_id] = num_id

func assign_class_instance_id(entity) -> void:
	var class_counter = class_id_to_class_counter[entity.netcode.class_id]
	class_counter.assign_instance_id(entity)

func id_to_int(id : String):
	id = id.to_upper()
	var ascii_A = "A".unicode_at(0)
	var a = id.unicode_at(0) - ascii_A
	var b = id.unicode_at(1) - ascii_A
	var c = id.unicode_at(2) - ascii_A
	var first_cantor = cantor(a, b)
	return cantor(first_cantor, c)

func cantor(a : int, b : int) -> int:
	return (a + b) * (a + b + 1) / 2 + b

# See https://en.wikipedia.org/wiki/Pairing_function#Inverting_the_Cantor_pairing_function
func reverse_cantor(cantor_number : int):
	var w = int((sqrt(8 * cantor_number + 1) - 1) / 2)
	var t = w * (w + 1) / 2
	var y = cantor_number - t
	var x = w - y
	return [x, y]

func instance_from_str_id(class_id : String):
	var path = str_id_to_path[class_id]
	return load(path).instantiate()

func duplicate_object_with_netcode_data(object):
	var new_obj = instance_from_str_id(object.netcode.class_id)
	new_obj.netcode.state_data.set_data_with_obj(object)
	new_obj.netcode.state_data.set_obj_with_data(object)
	return new_obj

#func instance_object(object_cantor_id : int):
#	return load(id_to_path[object_cantor_id]).instantiate()
