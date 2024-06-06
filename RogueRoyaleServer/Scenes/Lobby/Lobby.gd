extends Node
class_name Lobby
# Keeps track of all players that have joined and if they have pressed the
# ready button or not. Once all players have pressed the ready button,
# A start command step is decided, then InputProcessing will determine on what
# command step each client should start the game

# TO DO -> ensure that the starting step is greater than all players latency
const START_IN_X_COMMAND_STEPS : int = 20
enum {NOT_READY, READY, SYNCED_COMMAND, MAP_LOADED, WAITING_FOR_START}

# States
enum {IN_LOBBY, SYNCING_COMMAND, LOADING_MAP}

var players_in_lobby : Dictionary = {}
var all_ready = false
var game_start_frame : int = INF
var state = IN_LOBBY

func _ready():
	Server.connect("player_connected",Callable(self,"_on_player_connected"))
	Server.connect("player_disconnected",Callable(self,"_on_player_disconnected"))

func _on_player_connected(player_id : int) -> void:
	players_in_lobby[player_id] = NOT_READY

func _on_player_disconnected(player_id : int) -> void:
	if players_in_lobby.has(player_id):
		players_in_lobby.erase(player_id)
		# TO DO -> QUEUE FREE ANY SPAWNED CHARACTERS

func _physics_process(_delta):
	match state:
		IN_LOBBY:
			while_players_in_lobby()
		SYNCING_COMMAND:
			while_players_sync_command()
		LOADING_MAP:
			while_players_load_map()
		WAITING_FOR_START:
			while_waiting_for_start()

func while_players_in_lobby():
	if all_players_ready():
		print("all players are ready")
		#_spawn_players()
		InputProcessing.sync_command_frames_and_set_buffers(players_in_lobby.keys())
		all_ready = true
		state = SYNCING_COMMAND

func all_players_ready() -> bool:
	if not players_in_lobby.is_empty():
		return _all_players_ready()
	return false

func _all_players_ready() -> bool:
	for player_id in players_in_lobby.keys():
		if players_in_lobby[player_id] == NOT_READY:
			return false
	return true

func _spawn_players():
	# Spawn players and sync the serialized_id's to uids
	for player_id in players_in_lobby.keys():
		Map.spawn_new_player(player_id)
		var class_instance_id = Map.get_player_node(player_id).netcode.class_instance_id
		Server.send_client_serialization(player_id, class_instance_id)
	#TestCharacterSpawner.spawn_test_characters()

func while_players_sync_command():
	if all_players_synced():
		Map.send_map_data()
		state = LOADING_MAP
		#Logging.log_line("All players synced")
		print("All players synced")

func all_players_synced():
	for player_id in players_in_lobby.keys():
		if not players_in_lobby[player_id] == SYNCED_COMMAND:
			return false
	return true

func while_players_load_map():
	if all_players_loaded() == true:
		game_start_frame = CommandFrame.frame + START_IN_X_COMMAND_STEPS
		InputProcessing.send_players_starting_step(game_start_frame)
		state = WAITING_FOR_START
		print("All players loaded map")

func all_players_loaded() -> bool:
	for player_id in players_in_lobby.keys():
		if players_in_lobby[player_id] != MAP_LOADED:
			return false
	return true

func while_waiting_for_start():
	if CommandFrame.frame >= game_start_frame:
		WorldState.start_sending_world_state()
		PlayerStateSync.start_syncing_state()
		PlayerSyncController.adjusting_process_speeds = true
		_spawn_players()
		Logging.log_line("GAME START!!")
		print("Game start!!")
		queue_free()

#func build_spawn_position_dict() -> Dictionary:
#	var spawn_dict = {}
#	for serialized_id in players_in_lobby.keys():
#		var spawn_pos = Map.get_player_node(serialized_id).position
#		spawn_dict[serialized_id] = spawn_pos
#	return spawn_dict

func player_ready(player_serialized_id) -> void:
	if not players_in_lobby[player_serialized_id] == READY:
		players_in_lobby[player_serialized_id] = READY
		#Map.spawn_new_player(player_serialized_id)

func player_not_ready(player_id) -> void:
	if not all_ready:
		players_in_lobby[player_id] = NOT_READY

func player_command_step_synced(player_id) -> void:
	players_in_lobby[player_id] = SYNCED_COMMAND

func player_map_loaded(player_id : int, client_command_step : int, server_command_step : int):
	players_in_lobby[player_id] = MAP_LOADED
	print("Player map loaded on client step ", client_command_step, " Server receieved ", server_command_step)
