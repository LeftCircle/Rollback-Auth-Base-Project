#################################################
######   SHARED BETWEEN CLIENT AND SERVER   #####
#################################################
extends Node
class_name BaseStateSystem

var state_system_int = SystemController.STATES.NULL

var registered_entities = {}
var queued_entities = {}
var queued_for_unregister = {}
var required_component_groups : Array[StringName] = []

func _init():
	_init_required_component_groups()
	_init_state_system_int()

func _ready():
	SystemController.register_state_system(self)

func _init_required_component_groups():
	assert(false) #,"must be overwritten")

func _init_state_system_int() -> void:
	assert(false, "must be overwritten")

func execute(frame : int) -> void:
	_unregister_queued_entities(frame)
	move_queued_entities_to_registered(frame)

func queue_entity(frame : int, entity) -> void:
	queued_entities[entity] = frame
	_connect_entity_signals(entity)
	#_set_queued_state(frame, entity)

func register_immediately(frame : int, entity) -> void:
	if _does_entity_have_required_components(entity):
		registered_entities[entity] = frame
		_set_entity_state(frame, entity)
		queued_entities.erase(entity)
		_connect_entity_signals(entity)

func _does_entity_have_required_components(entity) -> bool:
	for group in required_component_groups:
		if not entity.has_component_group(group):
			return false
	return true

func _connect_entity_signals(entity):
	if not entity.is_connected("queued_for_free",Callable(self,"_on_entity_queued_free")):
		entity.connect("queued_for_free",Callable(self,"_on_entity_queued_free"))
	if not entity.is_connected("components_removed",Callable(self,"_on_entity_components_removed")):
		entity.connect("components_removed",Callable(self,"_on_entity_components_removed"))

func disconnect_entity_signals(entity):
	#if is_instance_valid(entity):
	if entity.is_connected("queued_for_free",Callable(self,"_on_entity_queued_free")):
		entity.disconnect("queued_for_free",Callable(self,"_on_entity_queued_free"))
	if entity.is_connected("components_removed",Callable(self,"_on_entity_components_removed")):
		entity.disconnect("components_removed",Callable(self,"_on_entity_components_removed"))

func move_queued_entities_to_registered(frame : int) -> void:
	var queued_entites_array = queued_entities.keys()
	for entity in queued_entites_array:
		if queued_entities[entity] != frame:
			queued_for_unregister.erase(entity)
			_register_entity_if_it_has_required_components(frame, entity)

func _register_entity_if_it_has_required_components(frame : int, entity) -> void:
	if _does_entity_have_required_components(entity):
		_on_entity_registered(frame, entity)
	else:
		queued_entities.erase(entity)
		#assert(false, "Need a failsafe for if we cannot add an entity to a system")

func _on_entity_registered(frame : int, entity) -> void:
	registered_entities[entity] = frame
	_set_entity_state(frame, entity)
	queued_entities.erase(entity)
	_set_queued_state(frame, entity, SystemController.STATES.NULL)
	if not are_entity_signals_connected(entity):
		_connect_entity_signals(entity)

func _set_entity_state(frame : int, entity) -> void:
	var entity_state_component : StateSystemState = entity.get_component("StateSystem")
	entity_state_component.set_state(frame, state_system_int)

func _set_queued_state(frame : int, entity, state : int = state_system_int) -> void:
	if entity.has_component_group("StateSystem"):
		var entity_state_component : StateSystemState = entity.get_component("StateSystem")
		entity_state_component.set_queued_state(frame, state)

func _set_queue_unregister_state(frame : int, entity, set_to_null = false) -> void:
	var entity_state_component : StateSystemState = entity.get_component("StateSystem")
	var state = SystemController.STATES.NULL if set_to_null else entity_state_component.data_container.state
	entity_state_component.set_queued_unregister(frame, state)

func unregister_entity(frame : int, entity) -> void:
	queued_for_unregister[entity] = frame
	_set_queue_unregister_state(frame, entity)

func unregister_immediately(frame : int, entity) -> void:
	_unregister_from_all_but_queue(frame, entity)

func _unregister_queued_entities(frame : int) -> void:
	var queued_for_unreg_array = queued_for_unregister.keys()
	for entity in queued_for_unreg_array:
		_unregister_from_all_but_queue(frame, entity)
		_set_queue_unregister_state(frame, entity, true)

func _unregister_from_all_but_queue(frame : int, entity, with_exit_conditions = true) -> void:
	registered_entities.erase(entity)
	queued_for_unregister.erase(entity)
	if is_instance_valid(entity):
		if not entity in queued_entities:
			disconnect_entity_signals(entity)
		if with_exit_conditions:
			on_exit_state(frame, entity)

func _remove_entity_from_all(frame : int, entity, with_exit_conditions = true) -> void:
	_unregister_from_all_but_queue(frame, entity, with_exit_conditions)
	queued_entities.erase(entity)

func is_entity_registered(entity) -> bool:
	return entity in registered_entities

func has_registered_entities() -> bool:
	return !registered_entities.is_empty()

func has_queued_entities() -> bool:
	return !queued_entities.is_empty()

func is_entity_queued(entity) -> bool:
	return entity in queued_entities

func is_entity_queued_to_unregister(entity) -> bool:
	return entity in queued_for_unregister

func is_entity_queued_or_registered(entity) -> bool:
	return entity in queued_entities or entity in registered_entities

func _on_entity_queued_free(entity):
	queued_entities.erase(entity)
	registered_entities.erase(entity)
	queued_for_unregister.erase(entity)

func switch_state_system(frame : int, entity, new_state_system) -> void:
	unregister_entity(frame, entity)
	_set_queued_state(frame, entity, new_state_system.state_system_int)
	new_state_system.queue_entity(frame, entity)

func switch_without_unregister(frame : int, entity, new_state_system) -> void:
	_set_queued_state(frame, entity, new_state_system.state_system_int)
	new_state_system.queue_entity(frame, entity)

func on_exit_state(frame : int, entity) -> void:
	pass

func get_system_id() -> int:
	return state_system_int

# TO DO -> this could cause errors if an entity is removed during execution
# It might be best to defer component removal until the end of the frame
func _on_entity_components_removed(entity):
	if not _does_entity_have_required_components(entity):
		queued_entities.erase(entity)
		registered_entities.erase(entity)

func are_entity_signals_connected(entity) -> bool:
	return entity.is_connected("queued_for_free",Callable(self,"_on_entity_queued_free"))

func before_gut_test():
	registered_entities.clear()
	queued_entities.clear()
	queued_for_unregister.clear()
