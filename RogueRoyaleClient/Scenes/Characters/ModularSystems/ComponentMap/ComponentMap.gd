extends Node2D
class_name ComponentMap

@export var entity : Node

var component_map = {}
var component_groups = {}
var class_id_to_component = {}

func _ready() -> void:
	if not is_instance_valid(entity):
		entity = get_parent()

func add_component(frame : int, component) -> void:
	if not component in component_map:
		_add_component_to_entity(frame, component)

func _add_component_to_entity(frame : int, component):
	if component.netcode.class_id in class_id_to_component:
		return _update_existing_component(frame, component)
	else:
		return _add_new_component(frame, component)

func _update_existing_component(frame : int, component):
	var existing_component = class_id_to_component[component.netcode.class_id]
	existing_component.data_container.set_data_with_obj(component.data_container)
	component.queue_free()
	print("EXISTING COMPONENT UPDATED %s instance %s" % [component.netcode.class_id, component.netcode.class_instance_id])
	return existing_component

func _add_new_component(frame : int, component):
	assert(not component.netcode.class_id in class_id_to_component, "DEBUG. cannot have the same component ID twice")
	component_map[component] = frame
	class_id_to_component[component.netcode.class_id] = component
	_add_component_groups(component)
	if not is_ancestor_of(component):
		_reparent_component_to_self(component)
	return component

func _add_component_groups(component) -> void:
	var groups = component.get_groups()
	for group in groups:
		if component_groups.has(group):
			component_groups[group].append(component)
		else:
			component_groups[group] = [component]

func _reparent_component_to_self(component) -> void:
	if component.get_parent():
		component.reparent(self)
	else:
		add_child(component)

func remove_and_immediately_delete(component) -> bool:
	if component in component_map:
		_stop_tracking_and_disconnect_component(component)
		DeferredDeleteComponent.queue_free_imediately(component)
		return true
	return false

func remove_component(component) -> bool:
	if component in component_map:
		_stop_tracking_and_disconnect_component(component)
		DeferredDeleteComponent.defer_delete(component)
		return true
	return false

func _stop_tracking_and_disconnect_component(component) -> void:
	#if component in component_map:
	component_map.erase(component)
	_remove_component_groups(component)
	class_id_to_component.erase(component.netcode.class_id)
	component.disconnect_from_entity()

func _remove_component_groups(component) -> void:
	var groups = component.get_groups()
	for group in groups:
		if component_groups.has(group):
			component_groups[group].erase(component)
			if component_groups[group].is_empty():
				component_groups.erase(group)

func has_group(group : String) -> bool:
	return component_groups.has(group)

func get_component_in_group(group : String):
	if has_group(group):
		Logging.log_line("There are %s components in %s" % [component_groups[group].size(), group])
		return component_groups[group][0]
	return NullComponent.new()

func get_primary_weapon():
	return get_component_in_group("PrimaryWeapons")

func get_secondary_weapon():
	return get_component_in_group("SecondaryWeapons")

func reset_components_to_frame(frame : int) -> void:
	var components = component_map.keys()
	for i in range(components.size(), 0, -1):
		var component = components[i - 1]
		if CommandFrame.command_frame_greater_than_previous(component.component_data.creation_frame, frame):
			remove_and_immediately_delete(component)
		else:
			component.reset_to_frame(frame)

func has(component) -> bool:
	return component_map.has(component)
