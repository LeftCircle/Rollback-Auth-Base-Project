extends Node
# ServerComponentContainer

signal entity_created(entity : Node)

var server_components = {}
var server_entities = {}

func add_component(frame : int, component : Node) -> void:
	if not frame in server_components:
		var new_array : Array[Node] = []
		server_components[frame] = new_array
	component.netcode.is_from_server = true
	component.component_data.creation_frame = frame
	Logging.log_line("Server component %s added on frame %s to ServerComponentContainer" % [component.to_string(), frame])
	server_components[frame].append(component)

func add_entity(frame : int, entity : Node) -> void:
	if not frame in server_entities:
		var new_array : Array[Node] = []
		server_entities[frame] = new_array
	server_entities[frame].append(entity)

func on_rollback_frame(rollback_frame : int) -> void:
	_add_entities_to_scene(rollback_frame)
	_add_components_to_scene(rollback_frame)

func _add_components_to_scene(rollback_frame : int) -> void:
	var component_frames : Array[int] = _get_frames_before(rollback_frame, server_components) 
	for frame in component_frames:
		for component in server_components[frame]:
			_add_component_to_scene(frame, component)
		server_components.erase(frame)

func _add_component_to_scene(rollback_frame : int, component : Node) -> void:
	var owner_entity = _get_owner_entity(component)
	#print("Adding component %s to scene on rollback frame %s" % [component.to_string(), rollback_frame])
	#print("Execution frame is %s" % [CommandFrame.execution_frame])
	Logging.log_line("Component %s added to scene on execution frame %s, rollback_frame %s" % [component.to_string(), CommandFrame.execution_frame, rollback_frame])
	if is_instance_valid(owner_entity):
		owner_entity.add_component(rollback_frame, component)
	else:
		connect("entity_created", component.netcode._on_entity_created)

func _add_entities_to_scene(rollback_frame : int) -> void:
	var entity_frames : Array[int] = _get_frames_before(rollback_frame, server_entities)
	for frame in entity_frames:
		for entity in server_entities[frame]:
			_add_entity_to_scene(entity)
		server_entities.erase(frame)

func _add_entity_to_scene(entity : Node) -> void:
	ObjectCreationRegistry.add_child(entity)
	emit_signal("entity_created", entity)

func _get_owner_entity(component) -> Node:
	var owner_class = component.netcode.owner_class_id
	var owner_instance = component.netcode.owner_instance_id
	var owner_entity = ObjectsInScene.find_and_return_object(owner_class, owner_instance)
	return owner_entity

func _get_frames_before(rollback_frame : int, frame_dict : Dictionary) -> Array[int]:
	var frames : Array[int] = []
	for frame in frame_dict.keys():
		if CommandFrame.frame_greater_than_or_equal_to(rollback_frame, frame):
			frames.append(frame)
	return frames

func frame_has_component(frame : int, component : Node) -> bool:
	if not frame in server_components:
		return false
	else:
		return component in server_components[frame]

func before_gut_test():
	server_components.clear()
	server_entities.clear()
