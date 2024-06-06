extends Node
# DeferredDeleteComponent

var nodes_to_free_immediately : Array[Node] = []
var deferred_delete_components = {}
var server_frames_received = []
var is_in_gut = false
var packets_to_read : Array = []
var id_to_frame : Dictionary = {}


func receive_packet(packet : PackedByteArray) -> void:
	packets_to_read.append(packet)

func queue_free_imediately(component) -> void:
	nodes_to_free_immediately.append(component)
	if not is_in_gut:
		assert(component.netcode.is_from_server == false, "Server components should never be immediately deleted")
	Logging.log_line("Queueing node to be free immediately by ComponentFreeSystem: %s %s" % [component.netcode.class_id, component.to_string()])

func defer_delete(component : Node) -> void:
	assert(!has_deferred_delete(component), "Component %s is already queued for deferred delete" % [component.netcode.class_id])
	_track_components_for_frame(CommandFrame.execution_frame, component)
	_track_id_to_frame(component)

func _track_components_for_frame(frame : int, component : Node) -> void:
	if not deferred_delete_components.has(frame):
		var new_array : Array[Node] = [component]
		deferred_delete_components[frame] = new_array
	else:
		deferred_delete_components[frame].append(component)

func _track_id_to_frame(component : Node) -> void:
	if not id_to_frame.has(component.netcode.class_id):
		id_to_frame[component.netcode.class_id] = {component.netcode.class_instance_id : CommandFrame.execution_frame}
	else:
		id_to_frame[component.netcode.class_id][component.netcode.class_instance_id] = CommandFrame.execution_frame

func object_freed(class_id : int, instance_id : int) -> void:
	var str_id = ObjectCreationRegistry.int_id_to_str_id[class_id]
	_remove_from_deferred_delete(str_id, instance_id)

func _remove_from_id_to_frame(class_id : String, instance_id : int) -> void:
	if id_to_frame.has(class_id):
		id_to_frame[class_id].erase(instance_id)
		if id_to_frame[class_id].is_empty():
			id_to_frame.erase(class_id)

func _remove_from_deferred_delete(class_id : String, instance_id : int) -> void:
	var frame = id_to_frame[class_id][instance_id]
	for node in deferred_delete_components[frame]:
		if node.netcode.class_id == class_id and node.netcode.class_instance_id == instance_id:
			deferred_delete_components[frame].erase(node)
			if deferred_delete_components[frame].is_empty():
				deferred_delete_components.erase(frame)
			break
	_remove_from_id_to_frame(class_id, instance_id)

func on_rollback(frame : int) -> void:
	# add components from this frame and earlier back to their entities. 
	# If the frame is equal to or before the creation frame, delete the component
	for delete_frame in deferred_delete_components.keys():
		if CommandFrame.command_frame_greater_than_previous(delete_frame, frame):
			_delete_nonexistent_nodes_and_reparent_existing(delete_frame, frame)

func _delete_nonexistent_nodes_and_reparent_existing(delete_frame : int, rollback_frame : int) -> void:
	for node in deferred_delete_components[delete_frame]:
		if CommandFrame.command_frame_greater_than_previous(node.component_data.creation_frame, rollback_frame):
			assert(!node.netcode.is_from_server)
			assert(!ObjectsInScene.has_object(node))
			Logging.log_line("Queueing free node %s" % [node.netcode.class_id])
			# This object should not be in the scene
			#ObjectsInScene.stop_tracking_object(node)
			node.queue_free()
		else:
			node.entity.add_component(node.component_data.creation_frame, node)
			Logging.log_line("Not deleting node of class %s because creation frame because it existed before or on rollback" % [node.netcode.class_id])
		_remove_from_id_to_frame(node.netcode.class_id, node.netcode.class_instance_id)
	deferred_delete_components.erase(delete_frame)

func has(component) -> bool:
	var has_immediate_delete = nodes_to_free_immediately.has(component)
	return has_immediate_delete or has_deferred_delete(component)

func has_deferred_delete(component) -> bool:
	if id_to_frame.has(component.netcode.class_id):
		return id_to_frame[component.netcode.class_id].has(component.netcode.class_instance_id)
	else:
		return false

func reset():
	Logging.log_line("Nodes to free has been reset. Nodes in queue_free_immediately not queued free.")
	nodes_to_free_immediately.clear()
	server_frames_received.clear()

func before_gut_test():
	is_in_gut = true
	_free_all_nodes_gut()
	nodes_to_free_immediately.clear()
	deferred_delete_components.clear()
	server_frames_received.clear()
	id_to_frame.clear()

func _free_all_nodes() -> void:
	for node in nodes_to_free_immediately:
		node.queue_free()
	for frame in deferred_delete_components.keys():
		for node in deferred_delete_components[frame]:
			node.queue_free()

func _free_all_nodes_gut() -> void:
	for node in nodes_to_free_immediately:
		if is_instance_valid(node):
			node.queue_free()
	for frame in deferred_delete_components.keys():
		for node in deferred_delete_components[frame]:
			if is_instance_valid(node):
				node.queue_free()
