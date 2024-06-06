extends Node

# This system will receive packets from the server, then update the player entities
# and components

# If this is a system that acts on entities with specific components, should we
# create a component for each packet? Or just send the packets here....


var packets = []
var new_packets = []
var mutex = Mutex.new()

func execute():
	Logging.log_line("---------------- START OF PLAYER UPDATE SYSTEM ----------------")
	_move_new_packets_to_be_processed()
	for packet in packets:
		PlayerStateSync.receive_player_states(packet)
	Logging.log_line("---------------- END OF PLAYER UPDATE SYSTEM ----------------")

func receive_packet(packet : Array) -> void:
	mutex.lock()
	new_packets.append(packet)
	mutex.unlock()

func _move_new_packets_to_be_processed() -> void:
	mutex.lock()
	packets = new_packets.duplicate()
	new_packets.clear()
	mutex.unlock()


