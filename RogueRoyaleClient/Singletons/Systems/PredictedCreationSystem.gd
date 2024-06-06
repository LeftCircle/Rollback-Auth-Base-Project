extends Node
# Predicted Component System

# A rollback will be forced on component creation, since we roll back whenever an entity or
# component is created by the server. 

## {frame : [predicted components]}
var predicted_components = {}

func _ready() -> void:
	PlayerStateSync.server_player_frame_processed.connect(_on_server_update)
	RollbackSystem.rollback_started.connect(_on_rollback_started)

func _on_server_update(server_frame : int) -> void:
	var predicted_frames : Array[int] = _get_predicted_frames_earlier_or_equal_to(server_frame)
	if not predicted_frames.is_empty():
		MissPredictFrameTracker.add_reset_frame(server_frame)
		var predicted_components_array : Array[String] = debug_get_predicted_classes(predicted_frames)
		Logging.log_line("Adding reset frame for %s because of the following predicted components: %s" % [server_frame, predicted_components_array])
		_delete_predicted_components(predicted_frames)

func debug_get_predicted_classes(predicted_frames : Array[int]) -> Array[String]:
	var predicted_classes : Array[String] = []
	for predicted_frame in predicted_frames:
		var components : Array = predicted_components[predicted_frame]
		for component in components:
			if is_instance_valid(component):
				predicted_classes.append(component.netcode.class_id)
	return predicted_classes

func _delete_predicted_components(predicted_frames : Array[int]) -> void:
	for predicted_frame in predicted_frames:
		var frame_predicted_components : Array = predicted_components[predicted_frame]
		_remove_and_immediately_delete_components(frame_predicted_components)
		predicted_components.erase(predicted_frame)

func _get_predicted_frames_earlier_or_equal_to(server_frame : int) -> Array[int]:
	var predicted_frames = predicted_components.keys()
	var predicted_frames_earlier_than_server_frame : Array[int] = []
	for predicted_frame in predicted_frames:
		if CommandFrame.frame_greater_than_or_equal_to(server_frame, predicted_frame):
			predicted_frames_earlier_than_server_frame.append(predicted_frame)
	return predicted_frames_earlier_than_server_frame

func _get_predicted_frames_after(frame : int) -> Array[int]:
	var predicted_frames = predicted_components.keys()
	var predicted_frames_after : Array[int] = []
	for predicted_frame in predicted_frames:
		if CommandFrame.command_frame_greater_than_previous(predicted_frame, frame):
			predicted_frames_after.append(predicted_frame)
	return predicted_frames_after

func _remove_and_immediately_delete_components(components : Array) -> void:
	for component in components:
		component.entity.remove_and_immediately_delete_component(component)

func add_predicted_component(frame, component):
	if frame not in predicted_components:
		predicted_components[frame] = []
	predicted_components[frame].append(component)

func get_predicted_components_for_frame(frame : int) -> Array:
	if frame in predicted_components:
		return predicted_components[frame]
	else:
		return []

func has_component(frame : int, component) -> bool:
	var frame_components = get_predicted_components_for_frame(frame)
	return component in frame_components

func before_gut() -> void:
	predicted_components.clear()

func _on_rollback_started(rollback_frame : int) -> void:
	var predicted_frames : Array[int] = _get_predicted_frames_after(rollback_frame)
	if not predicted_frames.is_empty():
		for frame in predicted_frames:
			predicted_components.erase(frame)
