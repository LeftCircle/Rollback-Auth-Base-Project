extends RefCounted
class_name PredictedActionVerifier

signal frame_to_reset_to(frame)

const MAX_FRAME_DIFF = 50

var rollback_frame_tracker = RollbackFrameTracker.new()
var player_id

func init(player_template) -> void:
	player_id = player_template.player_id
	connect("frame_to_reset_to",Callable(player_template,"_on_reset_frame_received"))

func correct_predictions_in_physics_process(player_id : int, predicted_actions : Dictionary):
	var has_rollback_missmatch = false
	var has_silent_missmatch = false
	rollback_frame_tracker.reset()
	Logging.log_line("Predicted frames are " + str(predicted_actions.keys()))
	var debug_oldest_frame = CommandFrame.get_previous_frame(CommandFrame.frame, MAX_FRAME_DIFF)
	for frame in predicted_actions.keys():
		if CommandFrame.command_frame_greater_than_previous(WorldState.previous_buffered_frame, frame):
			# We don't care about inputs before the server correction
		#if CommandFrame.frame_difference(CommandFrame.frame, frame) > MAX_FRAME_DIFF:
			predicted_actions.erase(frame)
			Logging.log_line("Predicted inputs are too old to verify " + str(frame) + " vs " + str(debug_oldest_frame))
			continue
		var predicted_inputs = predicted_actions[frame] as InputActions
		var missmatch_type = _verify_prediction(frame, predicted_inputs)
		if missmatch_type != InputProcessing.NOT_YET_RECEIVED:
			predicted_actions.erase(frame)
		#if not missmatch_type == ActionFromClientComparer.MISSMATCH_TYPE.NONE:
		# Before we were setting the oldest correct frame to also be the frame
		# before silent misspredictions, but I think we can safely set it to only
		# be the frame before rollbacks, since inputs are automatically corrected
		# elsewhere
		if missmatch_type == ActionFromClientComparer.MISSMATCH_TYPE.ROLLBACK:
			has_rollback_missmatch = true
			_on_misspredict(frame)
		elif missmatch_type == ActionFromClientComparer.MISSMATCH_TYPE.SILENT:
			has_silent_missmatch = true
	if has_rollback_missmatch:
		_on_rollback_required()
	elif has_silent_missmatch:
		_on_silent_correction()

func _verify_prediction(frame, predicted_action : InputActions):
	var missmatch_type : int = ActionFromClientComparer.MISSMATCH_TYPE.NONE
	if InputProcessing.has_received_current_and_previous_for_frame(player_id, frame):
		var received_current_action = InputProcessing.get_action_or_duplicate_for_frame(frame, player_id)
		var predicted_current_action = predicted_action.current_actions
		missmatch_type = ActionFromClientComparer.compare(received_current_action, predicted_current_action)
		if not missmatch_type == ActionFromClientComparer.MISSMATCH_TYPE.NONE:# and not history_for_frame == null:
			var type = "SILENT" if missmatch_type == ActionFromClientComparer.MISSMATCH_TYPE.SILENT else "ROLLBACK"
			Logging.log_line("Failed prediction for frame " + str(frame) + " Missmatch type " + type + " Against buffered frame " + str(CommandFrame.input_buffer_frame))
			Logging.log_line("Predicted: " + str(predicted_current_action))
			Logging.log_line("Received : " + str(received_current_action))
	else:
		return InputProcessing.NOT_YET_RECEIVED
	return missmatch_type

# If the history is wrong, update the history and mark the last correct frame, and the most
# recent received frame.
func _on_misspredict(frame):
	rollback_frame_tracker.set_oldest_correct_frame(frame)
	rollback_frame_tracker.set_most_recent_frame(frame)

func _on_rollback_required() -> void:
	emit_signal("frame_to_reset_to", rollback_frame_tracker.oldest_correct_frame)
	MissPredictFrameTracker.add_reset_frame(rollback_frame_tracker.oldest_correct_frame)

func _on_silent_correction() -> void:
	print("Maybe we should be updating the looking direction for this input and future ones?")
	pass


