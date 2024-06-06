extends Node

const NO_ACTION_FOR_FRAME = -1

# {player_id : ActionRingBuffer, ...} Each buffer holds ActionFromClients
var player_action_buffers = {}
var adjusting_process_speeds = false

#var mutex = Mutex.new()
var EMPTY_ACTION = ActionFromClient.new()
var input_buffer = ProjectSettings.get_setting("global/input_buffer")

#@onready var latency_tracker_container = Node.new()

#@onready var command_latency_tracker = load("res://Singletons/CommandFrameHelpers/CommandLatencyTracker.tscn")

func _ready():
#	latency_tracker_container.name = "LatencyTrackerContainer"
#	add_child(latency_tracker_container, true)
	Server.connect("player_connected",Callable(self,"_on_player_connected"))
	Server.connect("player_disconnected",Callable(self,"_on_player_disconnected"))
#
func _on_player_connected(player_id : int) -> void:
	print("Player ", player_id, "'s inputs are now being tracked")
	add_player_to_action_dicts(player_id)
	#start_command_latency_tracker(player_id)

func add_player_to_action_dicts(player_id : int) -> void:
	player_action_buffers[player_id] = ActionRingBuffer.new()
	player_action_buffers[player_id].player_id = player_id

#func start_command_latency_tracker(player_id : int) -> void:
#	var new_command_latency_tracker = command_latency_tracker.instantiate()
#	new_command_latency_tracker.init(player_id)
#	new_command_latency_tracker.set_name(str(player_id) + "_CommandLatencyTracker")
#	latency_tracker_container.add_child(new_command_latency_tracker, true)

func _on_player_disconnected(player_id : int) -> void:
	if player_id in player_action_buffers.keys():
		player_action_buffers.erase(player_id)
	#if get_node_or_null(str(player_id) + "_CommandLatencyTracker") != null:
	#	get_node(str(player_id) + "_CommandLatencyTracker").call_deferred("queue_free")

func receive_unreliable_history(player_id : int, action_histories : Array) -> void:
	#var dup = action_histories.duplicate(true)
	player_action_buffers[player_id].receive_action_history_sliding_buffer(action_histories)

func get_action_or_duplicate_for_frame(player_id : int, frame : int):
	var buffered_frame = CommandFrame.get_past_frame(frame, input_buffer)
	if player_action_buffers.has(player_id):
		return player_action_buffers[player_id].get_action_or_duplicate_for_frame(frame, buffered_frame)
	else:
		return EMPTY_ACTION

func sync_command_frames_and_set_buffers(player_ids : Array) -> void:
	for player_id in player_ids:
		#var rtt_in_frames = 2 * player_command_latency_tracker(player_id).average_step_latency
		var rtt_in_ms = Server.get_rtt_in_ms(player_id)
		var rtt_in_frames = rtt_in_ms / CommandFrame.frame_length_msec
		var client_ahead_by = rtt_in_frames + 1
		var buffer = rtt_in_frames + CommandFrame.client_buffer_pad
		#player_command_latency_tracker(player_id).queue_free_command_latency_tracker()
		Server.sync_command_frames(player_id, rtt_in_frames, client_ahead_by, buffer)

func get_average_buffer(player_id : int) -> float:
	return player_action_buffers[player_id].get_average_buffer()

#func _get_max_latency() -> float:
#	var latency_trackers = latency_tracker_container.get_children()
#	var max_latency = 0
#	for latency_tracker in latency_trackers:
#		max_latency = max(latency_tracker.average_step_latency, max_latency)
#	return max_latency

func send_players_starting_step(game_start_step : int) -> void:
	for player_id in player_action_buffers.keys():
		var client_starting_command_step = game_start_step
		print("Starting server step = ", game_start_step)
		Server.send_starting_command_step(player_id, client_starting_command_step)
		print("Finished sending start step on frame ", CommandFrame.get_command_frame_number())

#func player_command_latency_tracker(player_id : int):
#	return latency_tracker_container.get_node_or_null(str(player_id) + "_CommandLatencyTracker")

func receive_action_for_player(frame : int, player_id : int, action : ActionFromClient) -> void:
	var buffered_frame = CommandFrame.get_previous_frame(frame, input_buffer)
	if not player_action_buffers.has(player_id):
		_on_player_connected(player_id)
	player_action_buffers[player_id].receive_action(buffered_frame, action)
