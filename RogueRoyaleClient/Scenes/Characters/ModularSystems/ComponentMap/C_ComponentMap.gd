extends ComponentMap
class_name C_ComponentMap

func _ready():
	super._ready()
	for component in get_children():
		add_component(CommandFrame.execution_frame, component)

func add_component(frame : int, component) -> void:
	if not component in component_map:
		var updated_component = _add_component_to_entity(frame, component)
		_track_component_update_or_creation(frame, updated_component)

func _add_new_component(frame, component):
	var new_component = super._add_new_component(frame, component)
	new_component.connect_to_entity(entity)
	return new_component

func _track_component_update_or_creation(frame : int, component) -> void:
	if not component.netcode.is_from_server:
		PredictedCreationSystem.add_predicted_component(frame, component)
	else:
		component.netcode.on_client_update(frame)

func has_component(component) -> bool:
	return component in component_map

func get_components() -> Array:
	return component_map.keys()
