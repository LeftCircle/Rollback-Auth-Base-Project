extends Node
# ComponentFreeSystem

const BITS_FOR_N_OBJECTS : int = 10
const BYTES_FOR_FRAME : int = 3
const BYTES_FOR_N_BITS = 2

var bit_packer : OutputMemoryBitStream = OutputMemoryBitStream.new()

func _ready() -> void:
	RollbackSystem.rollback_started.connect(free_nodes_queued_for_immediate_deletion)

func execute():
	free_nodes_queued_for_immediate_deletion(0)
	delete_objects_from_server()
	DeferredDeleteComponent.reset()

# Frame is here for the signal in the _ready function
func free_nodes_queued_for_immediate_deletion(_frame : int):
	for node in DeferredDeleteComponent.nodes_to_free_immediately:
		assert(!node.netcode.is_from_server, "Server nodes should not be queued for immediate deletion")
		# These objects should also not be tracked
		assert(!ObjectsInScene.has_object(node))
		node.queue_free()
		#print("Immediately Queueing free node %s" % [node.netcode.class_id])
	DeferredDeleteComponent.nodes_to_free_immediately.clear()

func delete_objects_from_server() -> void:
	var future_packets : Array = []
	for packet in DeferredDeleteComponent.packets_to_read:
		_read_packet_and_delete_objects(packet, future_packets)
	DeferredDeleteComponent.packets_to_read = future_packets

func _read_packet_and_delete_objects(packet : PackedByteArray, future_packets : Array) -> void:
	var deletion_frame_n = WorldStateDecompression.get_frame(packet)
	if CommandFrame.command_frame_greater_than_previous(deletion_frame_n, CommandFrame.frame):
		future_packets.append(packet)
		print("FUTURE DELETE PACKET!!!")
	else:
		var n_bits : int = WorldStateDecompression.get_n_bits(packet)
		bit_packer.gaffer_start_read(packet, n_bits)
		_process_bit_array()

func _process_bit_array() -> void:
	while !bit_packer.is_finished():
		var class_id_int : int = bit_packer.decompress_class_id()
		var class_id : String = ObjectCreationRegistry.int_id_to_str_id[class_id_int]
		var n_objects : int = bit_packer.decompress_int(BITS_FOR_N_OBJECTS)
		for i in range(n_objects):
			var instance_id : int = bit_packer.gaffer_read(BaseCompression.n_class_instance_bits)
			free_component(class_id_int, instance_id)

func free_component(class_id : int, instance_id : int) -> void:
	DeferredDeleteComponent.object_freed(class_id, instance_id)	
	var object = _stop_tracking_from_objects_in_scene(class_id, instance_id)
	object.queue_free()

func _stop_tracking_from_objects_in_scene(class_id : int, instance_id : int):
	var object = ObjectsInScene.find_and_return_object(class_id, instance_id)
	assert(is_instance_valid(object), "DEBUG | Object should be valid")
	var str_id = ObjectCreationRegistry.int_id_to_str_id[class_id]
	ObjectsInScene.stop_tracking(str_id, instance_id)
	return object

func has_immediate_delete(component) -> bool:
	return DeferredDeleteComponent.nodes_to_free_immediately.has(component)

func has_deferred_delete(component) -> bool:
	return DeferredDeleteComponent.has(component) and not has_immediate_delete(component)
