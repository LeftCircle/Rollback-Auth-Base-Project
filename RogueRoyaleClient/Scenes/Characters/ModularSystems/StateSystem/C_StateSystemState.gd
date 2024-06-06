extends StateSystemState
class_name C_StateSystemState

func _init_history():
	history = StateSystemHistory.new()

func reset_to_frame(frame : int) -> void:
	#var old_system = SystemController.get_system_for_state(data_container.state)
	super.reset_to_frame(frame)
	var new_system = SystemController.get_system_for_state(data_container.state)
	if is_instance_valid(entity):
		entity.emit_signal("remove_from_all_systems_without_exit", frame, entity)
		new_system.register_immediately(frame, entity)
		_queue_to_data_container_system(frame)
		_queue_unregister_data_container_system(frame)

func _queue_to_data_container_system(frame : int):
	if data_container.queued_state != SystemController.STATES.NULL:
		var queue_system = SystemController.get_system_for_state(data_container.queued_state)
		queue_system.queue_entity(frame, entity)

func _queue_unregister_data_container_system(frame : int):
	if data_container.queued_unregister != SystemController.STATES.NULL:
		var unqueue_system = SystemController.get_system_for_state(data_container.queued_unregister)
		unqueue_system.unregister_entity(frame, entity)

func reset_to(data) -> void:
	assert(false) #,"Does not work with StateSystem")

func set_state(frame : int, state : int) -> void:
	super.set_state(frame, state)
	netcode.on_client_update(frame)
	Logging.log_line("%s | Setting state to %s" % [entity.player_id, state])

func set_queued_state(frame : int, queued_state : int) -> void:
	super.set_queued_state(frame, queued_state)
	Logging.log_line("%s | Queuing state to %s" % [entity.player_id, queued_state])
	netcode.on_client_update(frame)

func set_queued_unregister(frame : int, queued_unregister : int) -> void:
	super.set_queued_unregister(frame, queued_unregister)
	Logging.log_line("%s | Queuing unregister state to %s" % [entity.player_id, queued_unregister])
	netcode.on_client_update(frame)
