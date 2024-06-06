extends Resource
class_name BaseHistory

const MAX_FRAME_DIFF = 50

var history_size = 180
var history = PlayerHistoryData.new()
var history_array = []
var last_frame_checked_against_server : int = -1
#var server_state_to_correct_to = PlayerState.new()
var server_histories_to_redo = []
var server_frame_to_correct_from : int = 0
var player_node : BaseCharacter
var is_template = false

func _init():
	for i in range(history_size):
		history_array.append(PlayerHistoryData.new())

func set_player_node(from_character : BaseCharacter, is_node_template : bool = false) -> void:
	player_node = from_character
	is_template = is_node_template

func save_state(frame : int, with_state : PlayerState) -> void:
	var hist = history_array[frame % history_size] as PlayerHistoryData
	hist.set_state(frame, with_state)

func save_inputs(frame : int, input_actions : InputActions) -> void:
	var hist = history_array[frame % history_size] as PlayerHistoryData
	hist.add_inputs(frame, input_actions)

func server_matches_history(server_state : ServerPlayerState) -> bool:
	var hist = history_array[server_state.frame % history_size] as PlayerHistoryData
	var old_state = hist.player_state
	#var matches = ModularDataComparer.data_matches(server_state, old_state)
	var matches = server_state.matches(old_state)
	if not matches:
		#DataSetter.set_data_with_obj(hist, server_state)
		server_state.set_obj_with_data(hist)
	return matches

#func add_history(frame : int, player_state : PlayerState, input_actions : InputActions) -> void:
#	var frame_diff = frame - history.frame
#	if frame_diff != 1:
#		print("Frame difference for player inputs = ", frame_diff, " THIS SHOULD ONLY HAPPEN ON START")
#	history.update(frame, player_state, input_actions)
#	history_array[frame % history_size].duplicate(history)

func get_history_for_frame_or_null(frame : int):
	if history_array[frame % history_size].frame != frame:
		Logging.log_line("Player history for frame " + str(frame) + " does not exist")
		Logging.log_line("The frame at the requested index is " + str(history_array[frame % history_size].frame))
		return null
	return history_array[frame % history_size]

func get_histories_to_redo(old_frame : int, frame_to_redo_to : int = history.frame) -> Array:
	var first_input_frame = old_frame + 1
	var last_frame = frame_to_redo_to
	if last_frame - old_frame > history_size:
		return []
	var histories = []
	# TO DO -> this will break on frame number loop
	for frame_n in range(first_input_frame, last_frame + 1):
		var history = history_array[frame_n % history_size]
		histories.append(history)
	return histories

func correct_history(frame : int, new_state : PlayerState) -> void:
	var player_history = get_history_for_frame_or_null(frame)
	if player_history == null:
		Logging.log_line("Unable to correct history for frame " + str(frame))
	else:
		player_history.player_state.duplicate(new_state)

func log_history_frames():
	var frames = []
	for hist in history_array:
		frames.append(hist.frame)
	Logging.log_line(str(frames))

func log_history_actions():
	pass
#	for hist in history_array:
#		Logging.log_line(str(hist.frame) + " " + hist.actions.to_string() + " " + str(hist.actions))
