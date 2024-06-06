extends Resource
class_name ActionRingBuffer

#const IDEAL_BUFFER = 3
#const BUFFER_TOO_LARGE = 8
#const BUFFER_TOO_SMALL = 1

var history_size = 180
var history = []
var input_history_compresser = InputHistoryCompresser.new()
var bit_array_reader = BitArrayReader.new()
var player_id : int
var decompressed_action = ActionFromClient.new()
var input_buffer = ProjectSettings.get_setting("global/input_buffer")

# For tracking how far ahead the client should be based off of the buffer size
var buffer_size : int = 0
var last_requested_buffered_frame : int = 0
var mutex = Mutex.new()
var last_requested_command_frame : int = 0
var average_buffer = SlidingValueAverager.new()
var bit_packer = OutputMemoryBitStream.new()

func _init():
	for i in range(history_size):
		history.append(ActionFromClient.new())

func receive_action_history_sliding_buffer(sliding_buffer : Array) -> void:
	bit_packer.init_read(sliding_buffer)
	var client_frame = bit_packer.decompress_frame()
	var client_world_state = bit_packer.decompress_frame()
	var acked_frames = FrameAckCompresser.decompress_acked_frames(bit_packer)
	ClientWorldStateMap.add_client_frames(player_id, client_frame, client_world_state)
	var c_ahead_by = CommandFrame.frame_difference(client_frame, CommandFrame.frame)
	Logging.log_line("Received inputs from " + str(player_id) + " for frame " + str(client_frame) + " Client is ahead by " + str(c_ahead_by))
	Logging.log_line("Server frame - World state frame = " + str(CommandFrame.frame_difference(client_frame, client_world_state)))
	LatencyTracker.receive_client_frame_and_acked_frames(player_id, client_frame, acked_frames)
	var next_frame = CommandFrame.get_next_frame(last_requested_buffered_frame)
	var n_received_frames = 1
	if CommandFrame.command_frame_greater_than_previous(client_frame, last_requested_buffered_frame):
		input_history_compresser.set_decompression_frame(client_frame)
		# TO DO -> safeguard with an early out
		while true:
			if bit_packer.is_finished():
				break
			if CommandFrame.command_frame_greater_than_previous(next_frame, input_history_compresser.decompression_frame):
				# We don't care about inputs that are in the past
				break
			_decompress_and_track_action(bit_packer)
			n_received_frames += 1
		Logging.log_line("Received " + str(n_received_frames) + " Frames from " + str(player_id))

func _decompress_and_track_action(bit_packer : OutputMemoryBitStream) -> void:
	var old_action = history[input_history_compresser.decompression_frame % history_size]
	input_history_compresser.decompress_actions_and_frame_into(decompressed_action, bit_packer)
	_track_input_buffer(old_action, decompressed_action)
	old_action.duplicate(decompressed_action)
	old_action.is_from_client = true
	old_action.frame = decompressed_action.frame

func _track_input_buffer(old_action : ActionFromClient, new_action : ActionFromClient):
	# We only care about future frames
	if CommandFrame.command_frame_greater_than_previous(new_action.frame, last_requested_buffered_frame):
		if old_action.is_from_client == false:
			# We have received a new action!
			#Logging.log_line("Adding 1 to buffer for action frame " + str(new_action.frame) + " vs last requested frame " + str(last_requested_command_frame))
			buffer_size += 1
			#Logging.log_line("Buffer = " + str(buffer_size))
		# We can't have repeats adding to the buffer.
		elif old_action.frame != new_action.frame:
			buffer_size += 1
			#Logging.log_line("Adding 1 to buffer for action frame " + str(new_action.frame) + " vs last requested frame " + str(last_requested_command_frame))
			#Logging.log_line("Buffer = " + str(buffer_size))
		#elif old_action.frame == new_action.frame:
			#Logging.log_line("Action " + str(new_action.frame) + " Already received")
			#Logging.log_line("Buffer = " + str(buffer_size))
	else:
		Logging.log_line("Do not care about action " + str(new_action.frame) + " vs last requested cm " + str(last_requested_command_frame))

func _track_input_buffer_with_client_frame(client_frame : int) -> void:
	assert(false) #,"does not account for out of order packets")
	buffer_size = CommandFrame.frame_difference(client_frame, CommandFrame.frame)

#func adjust_client_processing():
#	PlayerSyncController.adjust_client_with_input_buffer(player_id, buffer_size)

func get_action_or_duplicate_for_frame(frame : int, buffered_frame : int):
	#mutex.lock()
	average_buffer.add_value(buffer_size)
	last_requested_command_frame = frame
	last_requested_buffered_frame = buffered_frame
	var actions = history[buffered_frame % history_size]
	if not actions.frame == buffered_frame:
		_redo_last_actions_or_set_to_none(buffered_frame, actions)
		#print("No actions for frame ", buffered_frame)
		Logging.log_line("Speeding up client from action ring buffer")
		PlayerSyncController.adjust_processing_speeds(player_id)
		#Logging.log_line("Duplicating previous actions for buffered frame " + str(buffered_frame))
	else:
		Logging.log_line("Actions found! Actions are: ")
		actions.log_action()
		if actions.is_from_client:
			buffer_size -= 1
			Logging.log_line("Action " + str(actions.frame) + " is from client. decreasing Buffer = " + str(buffer_size))
		else:
			Logging.log_line("Action " + str(actions.frame) + " is NOT from client Buffer = " + str(buffer_size))
	# We should adjust clients here based on their buffer
	Logging.log_line("Player %s input buffer = %s" % [player_id, buffer_size])
	PlayerSyncController.adjust_processing_speeds(player_id)
	#mutex.unlock()
	return actions

func _redo_last_actions_or_set_to_none(frame : int, actions : ActionFromClient):
	Logging.log_line("No actions for frame " + str(frame))
	var previous_frame = CommandFrame.get_past_frame(frame, 1)
	var previous_actions = history[previous_frame % history_size]
	if previous_actions.frame != previous_frame:
		actions.reset()
		actions.frame = frame
		actions.is_from_client = false
		Logging.log_line("No previous frame. Setting this frame to unexecuted")
		actions.log_action()
	else:
		actions.duplicate(previous_actions)
		actions.frame = frame
		actions.is_from_client = false
		Logging.log_line("Duplicating previous frame. Actions are " + str(actions.log_action()))
		actions.log_action()

func get_average_buffer() -> float:
	return average_buffer.average

func receive_action(frame : int, action : ActionFromClient) -> void:
	var old_action = history[frame % history_size]
	old_action.duplicate(action)
	old_action.is_from_client = true
	old_action.frame = frame
