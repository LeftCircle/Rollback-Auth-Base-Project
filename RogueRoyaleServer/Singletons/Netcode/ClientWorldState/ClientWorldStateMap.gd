extends Node
const PLAYER_QUEUED_FREE = -1

var player_world_state_map = {}

func _ready():
	Server.connect("player_connected",Callable(self,"_on_player_connected"))
	Server.connect("player_disconnected",Callable(self,"_on_player_disconnected"))

func _on_player_connected(player_id : int) -> void:
	var new_hist = ClientWorldStateFrameHistory.new()
	new_hist.player_id = player_id
	player_world_state_map[player_id] = new_hist

func _on_player_disconnected(player_id : int) -> void:
	if player_world_state_map.has(player_id):
		player_world_state_map.erase(player_id)

func add_client_frames(player_id : int, command_frame : int, world_state_frame : int) -> void:
	var hist = player_world_state_map[player_id]
	Logging.log_line(str(player_id) + " Client frame = " + str(command_frame) + " world state frame = " + str(world_state_frame))
	hist.add_data(command_frame, world_state_frame)

func get_world_state_frame(player_id : int, command_frame : int = CommandFrame.frame) -> int:
	if player_world_state_map.has(player_id):
		var hist = player_world_state_map[player_id]
		return hist.retrieve_world_state_frame(command_frame)
	return PLAYER_QUEUED_FREE

func get_n_predicted_frames(player_id : int, command_frame : int = CommandFrame.frame) -> int:
	var hist = player_world_state_map[player_id]
	var data = hist.retrieve_data(command_frame)
	return CommandFrame.frame_difference(data.command_frame, data.world_state_frame)

func get_n_frames_ahead(player_id : int, command_frame : int = CommandFrame.frame) -> int:
	var hist = player_world_state_map[player_id]
	var data = hist.retrieve_data(command_frame)
	return CommandFrame.frame_difference(data.command_frame, command_frame)
