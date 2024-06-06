extends Node

signal server_player_frame_processed(frame)

# This is like the world state, but we just immediately read the data
var world_state_decompresser = WorldStateDecompression.new()
var world_state_data = WorldStateData.new()

func receive_player_states(compressed_world_state : Array):
	var server_frame = world_state_decompresser.get_frame(compressed_world_state)
	Logging.log_line("Decompressing server frame " + str(server_frame))
	world_state_data.frame = server_frame
	world_state_data.compressed_data = compressed_world_state
	world_state_decompresser.decompress_world_state(world_state_data)
	MissPredictFrameTracker.receive_server_player_state_frame(server_frame)
	FrameLatencyTrackerSingleton.receive_server_player_state_frame(server_frame)
	emit_signal("server_player_frame_processed", server_frame)
