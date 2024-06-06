extends Node2D
#class_name ComponentMap
#
#var component_map = {}
#
#func _ready():
#	for component in get_children():
#		if not component.get("netcode") == null:
#				add_component(component)
#
#func add_component(component):
#	if component.get("netcode") != null:
#		component_map[component.netcode.class_id] = component
#
#func decompress_components(frame : int, n_abilities : int, bit_packer : OutputMemoryBitStream) -> void:
#	for _i in range(n_abilities):
#		var int_id = bit_packer.decompress_int(BaseCompression.n_class_id_bits)
#		var class_id = ObjectCreationRegistry.int_id_to_str_id[int_id]
#		receive_data_for(frame, class_id, bit_packer)
#
#func has(component) -> bool:
#	return component_map.has(component.netcode.class_id)
#
#func remove_component(component) -> void:
#	component_map.erase(component.netcode.class_id)
#
#func receive_data_for(frame : int, component_id : String, bit_packer : OutputMemoryBitStream) -> void:
#	component_map[component_id].decompress(frame, bit_packer)
#
#func reset_components_to_frame(frame : int) -> void:
#	for class_id in component_map.keys():
#		component_map[class_id].reset_to_frame(frame)
