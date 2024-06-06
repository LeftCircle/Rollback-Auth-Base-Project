extends FrameLatencyTracker
class_name C_FrameLatencyTracker

signal local_latency_update(frames)
signal remote_latency_update(player_id, frames)
signal rtt_update(rtt)

var delayed_function_executioner = DelayedFunctionExecutioner.new()

func _ready():
	delayed_function_executioner.execute_after_x_frames = 60
	delayed_function_executioner.funcref_to_execute = send_signals
	ObjectsInScene.track_object(self)

func _physics_process(delta):
	delayed_function_executioner.delay_execute()

func decompress(frame : int, bit_packer : OutputMemoryBitStream) -> void:
	var server_data = netcode.state_compresser.decompress(bit_packer) as FrameLatencyTrackerData
	data_container.eNet_rtt = server_data.eNet_rtt

func get_rtt():
	return data_container.eNet_rtt

func receive_server_player_state_frame(server_frame : int) -> void:
	var frame_diff = CommandFrame.frame_difference(CommandFrame.input_buffer_frame, server_frame)
	add_local_frame_latency(frame_diff)
	delayed_function_executioner.delay_execute()

func receive_remote_frame(player_id : int, remote_frame : int) -> void:
	var frame_diff = CommandFrame.frame_difference(CommandFrame.input_buffer_frame, remote_frame)
	add_remote_frame_latency(player_id, frame_diff)
	#print("Remote average = ", remote_latencies[player_id].average)

func send_signals():
	emit_signal("local_latency_update", local_frame_latency.average)
	for player_id in remote_latencies.keys():
		emit_signal("remote_latency_update", player_id, remote_latencies[player_id].average)
