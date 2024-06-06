extends Node
# ComponentUpdateTrackerSystem
#
#func _ready() -> void:
#	SystemController.end_of_frame.connect(_on_end_of_frame)
#	PlayerStateSync.server_player_frame_processed.connect(after_server_player_update)
#	RollbackSystem.rollback_started.connect(_on_rollback_started)
#	add_to_group("FrameInit")
#
#func frame_init(frame : int) -> void:
#	var data : ComponentUpdateTrackerData = ComponentUpdateTracker.history.retrieve_data_at_pos(frame)
#	data.frame = frame
#	data.updated_components.clear()
#
## Checks to see if there are any remaining components this frame. If so, the client
## incorrectly predicted the update of a component.
#func after_server_player_update(frame : int) -> void:
#	var data : ComponentUpdateTrackerData = ComponentUpdateTracker.history.retrieve_data_at_pos(frame)
#	if not data == BaseModularHistory.NO_DATA_FOR_FRAME and not data.updated_components.is_empty():
#		MissPredictFrameTracker.add_reset_frame(CommandFrame.get_previous_frame(frame))
#		_delete_components_that_shouldnt_exist(data.updated_components.keys())
#
#func _delete_components_that_shouldnt_exist(updated_components : Array) -> void:
#	for component in updated_components:
#		if is_instance_valid(component) and not component.netcode.is_from_server:
#			component.entity.remove_and_immediately_delete_component(component)
#			Logging.log_line("Removing and immediately deleting component %s" % [component.netcode.class_id])
#
#func _on_end_of_frame(frame : int) -> void:
#	var next_frame = CommandFrame.get_next_frame(frame)
#	var data : ComponentUpdateTrackerData = ComponentUpdateTracker.history.retrieve_data_at_pos(next_frame)
#	data.reset()
#
#func _on_rollback_started(rollback_frame : int) -> void:
#	# Delete all components that were updated after the rollback frame up to the current frame
#	var next_frame = CommandFrame.get_next_frame(rollback_frame)
#	while CommandFrame.command_frame_greater_than_previous(CommandFrame.frame, next_frame):
#		var data : ComponentUpdateTrackerData = ComponentUpdateTracker.history.retrieve_data_at_pos(next_frame)
#		data.reset()
#		next_frame = CommandFrame.get_next_frame(next_frame)
