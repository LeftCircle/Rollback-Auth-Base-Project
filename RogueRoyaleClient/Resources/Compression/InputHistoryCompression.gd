extends ActionFromClientCompression
class_name InputHistoryCompresser

# TO DO -> optimize so we don't have to recompress frames
const MAX_SLIDING_BUFFER = 10

# A dictionary of relevent actions where the key is the frame number
var actions_to_send = {}
var array_to_server = []
var most_recent_frame : int
var decompression_frame : int
#var last_received_frame_start_index = -3
var client_frame_end_index = -1#last_received_frame_start_index - 1
var client_frame_start_index = -3#client_frame_end_index - 2
var world_state_frame_end = client_frame_start_index - 1
var world_state_frame_start = world_state_frame_end - 2
var n_bits_end = world_state_frame_start - 1
var n_bits_start = world_state_frame_start - BaseCompression.bytes_for_n_bits
var bit_packer = OutputMemoryBitStream.new()
var action_frame_array = ActionLoopingArray.new()

func add_action_to_send(frame : int, actions : ActionFromClient) -> void:
	set_most_recent_frame(frame)
	#compressed_actions[frame] = compress_action(actions)
	#var new_action = action_frame_array.retrieve(frame)
	#new_action.duplicate(actions)
	#actions_to_send[frame] = new_action
	action_frame_array.add_data(frame, actions)
	actions_to_send[frame] = action_frame_array.retrieve_data(frame)

func set_most_recent_frame(new_frame : int) -> void:
	if CommandFrame.command_frame_greater_than_previous(new_frame, most_recent_frame):
		most_recent_frame = new_frame

func send_sliding_buffer(last_frame_acknowledged : int, current_frame : int) -> void:
	bit_packer.reset()
	var byte_array : Array
	if CommandFrame.command_frame_greater_than_previous(last_frame_acknowledged, current_frame):
		print("RUNNING BEHIND SERVER by ", CommandFrame.frame_difference(current_frame, last_frame_acknowledged))
		# TO DO -> This should be plus the latency
		CommandFrame.sync_command_frame(last_frame_acknowledged)
		byte_array = _build_sliding_buffer(last_frame_acknowledged, current_frame, false)
	else:
		byte_array = _build_sliding_buffer(last_frame_acknowledged, current_frame)
	Server.send_player_inputs_unreliable(byte_array)

func _build_sliding_buffer(last_frame_acknowledged : int, current_frame : int, delete_old_frames = true) -> Array:
	# Delete all actions before last_frame_acknowledged
	if delete_old_frames:
		_delete_old_actions(last_frame_acknowledged)
	bit_packer.compress_frame(current_frame)
	bit_packer.compress_frame(WorldState.buffered_frame)
	FrameAckCompresser.compress_acked_frames_to_bytes(bit_packer, FrameAcker.get_acked_frames())
	_compress_actions(last_frame_acknowledged, current_frame)
	return bit_packer.get_array_to_send()

func _delete_old_actions(last_frame_ack : int) -> void:
	for frame in actions_to_send.keys():
		if CommandFrame.command_frame_greater_than_previous(last_frame_ack, frame):
			actions_to_send.erase(frame)

func _compress_actions(last_frame_acknowledged : int, current_frame : int):
	# Step through current_frame -> last_frame acknowledged
	compress_action(bit_packer, actions_to_send[current_frame])
	var last_frame_to_send = _get_limited_last_frame_to_send(last_frame_acknowledged, current_frame)
	while true:
		if current_frame == last_frame_to_send:
			break
		current_frame = CommandFrame.get_previous_frame(current_frame)
		if not actions_to_send.has(current_frame):
			break
		compress_action(bit_packer, actions_to_send[current_frame])

func _get_limited_last_frame_to_send(last_frame_ack : int, current_frame : int) -> int:
	var frame_diff = CommandFrame.frame_difference(current_frame, last_frame_ack)
	if frame_diff > MAX_SLIDING_BUFFER:
		return CommandFrame.get_previous_frame(current_frame, MAX_SLIDING_BUFFER)
	return last_frame_ack

func set_decompression_frame(frame : int) -> void:
	decompression_frame = frame

#func get_acked_frames(sliding_buffer : Array) -> Array:
	#var n_acked_frames = sliding_buffer[0]
	#var acked_frame_end_index = (n_acked_frames * BaseCompression.BYTES_FOR_FRAME)
	#var compressed_acked_frames = sliding_buffer.slice(1, acked_frame_end_index + 1)
	#var acked_frames = FrameAckCompresser.get_acked_frames_from_compressed_ack(n_acked_frames, compressed_acked_frames)
	#return acked_frames

func decompress_actions_and_frame_into(action : ActionFromClient, with_bit_packer : OutputMemoryBitStream) -> void:
	# Calling the base functionality
	decompress_actions_into(action, with_bit_packer)
	action.frame = decompression_frame
	Logging.log_line("Decompressed action for frame " + str(action.frame))
	action.log_action()
	decompression_frame = CommandFrame.get_previous_frame(decompression_frame)

