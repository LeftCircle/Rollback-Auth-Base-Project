extends Node

var player_latencies : Dictionary = {}
var max_average_frame_latency : float = 0.0

func _ready():
	Server.connect("player_connected",Callable(self,"_on_player_connected"))
	Server.connect("player_disconnected",Callable(self,"_on_player_disconnected"))

func _on_player_connected(player_id : int) -> void:
	var new_tracker = FrameLatencyTracker.new()
	add_child(new_tracker)
	player_latencies[player_id] = new_tracker
	player_latencies[player_id].network_id = player_id

func _on_player_disconnected(player_id : int) -> void:
	if player_latencies.has(player_id):
		player_latencies[player_id].queue_free()
		player_latencies.erase(player_id)

func receive_frame_latency(player_id : int, frame_latency : float) -> void:
	if not player_latencies.has(player_id):
		_on_player_connected(player_id)
	player_latencies[player_id].add_frame_latency(frame_latency)

func receive_client_frame_and_acked_frames(player_id : int, client_frame : int, acked_frames : Array) -> void:
	var n_acked = acked_frames.size()
	#print("Acked frames = ", acked_frames, " vs server frame ", CommandFrame.frame)
	for i in range(n_acked):
		var latency = CommandFrame.frame - acked_frames[i]
		receive_frame_latency(player_id, latency)

	#PlayerSyncController.adjust_client(player_id, player_latencies[player_id].average, client_frame)
	#var ping_latency = Server.ping_tracker.get_frame_latency(player_id)
	#PlayerSyncController.adjust_client(player_id, ping_latency, client_frame)

func get_frame_latency(player_id) -> float:
	if not player_latencies.has(player_id):
		_on_player_connected(player_id)
	return player_latencies[player_id].get_frame_latency()

func get_half_rtt(player_id) -> float:
	return player_latencies[player_id].get_frame_latency() / 2.0

# Called from PlayerSyncController max latency timer
func get_max_average_latency() -> float:
	var max_average = 0.0
	for player_id in player_latencies:
		var average : float = player_latencies[player_id].get_frame_latency()
		max_average = max(max_average, average)
	max_average_frame_latency = max_average
	return max_average
