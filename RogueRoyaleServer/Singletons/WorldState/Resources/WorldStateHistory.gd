extends Resource
class_name WorldStateHistory

var history_size = 180
var history_array = []
var previous_frame_sent : int = -1
var previous_world_state = WorldStateData.new()
var history_dict_sender = HistoryDictSender.new()

var cf_skipped_states = []

func _init():
	for i in range(history_size):
		history_array.append(WorldStateData.new())

# It's important that every command frame is documented. Command frames that
# were skipped will be a copy of the previous command frame.
#func add_data_in_physics_process(world_state : WorldStateData) -> void:
#	var frame_difference = CommandFrame.frame_difference(world_state.frame, previous_world_state.frame)
#	if frame_difference <= 0:
#		Logging.log_line("WORLD STATE HISTORY FRAME DIFFERENCE ERROR")
#		assert(false)
#	elif frame_difference > 1:
#		# adds missing frames that the server skipped
#		add_missing_frames(frame_difference)
#		# updates the player state on the old frames for those skipped states
#		_update_skipped_player_states()
#	history_array[world_state.frame % history_size].duplicate_state_deep(world_state)
#	Logging.log_line("Updating world state history index " + str(world_state.frame % history_size))
#	previous_world_state.duplicate_state_deep(world_state)

# Because these world states don't actually exist yet, we store their states in an array to be
# filled in once the world states exist
#func add_player_skipped_command_frame(frame : int, player_state : PlayerState) -> void:
#	if not frame == 0:
#		Logging.log_line("State to copy = ")
#		player_state.log_state()
#		var skipped_state = SkippedPlayerState.new()
#		skipped_state.frame = frame
#		skipped_state.entity = player_state.entity
#		skipped_state.copy_state(player_state)
#		Logging.log_line("Adding skipped state for frame " + str(frame))
#		Logging.log_line("Player state = ")
#		skipped_state.log_state()
#		cf_skipped_states.append(skipped_state)

#func add_missing_frames(frame_difference : int) -> void:
#	for i in range(frame_difference - 1):
#		#var new_data = previous_world_state.duplicate(true)
#		var frame = previous_world_state.frame + i + 1
#		var world_state_data_to_update = history_array[frame % history_size]
#		world_state_data_to_update.duplicate_state_deep(previous_world_state)
#		world_state_data_to_update.set_frame(frame)
#
#func _update_skipped_player_states():
#	for skipped_state in cf_skipped_states:
#		var world_state = get_history_for_frame_or_null(skipped_state.frame)
#		if not world_state == null:
#			Logging.log_line("Updating skipped state for frame " + str(skipped_state.frame) + " with:")
#			skipped_state.log_state()
#			world_state.add_data(skipped_state)
#	cf_skipped_states.clear()

#func get_history_for_frame_or_null(frame : int):
#	Logging.log_line("Frame at requested index = " + str(history_array[frame % history_size].frame) + " vs " + str(frame))
#	if history_array[frame % history_size].frame != frame:
#		Logging.log_line("Failed to get history for frame " + str(frame) + " got " + str(history_array[frame % history_size].frame))
#		return null
#	return history_array[frame % history_size]
#
#func get_past_state(class_id : String, class_instance : int, frame : int):
#	var world_state_data = get_history_for_frame_or_null(frame)
#	if world_state_data != null:
#		Logging.log_line("Past state data for frame " + str(frame) + " = " + str(world_state_data.data))
#		return world_state_data.get_state(class_id, class_instance)
#	return null

#func send_world_state(send_funcref):
#	# Verification
#	# Anti cheat -> Hopefully covered by authoritative server
#	# Cuts (Chunkig / map)
#	# Anything else that must be done
#	var frame_to_send = CommandFrame.frame_to_send
#	var world_state = get_history_for_frame_or_null(frame_to_send)
#	if world_state != null:
#		world_state.log_world_state()
#		var compressed_state = world_state_data_compresser.compress_world_state(world_state)
#		Logging.log_line("Compressed state = " + str(compressed_state))
#		var test_world_state = WorldStateData.new()
#		var decompressed_state = world_state_data_compresser.decompress_world_state_into(test_world_state, compressed_state)
#		Logging.log_line("Decompressed test state = ")
#		test_world_state.log_world_state()
#		Server.send_world_state(compressed_state)
#		previous_frame_sent = world_state.frame
#	else:
#		Logging.log_line("Tried to send frame " + str(frame_to_send) + " and failed. Previous frame was " + str(previous_frame_sent) + " Frame to send = " + str(frame_to_send))
#		print("SEND FAILED")
#	history_dict_sender.send_data_and_swap_buffers(send_funcref)
#	Logging.log_line("Last frame sent = " + str(previous_frame_sent))
