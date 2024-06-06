extends ComponentMap
class_name S_ComponentMap

func add_component(frame : int, component) -> void:
	if not component in component_map:
		var updated_component = _add_component_to_entity(frame, component)
		component.netcode.send_to_clients()

func _add_new_component(frame : int, component):
	var new_component = super._add_new_component(frame, component)
	new_component.add_owner(entity)
	return new_component

func remove_component(frame : int, component, free_component = true) -> bool:
	var has_component = super.remove_component(frame, component, free_component)
	if free_component and has_component:
		NetcodeFreeComponent.add_component_to_free(component.netcode.class_id, component.netcode.class_instance_id)
	return has_component

