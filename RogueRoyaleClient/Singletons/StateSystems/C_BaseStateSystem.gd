extends BaseStateSystem
class_name C_BaseStateSystem

# db is double buffer
var registered_entities_db = {}
var queued_entities_db = {}
var queued_for_unregister_db = {}

func _connect_entity_signals(entity):
	super._connect_entity_signals(entity)
	if not entity.is_connected("remove_from_all_systems_without_exit",Callable(self,"_on_unregister_from_all_without_exit")):
		entity.connect("remove_from_all_systems_without_exit",Callable(self,"_on_unregister_from_all_without_exit"))

func disconnect_entity_signals(entity):
	super.disconnect_entity_signals(entity)
	if entity.is_connected("remove_from_all_systems_without_exit",Callable(self,"_on_unregister_from_all_without_exit")):
		entity.disconnect("remove_from_all_systems_without_exit",Callable(self,"_on_unregister_from_all_without_exit"))

func prep_for_rollback(_frame : int) -> void:
#	registered_entities_db = registered_entities.duplicate()
#	queued_entities_db = queued_entities.duplicate()
#	queued_for_unregister_db = queued_for_unregister.duplicate()
	# As of right now, we are rolling back all entites. Once we start rolling back only a select
	# few entities, then we can create these double buffers and remove the entites that are rolled back
	pass

func end_rollback(_frame : int) -> void:
#	for entity in queued_entities:
#		queued_for_unregister_db.erase(entity)
#	registered_entities.merge(registered_entities_db)
#	queued_entities.merge(queued_entities_db)
#	queued_for_unregister.merge(queued_for_unregister_db)
	pass

func _on_unregister_from_all_without_exit(frame, entity) -> void:
	_remove_entity_from_all(frame, entity, false)
