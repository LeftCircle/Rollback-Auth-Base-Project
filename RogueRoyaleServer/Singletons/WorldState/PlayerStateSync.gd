extends PackageBuilder
# Like the World State, but only has information that clients immediately process

func _ready():
	set_physics_process(false)

func start_syncing_state():
	set_physics_process(true)

func _physics_process(delta):
	_compress_netcode_objects()
	_send_all_player_states()
	_reset()

func _send_all_player_states():
	# TO DO -> multithread creating arrays to send
	for client_id in packets_to_players.keys():
		var comp_player_state = packets_to_players[client_id].create_array_to_send()
		Server.send_player_states(client_id, comp_player_state)
		packets_to_players[client_id].reset()


