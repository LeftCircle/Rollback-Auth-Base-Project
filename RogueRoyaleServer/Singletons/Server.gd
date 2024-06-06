extends Node

# This is the main point of communication between the client and the server.
# Obtaining any information such as combat data will occur here, and fork the
# request for information out to child nodes/codes

signal player_connected(network_id)
signal player_disconnected(network_id)

const CLIENT_SYNC_PAD = 3

# TO DO -> Might want to use ENetConnection instead of ENetMultiplayerPeer/SceneMultiplayer

var network = ENetMultiplayerPeer.new()
var server_api = SceneMultiplayer.new()
var port = 28836
var max_players = 100
var expected_tokens = []
var packet_types = PacketTypes.new()
var n_bits_for_packet : int
var connected_players = []
#var ping_tracker = PingTracker.new()

################################################################################
############## Starting the server and connecting players
################################################################################
func _ready():
	#add_child(ping_tracker)
	startServer()
	_create_token_expiration_timer()
	n_bits_for_packet = packet_types.get_n_bits_for_packet_type()

func startServer():
	connect_and_check_connection()
	print("Server has started!!")
	network.connect("peer_connected",Callable(self,"_peer_connected"))
	network.connect("peer_disconnected",Callable(self,"_peer_disconnected"))
	server_api.peer_packet.connect(self._on_packet_received)

func connect_and_check_connection():
	var server_status = network.create_server(port, max_players)
	_check_status(server_status)
	server_api.multiplayer_peer = network
	server_api.root_path = get_path()
	get_tree().set_multiplayer(server_api, get_path())
	get_tree().multiplayer_poll = false

func _check_status(status) -> void:
	if status != OK:
		OS.alert("Server creation failed")

func _peer_connected(player_id):
	await get_tree().process_frame
	print("Player connected signal sent")
	#emit_signal("player_connected", player_id)
	print("User " + str(player_id) + " Connected. Starting Verification")
	PlayerVerification.start(player_id)
	connected_players.append(player_id)
	get_token(player_id)

func on_player_verified(player_id : int) -> void:
	emit_signal("player_connected", player_id)

func _peer_disconnected(player_id):
	print("User " + str(player_id) + " disonnected")
	if Map.get_player_node(player_id):
		rpc_id(0, "disconnect_player", player_id)
		Map.get_player_node(player_id).call_deferred("queue_free")
	connected_players.erase(player_id)
	emit_signal("player_disconnected", player_id)

func _create_token_expiration_timer():
	var timer = Timer.new()
	timer.wait_time = 30.0
	timer.autostart = true
	timer.set_name("TokenExpiration")
	timer.connect("timeout",Callable(self,"_on_TokenExpiration_timeout"))
	self.add_child(timer, true)

# Triggered once every 30 seconds
func _on_TokenExpiration_timeout():
	var current_time = Time.get_unix_time_from_system()
	var token_time
	if expected_tokens != []:
		# Go through tokens in reverse order to avoid shifting indexes
		for i in range(expected_tokens.size() -1, -1, -1):
			var token = expected_tokens[i]
			token_time = int(token.right(64))
			if current_time - token_time >= 30:
				expected_tokens.remove(i)

func get_token(player_id):
	print("Getting the token from player/rpc_id ", player_id)
	# Going to the client's server script
	var connected_players = server_api.get_peers()
	assert(player_id in connected_players)
	rpc_id(player_id, "get_token_rpc")
	Logging.log_server_send("get_token_rpc")

@rpc("any_peer")
func return_token(token):
	Logging.log_server_receive("return_token_rpc")
	var player_id = server_api.get_remote_sender_id()
	print("Token returned from ", player_id)
	PlayerVerification.verify(player_id, token)

func return_token_verification_results(player_id : int, result : bool) -> void:
	print("Returning token verification results to client")
	rpc_id(player_id, "return_token_verification_results_rpc", result)
	Logging.log_server_send("return_token_verification_results")

func get_player_command_step_latency(player_id : int) -> void:
	rpc_id(player_id, "determine_command_step_latency", CommandFrame.get_command_frame_number())
	Logging.log_server_send("get_player_command_step_latency")

@rpc("any_peer")
func receive_command_step_latency(client_command_step : int, old_server_command_step : int) -> void:
	Logging.log_server_receive("receive_command_step_latency")
	var player_id = server_api.get_remote_sender_id()
	var step_mapper = InputProcessing.player_command_latency_tracker(player_id)
	if step_mapper != null:
		step_mapper.receive_command_step_latency(client_command_step, old_server_command_step)

###############################################################################
####### Lobby Functions
###############################################################################

@rpc("any_peer")
func lobby_ready_button_activated_rpc() -> void:
	Logging.log_server_receive("lobby_ready_button_activated")
	var player_id = server_api.get_remote_sender_id()
	var lobby = get_node_or_null("/root/SceneHandler/Lobby")
	if lobby != null:
		lobby.player_ready(player_id)
		print("Lobby ready button pressed")

@rpc("any_peer")
func lobby_ready_button_deactivated_rpc() -> void:
	Logging.log_server_receive("lobby_ready_button_deactivated")
	var player_id = server_api.get_remote_sender_id()
	var lobby = get_node_or_null("/root/SceneHandler/Lobby")
	if lobby != null:
		lobby.player_not_ready(player_id)

func send_client_serialization(client_id : int, class_instance_id : int) -> void:
	Logging.log_server_send("send_client_serialization")
	var network_id_and_instance = [client_id, class_instance_id]
	print("Sending client serialization to all clients for client_id %s and instance id %s" % [client_id, class_instance_id])
	rpc_id(0, "receive_client_serialization", network_id_and_instance)

func sync_command_frames(player_id : int, latency : float, clients_ahead_by, client_buffer : int) -> void:
	var synced_frame = int(round(latency) + CommandFrame.frame) + clients_ahead_by + CLIENT_SYNC_PAD
	rpc_id(player_id, "receive_synced_command_frame", synced_frame)
	set_client_buffer(client_buffer)

func set_client_buffer(client_buffer) -> void:
	Logging.log_server_send("set_client_buffer")
	rpc_id(0, "receive_client_buffer", client_buffer)

@rpc("any_peer")
func receive_command_frame_sync_complete():
	Logging.log_server_receive("receive_command_frame_sync_complete")
	var player_id = server_api.get_remote_sender_id()
	var lobby = get_node_or_null("/root/SceneHandler/Lobby")
	lobby.player_command_step_synced(player_id)

func send_load_map_signal_to_all_clients() -> void:
	rpc_id(0, "receive_load_map_signal")
	Logging.log_server_send("send_load_map_signal_to_all_clients")

func send_map_data(data : Dictionary) -> void:
	print("Map data sent")
	rpc_id(0, "receive_map_data", data)
	Logging.log_server_send("send_map_data")

@rpc("any_peer")
func receive_map_loaded_and_command_step(client_command_step : int) -> void:
	Logging.log_server_receive("receive_map_loaded_and_command_step")
	var player_id = server_api.get_remote_sender_id()
	var server_command_step = CommandFrame.get_command_frame_number()
	(get_node("/root/SceneHandler/Lobby") as Lobby).player_map_loaded(player_id, client_command_step, server_command_step)

func send_starting_command_step(player_id : int, starting_command_step : int) -> void:
	rpc_id(player_id, "receive_starting_command_step", starting_command_step)
	print("Sending start command step of ", starting_command_step)
	Logging.log_server_send("send_starting_command_step")

func send_all_players_spawn_positions(spawn_dict : Dictionary) -> void:
	rpc_id(0, "receive_all_player_spawns", spawn_dict)
	Logging.log_server_send("send_all_players_spawn_positions")

################################################################################
########## Player Data
################################################################################

func _on_packet_received(id : int, packet) -> void:
	packet = Array(packet)
	var packet_type = packet.pop_back()
	if packet_type == packet_types.INPUTS:
		_receive_player_inputs(id, packet)
	#elif packet_type == packet_types.PING:
	#	ping_tracker.receive_packet(id, packet)
	elif packet_type == packet_types.ITERATION_CHANGE:
		PlayerSyncController.client_is_at_normal_iterations(id)
	elif packet_type == packet_types.MTU_TEST:
		Logging.log_line("MTU received")
	else:
		assert(false) #,"Packet type not yet supported " + str(packet_type))

func _receive_player_inputs(id, packet : Array) -> void:
	InputProcessing.receive_unreliable_history(id, packet)
	if ProjectSettings.get_setting("global/rollback_enabled") and ObjectCreationRegistry.network_id_to_instance_id.has(id):
		#var input_history = InputHistoryCompresser.get_input_bytes(packet)
		var instance_id = ObjectCreationRegistry.network_id_to_instance_id[id]
		# TO DO -> error here if more than 255 players
		packet += [instance_id]
		packet += [packet_types.INPUTS]
		Logging.log_line("Received inputs from player_id " + str(id))
		for player_id in server_api.get_peers():
			if player_id != id and player_id != 0:
				server_api.send_bytes(packet, player_id, MultiplayerPeer.TRANSFER_MODE_UNRELIABLE)

#@rpc("any_peer") func receive_player_inputs_unreliable(player_input_history : PackedByteArray):
#	player_input_history = Array(player_input_history)
#	Logging.log_server_receive("receive_player_inputs_unreliable")
#	var player_id = get_tree().get_remote_sender_id()
#	InputProcessing.receive_unreliable_history(player_id, player_input_history)
#
#@rpc("any_peer") func receive_short_history_unreliable(player_input_history : Array) -> void:
#	Logging.log_server_receive("Received short history")
#	var player_id = get_tree().get_remote_sender_id()
#	Logging.log_server_receive("inputs received = " + str(player_input_history))
#	InputProcessing.receive_unreliable_history(player_id, player_input_history)


func send_iteration_change(network_id : int, speed : int, n_frames : int = 0) -> void:
	var packet_byte = packet_types.ITERATION_CHANGE
	var data
	if n_frames != 0:
		var comp_frames = BaseCompression.compress_frame_into_3_bytes(n_frames)
		data = [speed] + comp_frames + [packet_byte]
	else:
		data = [speed, packet_byte]
	var byte_array = PackedByteArray(data)
	server_api.send_bytes(byte_array, network_id, MultiplayerPeer.TRANSFER_MODE_RELIABLE)

func ping_for_latency(player_id : int, data : Array) -> void:
	var packet_byte = packet_types.PING
	var byte_array = PackedByteArray(data + [packet_byte])
	server_api.send_bytes(byte_array, player_id, MultiplayerPeer.TRANSFER_MODE_RELIABLE)

func get_rtt_in_ms(player_id : int) -> float:
	var enet_peer : ENetPacketPeer = network.get_peer(player_id)
	return enet_peer.get_statistic(ENetPacketPeer.PEER_ROUND_TRIP_TIME)


################################################################################
########## World State info
################################################################################


func send_objects_to_free(player_id : int, objects_to_free : Array) -> void:
	objects_to_free += [packet_types.OBJECTS_TO_FREE]
	var byte_array = PackedByteArray(objects_to_free)
	server_api.send_bytes(byte_array, player_id, MultiplayerPeer.TRANSFER_MODE_RELIABLE)
	# Logging.log_line("send bytes = ")
	# Logging.log_line(str(byte_array))
	#Logging.log_server_send("UNRELIABLE | send_world_state"

func send_world_state(player_id : int, compressed_world_state : Array):
	compressed_world_state += [packet_types.WORLD_STATE]
	var byte_array = PackedByteArray(compressed_world_state)
	server_api.send_bytes(byte_array, player_id, MultiplayerPeer.TRANSFER_MODE_RELIABLE)
	Logging.log_line("send bytes = ")
	Logging.log_line(str(byte_array))
	#Logging.log_server_send("UNRELIABLE | send_world_state")

func send_player_states(player_id : int, compressed_data : Array) -> void:
	compressed_data += [packet_types.PLAYER_STATES]
	var byte_array = PackedByteArray(compressed_data)
	server_api.send_bytes(byte_array, player_id, MultiplayerPeer.TRANSFER_MODE_RELIABLE)

func send_map_spawn_data(player_id : int, compressed_data : Array) -> void:
	compressed_data += [packet_types.WORLD_SPAWN]
	var byte_array = PackedByteArray(compressed_data)
	var n_bytes = byte_array.size()
	#Logging.log_line("Packet for gut = " + str(byte_array))
	# MUST BE RELIABLE
	server_api.send_bytes(byte_array, player_id, MultiplayerPeer.TRANSFER_MODE_RELIABLE)

func send_reliable_data(compressed_reliable_data : Array) -> void:
	#var packet_bits = BaseCompression.compress_int_into_x_bits(packet_types.RELIABLE, packet_types.N_ENUM)
	compressed_reliable_data += [packet_types.RELIABLE]
	var bytes = PackedByteArray(compressed_reliable_data)
	server_api.send_bytes(bytes, 0, MultiplayerPeer.TRANSFER_MODE_RELIABLE)

#@rpc("any_peer")
#func get_dungeon_rng_seed():
#	Logging.log_server_receive("get_dungeon_rng_seed")
#	var player_id = get_tree().get_remote_sender_id()
#	var rng_seed = Map.map_rng_seed
#	print("Sending a seed of ", rng_seed)
#	rpc_id(player_id, "receive_rng_seed", rng_seed)
#	Logging.log_server_send("get_dungeon_rng_seed")


################################################################################
########## Signals
################################################################################

func connect_server_send(server_signal : String, node_reference, node_function : String) -> void:
	self.connect(server_signal,Callable(node_reference,node_function))

func connect_server_receive(node_signal : String, node_referece, server_function : String) -> void:
	node_referece.connect(node_signal,Callable(self,server_function))

################################################################################
########## Client rpc's
################################################################################
@rpc("authority")
func get_token_rpc():
	pass

@rpc("authority")
func return_token_verification_results_rpc(result):
	pass

@rpc("authority")
func determine_command_step_latency(old_server_command_step : int) -> void:
	pass

@rpc("authority")
func receive_synced_command_frame(synced_frame : int) -> void:
	pass

@rpc("authority")
func receive_client_serialization(network_and_instance : Array) -> void:
	pass

@rpc("authority")
func receive_client_buffer(client_buffer) -> void:
	pass

@rpc("authority")
func receive_map_data(data : Dictionary) -> void:
	pass

@rpc("authority")
func receive_starting_command_step(command_game_start_step : int) -> void:
	pass

@rpc("authority")
func disconnect_player(player_id : int) -> void:
	pass
