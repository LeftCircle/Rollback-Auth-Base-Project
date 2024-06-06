extends StateSystemState
class_name S_StateSystemState

func set_state(frame : int, state : int) -> void:
	super.set_state(frame, state)
	Logging.log_line("%s | Setting state to %s" % [entity.player_id, state])
	netcode.send_to_clients()

func set_queued_state(frame : int, queued_state : int) -> void:
	super.set_queued_state(frame, queued_state)
	Logging.log_line("%s | Queuing state to %s" % [entity.player_id, queued_state])
	netcode.send_to_clients()

func set_queued_unregister(frame : int, queued_unregistered_state : int) -> void:
	super.set_queued_unregister(frame, queued_unregistered_state)
	Logging.log_line("%s | Queuing unregister state to %s" % [entity.player_id, queued_unregistered_state])
	netcode.send_to_clients()
