extends NetcodeBase
class_name NetcodeForModules

var component
var owner_class_id : int
var owner_instance_id : int
var is_from_server : bool = false

func init(new_component, new_class_id, new_state_data, new_state_compresser) -> void:
	set_class_id(new_class_id)
	state_data = new_state_data
	state_compresser = new_state_compresser
	component = new_component
	new_component.connect("tree_exited",Callable(self,"_on_exit_tree"))
	new_component.connect("tree_entered", _on_tree_entered)

#func add_owner(new_entity) -> void:
#	entity = new_entity
#	#owner_class_id = ObjectCreationRegistry.class_id_to_int_id[entity.netcode.class_id]
#	#owner_instance_id = entity.netcode.class_instance_id
#	if new_entity.is_in_group("Players") and not component.is_in_group("Health"):
#		component.is_lag_comp = false
#	else:
#		component.is_lag_comp = true

func set_class_id(new_id : String) -> void:
	class_id = new_id.substr(0, 3)

func set_state_data(with_module) -> void:
	state_data.set_data_with_obj(with_module)

func compress_module() -> Array:
	var compressed_data = state_compresser.compress(state_data)
	return compressed_data

func _on_entity_created(frame : int, entity) -> void:
	var entity_class_id = ObjectCreationRegistry.class_id_to_int_id[entity.netcode.class_id]
	var entity_instance_id = entity.netcode.class_instance_id
	if entity_class_id == owner_class_id and entity_instance_id == owner_instance_id:
		entity.add_component(frame, component)
		ObjectCreationRegistry.disconnect("entity_created",Callable(self,"_on_entity_created"))

func _on_exit_tree():
	#print("Component %s exiting tree on execution frame %s" % [component.to_string(), CommandFrame.execution_frame])
	Logging.log_line("Component %s exiting tree on execution frame %s" % [component.to_string(), CommandFrame.execution_frame])

func _on_tree_entered():
	#print("Component %s entering tree on execution frame %s" % [component.to_string(), CommandFrame.execution_frame])
	Logging.log_line("Component %s entering tree on execution frame %s" % [component.to_string(), CommandFrame.execution_frame])

func on_client_update(frame : int) -> void:
	ComponentUpdateTracker.track_client_update(frame, component)
