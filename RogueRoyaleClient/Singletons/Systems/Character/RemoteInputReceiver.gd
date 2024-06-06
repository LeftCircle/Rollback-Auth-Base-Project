extends RefCounted
class_name RemoteInputReceiver

var packets = []
var new_packets = []
var mutex = Mutex.new()

func execute():
	Logging.log_line("---------------- START OF REMOTE INPUT SYSTEM ----------------")
	_move_new_packets_to_be_processed()
	for packet in packets:
		_process_packet(packet)
		# PlayerStateSync.receive_player_states(packet)
	Logging.log_line("---------------- END OF REMOTE INPUT SYSTEM ----------------")

func receive_packet(packet : Array) -> void:
	mutex.lock()
	new_packets.append(packet)
	mutex.unlock()

func _move_new_packets_to_be_processed() -> void:
	mutex.lock()
	packets = new_packets.duplicate()
	new_packets.clear()
	mutex.unlock()

func _process_packet(packet) -> void:
	Logging.log_line("RECEIVED PLAYER INPUTS")
	var instance_id = packet.pop_back()
	var id_of_inputs = null
	# TO DO -> create a map so we don't have to loop
	for network_id in ObjectCreationRegistry.network_id_to_instance_id.keys():
		if ObjectCreationRegistry.network_id_to_instance_id[network_id] == instance_id:
			id_of_inputs = network_id
			break
	if id_of_inputs != null and id_of_inputs != Server.server_api.get_unique_id():
		InputProcessing.receive_unreliable_history(id_of_inputs, packet)
