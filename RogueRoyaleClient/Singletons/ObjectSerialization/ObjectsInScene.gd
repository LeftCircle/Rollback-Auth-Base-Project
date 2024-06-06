extends Node

const OBJECT_NOT_IN_SCENE = null

# {class_id : {class_instance_id : spawned_object}, ... }
var objects_in_scene = {}
#var lag_comp_spawner = LagCompObjectSpawner.new()

@onready var player_character_loader = $PlayerCharacterLoader

func track_object(object) -> void:
	var netcode = object.netcode
	var class_id_int = ObjectCreationRegistry.class_id_to_int_id[netcode.class_id]
	assert(netcode.is_from_server, "Tacked objects should ALWAYS be from the server")
	_track_object(class_id_int, netcode.class_instance_id, object)

func has_object(object) -> bool:
	var netcode = object.netcode
	var class_id_int = ObjectCreationRegistry.class_id_to_int_id[netcode.class_id]
	if class_id_int in objects_in_scene.keys():
		var has_obj = objects_in_scene[class_id_int].has(netcode.class_instance_id)
		if has_obj:
			assert(netcode.is_from_server, "Tacked objects should ALWAYS be from the server")
		return has_obj
	else:
		return false

func has(class_id : int, class_instance_id) -> bool:
	if class_id in objects_in_scene.keys():
		return class_instance_id in objects_in_scene[class_id].keys()
	else:
		return false

func _track_object(class_id_int : int, class_instance : int, object):
	#var class_id_int = ObjectCreationRegistry.class_id_to_int_id[class_id]
	if class_id_int in objects_in_scene.keys():
		if class_instance in objects_in_scene[class_id_int].keys():
			Logging.log_line("This should never happen")
			assert(false) #,"object is already being tracked")
		else:
			objects_in_scene[class_id_int][class_instance] = object
	else:
		objects_in_scene[class_id_int] = {}
		objects_in_scene[class_id_int][class_instance] = object

func stop_tracking_object(object) -> void:
	var netcode = object.netcode
	assert(netcode.is_from_server, "Tacked objects should ALWAYS be from the server")
	stop_tracking(netcode.class_id, netcode.class_instance_id)

func stop_tracking(class_id : String, class_instance_id : int) -> void:
	var class_id_int = ObjectCreationRegistry.class_id_to_int_id[class_id]
	if objects_in_scene.has(class_id_int):
		objects_in_scene[class_id_int].erase(class_instance_id)

func find_and_return_object(class_id_int : int, class_instance : int):
	assert(ObjectCreationRegistry.int_id_to_str_id.has(class_id_int))
	var string_id : String = ObjectCreationRegistry.int_id_to_str_id[class_id_int]
	Logging.log_line("Finding object for class %s id %s" % [string_id, class_instance])
	if class_id_int in objects_in_scene.keys():
		if class_instance in objects_in_scene[class_id_int].keys():
			Logging.log_line("Returning already existing")
			return objects_in_scene[class_id_int][class_instance]
	return OBJECT_NOT_IN_SCENE

func find_and_decompress(frame : int, class_id_int : int, bit_packer : OutputMemoryBitStream):
	var class_instance = bit_packer.decompress_int(BaseCompression.n_class_instance_bits)
	var string_id : String = ObjectCreationRegistry.int_id_to_str_id[class_id_int]
	Logging.log_line("Finding and decompressing object for class %s id %s" % [string_id, class_instance])
	var object
	if class_id_int in objects_in_scene.keys():
		object = _get_object_if_class_id_in_scene(frame, class_id_int, class_instance, bit_packer)
	else:
		var debug_id = ObjectCreationRegistry.int_id_to_str_id[class_id_int]
		Logging.log_line("Creating first instance of class %s. ID = %s Instance = %s" % [debug_id, class_id_int, class_instance])
		object = _create_new_and_decompress(frame, class_id_int, class_instance, bit_packer)
	if not object.is_entity:
		ComponentUpdateTracker.track_server_update(frame, object)

func _get_object_if_class_id_in_scene(frame : int, class_id_int : int, class_instance : int, bit_packer : OutputMemoryBitStream):
	var object
	if class_instance in objects_in_scene[class_id_int].keys():
		object = _on_object_in_scene(frame, class_id_int, class_instance, bit_packer)
	else:
		var debug_id = ObjectCreationRegistry.int_id_to_str_id[class_id_int]
		Logging.log_line("Creating new from already existing class %s. ID = %s Instance = %s" % [debug_id, class_id_int, class_instance])
		object = _create_new_and_decompress(frame, class_id_int, class_instance, bit_packer)
	return object

func _on_object_in_scene(frame : int, class_id_int : int, class_instance : int, bit_packer : OutputMemoryBitStream):
	Logging.log_line("Returning already existing")
	var debug_class_string = ObjectCreationRegistry.int_id_to_str_id[class_id_int]
	var object = objects_in_scene[class_id_int][class_instance]
	object.decompress(frame, bit_packer)
	return object

func _create_new_and_decompress(frame : int, class_id_int : int, class_instance : int, bit_packer : OutputMemoryBitStream) -> Node:
	Logging.log_line("Adding reset frame %s for new component/entity" % [frame])
	MissPredictFrameTracker.add_reset_frame(frame)
	if class_id_int == ObjectCreationRegistry.class_id_to_int_id["CHR"]:
		var spawned_object = $PlayerCharacterLoader.get_character(class_instance)
		_track_object(class_id_int, class_instance, spawned_object)
		spawned_object.decompress(frame, bit_packer)
		ServerComponentContainer.add_entity(frame, spawned_object)
		return spawned_object
	else:
		var loaded_obj = ObjectCreationRegistry.int_id_to_loaded_scene[class_id_int]
		#var path = ObjectCreationRegistry.id_to_path[class_id_int]
		var new_obj = loaded_obj.instantiate()
		new_obj.netcode.class_instance_id = class_instance
		var spawned_object
		if new_obj.is_in_group("Spawner"):
			spawned_object = new_obj.get_object()
			assert(!new_obj.is_in_group("Spawner"), "debug -- does this even happen anymore?")
		else:
			spawned_object = new_obj
		if spawned_object.is_entity:
			_spawn_and_decompress_new_entity(frame, spawned_object, bit_packer)
		else:
			_spawn_and_decompress_new_component(frame, spawned_object, bit_packer)
		return spawned_object

func _spawn_and_decompress_new_component(frame : int, instanced_component, bit_packer : OutputMemoryBitStream) -> void:
	# We want to decompress this to find the owner so that we can spawn the
	# scene on the owner or save for later.
	instanced_component.decompress(frame, bit_packer)
	var owner_entity = find_and_return_object(instanced_component.netcode.owner_class_id, instanced_component.netcode.owner_instance_id)
	ObjectCreationRegistry.add_child(instanced_component)
	ServerComponentContainer.add_component(frame, instanced_component)
	if is_instance_valid(owner_entity):
		pass
		#owner_entity.add_component(frame, instanced_component)
	else:
		ObjectCreationRegistry.connect("entity_created",Callable(instanced_component.netcode,"_on_entity_created"))
	_track_object_by_netcode(instanced_component)

func _spawn_and_decompress_new_entity(frame : int, instanced_entity, bit_packer : OutputMemoryBitStream) -> void:
	#ObjectCreationRegistry.add_child(instanced_entity)
	instanced_entity.decompress(frame, bit_packer)
	_track_object_by_netcode(instanced_entity)
	#ObjectCreationRegistry.emit_signal("entity_created", frame, instanced_entity)
	ServerComponentContainer.add_entity(frame, instanced_entity)

func _track_object_by_netcode(object) -> void:
	var class_id_int = ObjectCreationRegistry.class_id_to_int_id[object.netcode.class_id]
	var class_instance = object.netcode.class_instance_id
	Logging.log_line("Tracking object by netcode %s: class_id_int = %s class_instance = %s" % [object.netcode.class_id, class_id_int, class_instance])
	_track_object(class_id_int, class_instance, object)

func before_gut_test():
	objects_in_scene.clear()
