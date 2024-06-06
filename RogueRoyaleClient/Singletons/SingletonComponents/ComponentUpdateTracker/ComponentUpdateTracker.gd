extends Node


var history = ComponentUpdateTrackerHistory.new()

func _ready() -> void:
	PlayerStateSync.server_player_frame_processed.connect(after_server_player_update)
	RollbackSystem.rollback_started.connect(_on_rollback_started)
	add_to_group("FrameInit")

func frame_init(frame : int) -> void:
	var data : ComponentUpdateTrackerData = history.retrieve_data_at_pos(frame)
	data.frame_init(frame)

# Checks to see if there are any remaining components this frame. If so, the client
# incorrectly predicted the update of a component.
func after_server_player_update(frame : int) -> void:
	var data : ComponentUpdateTrackerData = history.retrieve_data_at_pos(frame)
	if is_client_server_missmatch(data):
		Logging.log_line("Client/server update missmatch. Adding reset frame of %s. " % frame)
		if not data.updated_components.is_empty():
			var components = []
			for component in data.updated_components.keys():
				if is_instance_valid(component):
					components.append(component.netcode.class_id)
			Logging.log_line("Updated incorrectly components = %s" % [components])
		MissPredictFrameTracker.add_reset_frame(frame)
		#_delete_components_that_shouldnt_exist(data.updated_components.keys())

func is_client_server_missmatch(data : ComponentUpdateTrackerData) -> bool:
	return not data == BaseModularHistory.NO_DATA_FOR_FRAME and not data.updated_components.is_empty()

#func _delete_components_that_shouldnt_exist(updated_components : Array) -> void:
#	for component in updated_components:
#		if is_instance_valid(component) and not component.netcode.is_from_server:
#			component.entity.remove_and_immediately_delete_component(component)
#			Logging.log_line("Removing and immediately deleting component %s" % [component.netcode.class_id])

func _on_rollback_started(rollback_frame : int) -> void:
	# Delete all components that were updated after the rollback frame up to the current frame
	var next_frame = CommandFrame.get_next_frame(rollback_frame)
	while CommandFrame.command_frame_greater_than_previous(CommandFrame.frame, next_frame):
		frame_init(next_frame)
		next_frame = CommandFrame.get_next_frame(next_frame)

func track_client_update(frame : int, component) -> void:
	if component.netcode.is_from_server:
		history.add_data(frame, component)

func track_server_update(frame : int, component) -> void:
	var data = history.retrieve_data_at_pos(frame)
	data.updated_components.erase(component)

func is_component_updated(frame : int, component) -> bool:
	var data = history.retrieve_data_at_pos(frame)
	return data.updated_components.has(component)

func get_history() -> ComponentUpdateTrackerHistory:
	return history

func has_client_update(frame : int, component) -> bool:
	var data = history.retrieve_data_at_pos(frame)
	return data.updated_components.has(component)
