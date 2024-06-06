extends Node
# We get a history of inputs from the user, check to see if they have been
# used, and if not add them to the unused_action times.

const NOT_YET_RECEIVED = -1

# {player_id : ActionRingBuffer, ...} Each buffer holds ActionFromClients
var player_action_buffers = {}

var EMPTY_ACTION = ActionFromClient.new()
var input_buffer = ProjectSettings.get_setting("global/input_buffer")


func _ready():
	pass

func _on_player_connected(player_id : int) -> void:
	print("Player ", player_id, "'s inputs are now being tracked")
	add_player_to_action_dicts(player_id)
	#start_command_latency_tracker(player_id)

func add_player_to_action_dicts(player_id : int) -> void:
	if player_id == Server.server_api.get_unique_id():
		register_local_player(player_id)
	else:
		register_remote_player(player_id)

func register_local_player(player_id) -> void:
	var local_buffer = LocalActionRingBuffer.new()
	local_buffer.player_id = player_id
	player_action_buffers[player_id] = local_buffer

func register_remote_player(player_id : int) -> void:
	var remote_buffer = RemoteActionRingBuffer.new()
	remote_buffer.player_id = player_id
	player_action_buffers[player_id] = remote_buffer

func is_ring_buffer_remote(player_id : int) -> bool:
	var buffer_class : String = player_action_buffers[player_id].get_custom_class()
	if buffer_class == "RemoteActionRingBuffer":
		return true
	return false

#func start_command_latency_tracker(player_id : int) -> void:
#	var new_command_latency_tracker = command_latency_tracker.instantiate()
#	new_command_latency_tracker.init(player_id)
#	new_command_latency_tracker.set_name(str(player_id) + "_CommandLatencyTracker")
#	latency_tracker_container.add_child(new_command_latency_tracker, true)

func _on_player_disconnected(player_id : int) -> void:
	if player_id in player_action_buffers.keys():
		player_action_buffers.erase(player_id)
	if get_node_or_null(str(player_id) + "_CommandLatencyTracker") != null:
		get_node(str(player_id) + "_CommandLatencyTracker").call_deferred("queue_free")

func receive_unreliable_history(player_id : int, action_histories : Array) -> void:
	Logging.log_line("Received actions for player_id " + str(player_id))
	if not player_action_buffers.has(player_id):
		add_player_to_action_dicts(player_id)
	player_action_buffers[player_id].receive_action_history_sliding_buffer(action_histories)

func get_action_or_duplicate_for_frame(frame : int, player_id : int):
	Logging.log_line("Trying to get actions for player id " + str(player_id))
	frame = CommandFrame.get_previous_frame(frame, input_buffer)
	if not player_action_buffers.has(player_id):
		add_player_to_action_dicts(player_id)
	return player_action_buffers[player_id].get_action_or_duplicate_for_frame(frame)

func has_received_current_and_previous_for_frame(player_id, frame : int) -> bool:
	if not player_action_buffers.has(player_id):
		return false
	frame = CommandFrame.get_previous_frame(frame, input_buffer)
	var action_ring_buff = player_action_buffers[player_id] as ActionRingBuffer
	return action_ring_buff.has_received_current_and_previous_for_frame(frame)

#func get_input_action_for_frame(player_id : int, frame : int):
#	if not player_action_buffers.has(player_id):
#		return InputActions.new()
#	frame = CommandFrame.get_previous_frame(frame, input_buffer)
#	var action_ring_buff = player_action_buffers[player_id] as ActionRingBuffer
#	return action_ring_buff.get_input_action_for_frame(frame)

func copy_input_actions_for_frame_into(player_id : int, frame : int, into_actions : InputActions) -> void:
	if not player_action_buffers.has(player_id):
		into_actions.reset()
	frame = CommandFrame.get_previous_frame(frame, input_buffer)
	var action_ring_buff = player_action_buffers[player_id] as ActionRingBuffer
	action_ring_buff.copy_input_actions_for_frame_into(frame, into_actions)

func get_most_recently_received_actions(player_id):
	var action_ring_buff = player_action_buffers[player_id] as RemoteActionRingBuffer
	var most_recent_frame = action_ring_buff.get_most_recent_received_frame()
	return action_ring_buff.get_action_or_duplicate_for_frame(most_recent_frame)

func receive_unbuffered_action_for_player(frame : int, player_id : int, action : ActionFromClient) -> void:
	if not player_action_buffers.has(player_id):
		_on_player_connected(player_id)
	player_action_buffers[player_id].receive_action(frame, action)

func receive_action_for_player(frame : int, player_id : int, action : ActionFromClient) -> void:
	var buffered_frame = CommandFrame.get_previous_frame(frame, input_buffer)
	if not player_action_buffers.has(player_id):
		_on_player_connected(player_id)
	player_action_buffers[player_id].receive_action(buffered_frame, action)

func before_gut_test():
	player_action_buffers.clear()
