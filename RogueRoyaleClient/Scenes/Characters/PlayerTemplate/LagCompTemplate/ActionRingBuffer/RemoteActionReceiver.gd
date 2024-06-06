extends RefCounted
class_name RemoteActionReceiver

var input_history_compresser = InputHistoryCompresser.new()
var decompressed_action = ActionFromClient.new()
var bit_packer = OutputMemoryBitStream.new()
var most_recent_received_frame : int = 0
var history_size : int
var remote_action_buffer : RemoteActionRingBuffer

func init(new_action_ring_buffer : RemoteActionRingBuffer) -> void:
	remote_action_buffer = new_action_ring_buffer
	history_size = remote_action_buffer.history_size

func receive_action_history_sliding_buffer(sliding_buffer : Array) -> void:
	bit_packer.init_read(sliding_buffer)
	var client_frame = _get_and_track_remote_frame(remote_action_buffer.player_id)
	# TO DO -> this is unnecessary info sent to each client. We should be
	# able to get rid of this
	_get_world_state_and_acked_frames()
	input_history_compresser.set_decompression_frame(client_frame)
	while true:
		if bit_packer.is_finished():
			break
		_decompress_and_track_action(bit_packer)

func _get_and_track_remote_frame(player_id : int) -> int:
	var client_frame = bit_packer.decompress_frame()
	_set_most_recent_frame(client_frame)
	FrameLatencyTrackerSingleton.receive_remote_frame(player_id, client_frame)
	return client_frame

func _get_world_state_and_acked_frames():
	var client_world_state = bit_packer.decompress_frame()
	var acked_frames = FrameAckCompresser.decompress_acked_frames(bit_packer)

func _set_most_recent_frame(received_frame : int) -> void:
	# TO DO -> this could cause issues if the game starts way late and 0 is perceived as the most recent frame
	if CommandFrame.command_frame_greater_than_previous(received_frame, most_recent_received_frame):
		most_recent_received_frame = received_frame

func _decompress_and_track_action(bit_packer : OutputMemoryBitStream) -> void:
	input_history_compresser.decompress_actions_and_frame_into(decompressed_action, bit_packer)
	remote_action_buffer.receive_action(decompressed_action.frame, decompressed_action)


