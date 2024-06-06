extends PackageBuilder

func _physics_process(delta):
	if not netcode_objs_to_compress.is_empty():
		send_map_data()

func add_netcode_to_compress(netcode, send_to_player_ids : Array = [SEND_TO_ALL]) -> void:
	_add_netcode_to_compress(netcode, send_to_player_ids)

func send_map_data():
	_compress_netcode_objects()
	_send_all_map_updates()
	_reset()

func _send_all_map_updates():
	# TO DO -> multithread creating arrays to send
	for client_id in packets_to_players.keys():
		var comp_player_state = packets_to_players[client_id].create_array_to_send()
		Server.send_map_spawn_data(client_id, comp_player_state)
		packets_to_players[client_id].reset()

func send_map_data_test():
	_compress_netcode_objects()
	_send_all_map_updates()
