extends RefCounted
class_name ClientSerialization

var client_map = {}
var client_uid : int = 0
var max_uid = 17
var this_client_id : int
var network_id_to_serialized = {}

#func add_player(player_id : int) -> void:
#	if not player_id in client_map:
#		client_map[player_id] = client_uid
#		assert(client_uid < max_uid)
#		client_uid += 1

#func send_clients_serialization_map():
#	Server.send_client_serialization(client_map)

#func duplicate_map(new_client_map, deep = false) -> void:
#	client_map = new_client_map.duplicate(deep)
#	for serialized_id in client_map.keys():
#		var network_id = client_map[serialized_id]
#		network_id_to_serialized[network_id] = serialized_id

func set_this_client_id(this_client_network_id : int) -> void:
	this_client_id = get_serialized_id(this_client_network_id)

func get_id(player_id : int) -> int:
	return client_map[player_id]

func get_serialized_id(network_id : int) -> int:
	return network_id_to_serialized[network_id]
