extends BaseHistory
class_name ServerHistoryCorrector

const DOUBLE_SLOW_IF_AHEAD_BY = 25
var server_histories = []
#var mutex = Mutex.new()
var most_recent_server = -1

func set_game_start_step():
	last_frame_checked_against_server = CommandFrame.game_start_step
	history.frame = CommandFrame.game_start_step - 1

func receive_server_history(server_history : ServerPlayerState) -> void:
	#mutex.lock()
	if CommandFrame.command_frame_greater_than_previous(server_history.frame, most_recent_server):
		server_histories.append(server_history)
	#mutex.unlock()

func get_server_histories():
	#mutex.lock()
	var copy = server_histories.duplicate(true)
	server_histories.clear()
	#mutex.unlock()
	return copy

func correct_against_server_in_physics_process():
	#mutex.lock()
	var missmatch_type = _check_and_correct_history()
	#mutex.unlock()
	if missmatch_type == PlayerStateComparer.MISSMATCH_TYPE.ROLLBACK:
		Logging.log_line("Repredicting player")
		_repredict_player_character()
	elif missmatch_type == PlayerStateComparer.MISSMATCH_TYPE.SILENT:
		Logging.log_line("Silently updating player")
		_update_silent_missmatch()

func _check_and_correct_history() -> int:
	var server_histories = get_server_histories()
	var rollback_detected = false
	var silent_missmatch_detected = false
	for server_state in server_histories:
		if CommandFrame.command_frame_greater_than_previous(server_state.frame, last_frame_checked_against_server):
			var match_type = matches_server(server_state)
			if match_type == PlayerStateComparer.MISSMATCH_TYPE.ROLLBACK:
				rollback_detected = true
				Logging.log_line("Rollback missmatch detected")
				var hist = get_history_for_frame_or_null(server_state.frame)
				if hist != null:
					Logging.log_line("Missmatch for frame " + str(server_state.frame))
					Logging.log_line("Server = ")
					server_state.log_state()
					Logging.log_line("Client = ")
					hist.player_state.log_state()
				correct_history(server_state.frame, server_state)
			elif match_type == PlayerStateComparer.MISSMATCH_TYPE.SILENT:
				silent_missmatch_detected = true
				Logging.log_line("Silent missmatch detected")
				var hist = get_history_for_frame_or_null(server_state.frame)
				if hist != null:
					Logging.log_line("Missmatch for frame " + str(server_state.frame))
					Logging.log_line("Server = ")
					server_state.log_state()
					Logging.log_line("Client = ")
					hist.player_state.log_state()
				correct_history(server_state.frame, server_state)
			# Setting this to be the last correct frame since the history was corrected
			set_most_recent_server(server_state.frame)
	if rollback_detected:
		return PlayerStateComparer.MISSMATCH_TYPE.ROLLBACK
	elif silent_missmatch_detected:
		return PlayerStateComparer.MISSMATCH_TYPE.SILENT
	return PlayerStateComparer.MISSMATCH_TYPE.NONE

func _repredict_player_character():
	_reset_player_state()
	_repredict_after_correct_state()

func _reset_player_state():
	var correct_hist = get_history_for_frame_or_null(last_frame_checked_against_server)
	if correct_hist != null:
		player_node.reset_state(last_frame_checked_against_server, correct_hist.player_state)
		Logging.log_line("Resetting state to history for frame " + str(correct_hist.frame))
		correct_hist.log_history()
	else:
		Logging.log_line("No history when resetting player state for frame " + str(most_recent_server))

func _update_silent_missmatch():
	var correct_hist = get_history_for_frame_or_null(last_frame_checked_against_server)
	if correct_hist != null:
		player_node.silent_reset_state(last_frame_checked_against_server, correct_hist.player_state)

func _repredict_after_correct_state():
	var to_redo = get_histories_to_redo(last_frame_checked_against_server)
	var frames = []
	for hist in to_redo:
		frames.append(hist.frame)
	Logging.log_line("Histories to redo = " + str(frames))
	for hist in to_redo:
		#Logging.log_line("Redoing frame for SERVER " + str(hist.frame) + " " + str(hist.input_actions.current_actions))
		player_node.redo_actions(hist.frame, hist.input_actions)
		correct_history(hist.frame, player_node.state_data)

# Checks to see if the saved state matches the server state, and returns if the missmatch is silent or rollback
func matches_server(server_player_state : ServerPlayerState) -> int:
	var frame = server_player_state.frame
	if CommandFrame.command_frame_greater_than_previous(last_frame_checked_against_server, frame):
		# If the frame comes before a correct frame, it is also correct
		return PlayerStateComparer.MISSMATCH_TYPE.NONE
	else:
		Logging.log_line("Setting last frame checked to " + str(frame) + " on frame " + str(CommandFrame.frame))
		last_frame_checked_against_server = frame
		#_check_for_double_slow(last_frame_checked_against_server)
	var player_history = get_history_for_frame_or_null(frame)
	if player_history == null:
		print("No histories to check against server. SHOULD ONLY HAPPEN AT START")
		return PlayerStateComparer.MISSMATCH_TYPE.ROLLBACK
	else:
		var match_type = PlayerStateComparer.compare_states(player_history.player_state, server_player_state, is_template)
		return match_type

func _check_for_double_slow(last_frame_checked):
	var frame_diff = CommandFrame.frame_difference(CommandFrame.frame, last_frame_checked)
	if frame_diff >= DOUBLE_SLOW_IF_AHEAD_BY:
		CommandFrame.change_iteration_speed(CommandFrame.DOUBLE_SLOW)

func set_most_recent_server(frame) -> void:
	if most_recent_server == -1:
		most_recent_server = frame
	else:
		if CommandFrame.command_frame_greater_than_previous(frame, most_recent_server):
			most_recent_server = frame
	#Logging.log_rollback("most recent server = " + str(most_recent_server) + " received " + str(frame))

