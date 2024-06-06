extends Node

# MUST be named Server to work with the host server. This is so that the paths in both
# the server and the client match up for function calls
# This script is onready, so it will automatically load when the project is run
# This is the fork that connects connects the client to the server, and redirects
# the code to the appropriate place

var network = ENetMultiplayerPeer.new()
var server_api = SceneMultiplayer.new()
var ip = "127.0.0.1" # This ip address loops back to yourself!
#var ip = "20.185.61.230" # server
var port = 28836 # 1909 in tutorial
var scene_handler_path = "/root/SceneHandler"
var login_path = "/root/SceneHandler/LoginScreen"
var map_path = "/root/SceneHandler/Map"
var token
var n_unreliable_sends = 0
var server_process_frames = 0
var mutex = Mutex.new()
var player_name : String
var packet_types = PacketTypes.new()
var n_bits_for_packet : int
var frame_latency : int

func _ready():
	n_bits_for_packet = packet_types.get_n_bits_for_packet_type()

#func _process(delta):
#	network.poll()

func connect_to_server():
	connect_and_check_connection()
	server_api.connection_failed.connect(self._on_connection_failed)
	server_api.connected_to_server.connect(self._on_connection_succeeded)
	server_api.peer_packet.connect(self._on_packet_received)

func connect_and_check_connection():
	var client_status = network.create_client(ip, port)
	_check_status(client_status)
	server_api.multiplayer_peer = network
	server_api.root_path = get_path()
	get_tree().set_multiplayer(server_api, get_path())
	get_tree().multiplayer_poll = false

func _check_status(client_status) -> void:
	if client_status != OK:
		OS.alert("Client creation failed")
	if network.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		OS.alert("Failed to connect to the authintiaction server")

func _on_connection_failed():
	print("Failed to connect")
	# TO DO -> does this have to be done every time we disconnect?
	get_tree().network_peer = null

func _on_connection_succeeded():
	print("Successfully connected. Starting clock syncs and getting test name if needed")
	get_node(scene_handler_path).on_connection()
	#_send_player_name()

func _send_player_name():
	pass
	#rpc_id(1, "receive_player_name", player_name)

@rpc("authority")
func get_token_rpc():
	Logging.log_server_receive("get_token")
	# Send this token back to the main server
	print("Sending token ", token)
	rpc_id(1, "return_token", token)
	Logging.log_server_send("return_token")

# All required startup information will begin to be acquired once the
# athentication results are received and true. This is where the lobby is created,
# the rng is set, and potentially more to come!
@rpc("authority")
func return_token_verification_results_rpc(result):
	Logging.log_server_receive("return_token_verification_results")
	if result == true:
		get_node(scene_handler_path).enter_lobby()
	else:
		print("Verification failed. Try logging in again")
		get_node(login_path).enable_login_buttons(false)

@rpc("authority")
func determine_command_step_latency(old_server_command_step : int) -> void:
	Logging.log_server_receive("determine_command_step_latency")
	rpc_id(1, "receive_command_step_latency", CommandFrame.get_command_frame_number(), old_server_command_step)
	Logging.log_server_send("receive_command_step_latency")

###############################################################################
######## Map Functions
###############################################################################

func _on_packet_received(id : int, packet) -> void:
	if id == 1:# and not ProjectSettings.get_setting("global/ClientOnlyTest"):
		packet = Array(packet)
		var packet_type = packet.pop_back()
		if packet_type == packet_types.INPUTS:
			_receive_player_inputs_packet(packet)
		elif packet_type == packet_types.PLAYER_STATES:
			PlayerUpdateSystem.receive_packet(packet)
			#PlayerStateSync.receive_player_states(packet)
		elif packet_type == packet_types.WORLD_STATE:
			Logging.log_line("RECEIVED WORLD STATE")
			WorldState.receive_world_state(packet)
		elif packet_type == packet_types.OBJECTS_TO_FREE:
			DeferredDeleteComponent.receive_packet(packet)
		elif packet_type == packet_types.ITERATION_CHANGE:
			Logging.log_line("RECEIVED ITERATION CHANGE " + str(packet[0]))
			CommandFrame.iteration_speed_manager.receive_iteration_packet(packet)
		elif packet_type == packet_types.PING:
			_respond_frame_ping(packet)
		elif packet_type == packet_types.WORLD_SPAWN:
			Map.receive_map_spawn_data(packet)
		else:
			assert(false) #,"Packet type not yet supported " + str(packet_type))

#@rpc("any_peer")
#func receive_world_state(compressed_world_state : PackedByteArray):
#	var compressed_world_state_array = Array(compressed_world_state)
#	Logging.log_server_receive("receive_world_state")
#	if get_tree().get_remote_sender_id() == 1:
#		WorldState.receive_world_state(compressed_world_state_array)

func _respond_frame_ping(packet : Array):
	frame_latency = packet.pop_back()
	#print(frame_latency)
	var server_comp_frame = packet.slice(0, 3)#2)
	var server_frame = BaseCompression.decompress_frame_from_3_bytes(server_comp_frame)
	Logging.log_line("Received frame ping for frame " + str(server_frame))
	var frame_frac = Engine.get_physics_interpolation_fraction()
	var comp_frame_frac = BaseCompression.compress_float_between_zero_and_one(frame_frac)
	var comp_frac_bytes = BaseCompression.bit_array_to_int_array(comp_frame_frac)
	assert(comp_frac_bytes.size() == 2)
	packet = packet + CommandFrame.compressed_frame + comp_frac_bytes + [packet_types.PING]
	var return_packet = PackedByteArray(packet)
	server_api.send_bytes(return_packet, 1, MultiplayerPeer.TRANSFER_MODE_RELIABLE)

###############################################################################
####### Lobby Functions
###############################################################################

func lobby_ready_button_activated():
	rpc_id(1, "lobby_ready_button_activated_rpc")
	Logging.log_server_send("lobby_ready_button_activated_rpc")

func lobby_ready_button_deactivated():
	rpc_id(1, "lobby_ready_button_deactivated_rpc")
	Logging.log_server_send("lobby_ready_button_deactivated")

@rpc("authority")
func receive_synced_command_frame(synced_frame : int) -> void:
	Logging.log_server_receive("receive_synced_command_frame")
	CommandFrame.sync_command_frame(synced_frame)
	rpc_id(1, "receive_command_frame_sync_complete")

@rpc("authority")
func receive_client_serialization(network_and_instance : Array) -> void:
	Logging.log_server_receive("receive_client_serialization")
	ObjectCreationRegistry.receive_client_serialization(network_and_instance)

@rpc("authority")
func receive_client_buffer(client_buffer) -> void:
	Logging.log_server_receive("receive_client_buffer")
	CommandFrame.set_buffer(client_buffer)

@rpc("authority")
func receive_map_data(data : Dictionary) -> void:
	print("Map data should be received")
	Logging.log_server_receive("receive_map_data" + str(data))
	get_node(scene_handler_path).load_map(data)

func send_map_loaded_and_command_step() -> void:
	rpc_id(1, "receive_map_loaded_and_command_step", CommandFrame.get_command_frame_number())
	Logging.log_server_send("receive_map_loaded_and_command_step")

@rpc("authority")
func receive_starting_command_step(command_game_start_step : int) -> void:
	Logging.log_server_receive("receive_starting_command_step")
	var lobby = get_node("/root/SceneHandler/Lobby") as Lobby
	lobby.set_command_game_start_step(command_game_start_step)
	CommandFrame.game_start_step = command_game_start_step

#remote func receive_all_player_spawns(player_spawn_dict : Dictionary) -> void:
#	Logging.log_server_receive("receive_all_player_spawns")
#	if get_tree().get_remote_sender_id() == 1:
#		var lobby = get_node("/root/SceneHandler/Lobby") as Lobby
#		lobby.set_player_spawn_positions(player_spawn_dict)

###############################################################################
####### Player Functions
###############################################################################

func send_player_inputs_unreliable(player_input_history : Array) -> void:
	#var packet_type_bits = BaseCompression.compress_int_into_x_bits(packet_types.INPUTS, packet_types.N_ENUM)
	player_input_history += [packet_types.INPUTS]
	var byte_array = PackedByteArray(player_input_history)
	server_api.send_bytes(byte_array, 1, MultiplayerPeer.TRANSFER_MODE_UNRELIABLE)
	#network.set_target_peer(network.TARGET_PEER_SERVER)
	#network.put_packet(byte_array)
	Logging.log_server_send("UNRELIABLE | send_player_inputs_unreliable")

func _receive_player_inputs_packet(player_input_history : Array) -> void:
	Logging.log_line("RECEIVED PLAYER INPUTS")
	var instance_id = player_input_history.pop_back()
	var id_of_inputs = null
	# TO DO -> create a map so we don't have to loop
	for network_id in ObjectCreationRegistry.network_id_to_instance_id.keys():
		if ObjectCreationRegistry.network_id_to_instance_id[network_id] == instance_id:
			id_of_inputs = network_id
			break
	if id_of_inputs != null and id_of_inputs != server_api.get_unique_id():
		InputProcessing.receive_unreliable_history(id_of_inputs, player_input_history)
	#if ObjectCreationRegistry.network_id_to_instance_id.has(id_of_inputs):
	#	var class_int_id = ObjectCreationRegistry.class_id_to_int_id["CHR"]
	#	var player_template = ObjectCreationRegistry.find_and_return_object(class_int_id, instance_id)
	#	player_template.receive_rollback_inputs(player_input_history)

#@rpc("any_peer") func receive_player_inputs_unreliable(player_input_history : Array) -> void:
#	Logging.log_line("RECEIVED PLAYER INPUTS")
#	var id_of_inputs = get_tree().get_remote_sender_id()
#	assert(id_of_inputs != get_tree().get_unique_id())
#	if ObjectCreationRegistry.network_id_to_instance_id.has(id_of_inputs):
#		var instance_id = ObjectCreationRegistry.network_id_to_instance_id[id_of_inputs]
#		var class_int_id = ObjectCreationRegistry.class_id_to_int_id["CHR"]
#		var player_template = ObjectCreationRegistry.find_and_return_object(class_int_id, instance_id)
#		# A hack to get rid of the clients last received server frame
#		#player_input_history.pop_back()
#		player_template.receive_rollback_inputs(player_input_history)

@rpc("authority")
func disconnect_player(player_id : int) -> void:
	# Creating a timer to avoid future states including this player
	await get_tree().create_timer(0.2).timeout
	if ObjectCreationRegistry.network_id_to_instance_id.has(player_id):
		var instance_id = ObjectCreationRegistry.network_id_to_instance_id[player_id]
		var class_int_id = ObjectCreationRegistry.class_id_to_int_id["CHR"]
		var player_template = ObjectsInScene.find_and_return_object(class_int_id, instance_id)
		if is_instance_valid(player_template):
			player_template.queue_free()
	print("Successfully disconnected a player")

func get_player_stats():
	rpc_id(1, "get_player_stats")
	Logging.log_server_send("get_player_stats")

func send_normal_iterations() -> void:
	var packet = [packet_types.ITERATION_CHANGE]
	var byte_array = PackedByteArray(packet)
	server_api.send_bytes(byte_array, 1, MultiplayerPeer.TRANSFER_MODE_RELIABLE)


#remote func receive_iteration_change(speed : int) -> void:
#	if get_tree().get_remote_sender_id() == 1:
#		print("Change iteration speed to ", speed)
#		CommandFrame.change_iteration_speed(speed)
#		rpc_unreliable_id(1, "receive_iteration_acknowledge", speed)

################################################################################
########## NPC Functions
################################################################################


################################################################################
########## Server Functions
################################################################################

@rpc("any_peer")
func return_token(token):
	pass

@rpc("any_peer") 
func receive_command_step_latency(client_command_step : int, old_server_command_step : int) -> void:
	pass

@rpc("any_peer") 
func lobby_ready_button_activated_rpc() -> void:
	pass

@rpc("any_peer")
func lobby_ready_button_deactivated_rpc() -> void:
	pass

@rpc("any_peer") 
func receive_command_frame_sync_complete():
	pass

@rpc("any_peer")
func receive_map_loaded_and_command_step(client_command_step : int) -> void:
	pass

#@rpc("any_peer")
#func get_dungeon_rng_seed():
#	pass
