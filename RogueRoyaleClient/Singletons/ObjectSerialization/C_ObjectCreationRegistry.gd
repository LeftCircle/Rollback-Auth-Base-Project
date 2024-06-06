extends Node

signal entity_created(frame, entity)

@export var file_lister: Resource
@export var synced_fx_file_lister: Resource

const netcode_variable = "netcode"

var id_to_path = {}
var class_id_to_int_id = {}
var int_id_to_str_id = {}
var client_character_class_instance_id : int = -1
var network_id_to_instance_id = {}
var int_id_to_loaded_scene = {}

var synced_fx_int_id_to_res = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	_serialize_entities_and_components()
	_serialize_fx_resources()

func _serialize_entities_and_components():
	file_lister.load_resources()
	var paths = file_lister.get_file_paths()
	for path in paths:
		if path.ends_with(".tmp"):
			return
		var loaded_scene = load(path)
		var scene = loaded_scene.instantiate()
		var netcode_ref = scene.get(netcode_variable)
		if netcode_ref != null and netcode_ref.get("from_spawner") != true:
			var class_id = netcode_ref.class_id
			assert(class_id != "")
			var num_id = id_to_int(class_id)
			if num_id in id_to_path.keys():
				assert(false, "This class_id already exists: " + str(class_id))
			else:
				#print(path, " class id = ", class_id)
				id_to_path[num_id] = path
				var class_counter = NetworkInstanceCounter.new()
				class_counter.class_id = class_id
				class_id_to_int_id[class_id] = num_id
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
			res.res = load(res.res_path)
			print(path, " class id = ", res.resource_id, " res = ", res.res)
			synced_fx_int_id_to_res[num_id] = res

func get_this_client():
	return ObjectsInScene.find_and_return_object(class_id_to_int_id["CHR"], client_character_class_instance_id)

func receive_client_serialization(network_id_and_instance : Array) -> void:
	var network_id = network_id_and_instance[0]
	var instance_id = network_id_and_instance[1]
	print("receiving client serialization for network id %s and instance id %s" %[network_id, instance_id])
	var local_unique_id = Server.server_api.get_unique_id()
	if network_id == local_unique_id:
		print("Local character instance_id recevied and is ", instance_id)
		client_character_class_instance_id = instance_id
	network_id_to_instance_id[network_id] = instance_id
	#var player_obj = find_and_queue_spawn_if_needed(CommandFrame.frame, class_id_to_int_id["CHR"], instance_id)
	#player_obj.player_id = network_id

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

func before_gut_test():
	ObjectsInScene.before_gut_test()

#func instance_object(object_cantor_id : int):
#	return load(id_to_path[object_cantor_id]).instantiate()
