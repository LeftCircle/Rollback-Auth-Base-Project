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

func add_action_to_send(frame : int, actions : ActionFromClient) -> void:
	set_most_recent_frame(frame)
	#compressed_actions[frame] = compress_action(actions)
	var new_action = ActionFromClient.new()
	new_action.duplicate(actions)
	actions_to_send[frame] = new_action

func set_most_recent_frame(new_frame : int) -> void:
	if CommandFrame.command_frame_greater_than_previous(new_frame, most_recent_frame):
		most_recent_frame = new_frame

func set_decompression_frame(frame : int) -> void:
	decompression_frame = frame

static func get_input_bytes(sliding_buffer : Array) -> Array:
	var n_acked_frames = sliding_buffer[0]
	var acked_frame_end_index = (n_acked_frames * BaseCompression.BYTES_FOR_FRAME)
	return sliding_buffer.slice(acked_frame_end_index + 1)

#func get_acked_frames(sliding_buffer : Array) -> Array:
	#var n_acked_frames = sliding_buffer[0]
	#var acked_frame_end_index = (n_acked_frames * BaseCompression.BYTES_FOR_FRAME)
	#var compressed_acked_frames = sliding_buffer.slice(1, acked_frame_end_index)
	#var acked_frames = FrameAckCompresser.get_acked_frames_from_compressed_ack(n_acked_frames, compressed_acked_frames)
	#return acked_frames

func decompress_actions_and_frame_into(action : ActionFromClient, bit_packer : OutputMemoryBitStream) -> void:
	decompress_actions_into(action, bit_packer)
	action.frame = decompression_frame
	action.is_from_client = true
	decompression_frame = CommandFrame.get_previous_frame(decompression_frame)
	Logging.log_line("Received action for frame " + str(decompression_frame))
	action.log_action()

func get_current_decompression_frame():
	return decompression_frame
