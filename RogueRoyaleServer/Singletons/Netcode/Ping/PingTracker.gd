extends Node
class_name PingTracker

# This ping tracker works by sending a message to the client every x frames.
# If we were doing this in a better manner, then we wouldn't be sending a
# single packet just for ping... it's a bit sloppy

const PING_AFTER_X_FRAMES = 5

var player_latencies = {}
var frames_since_ping = PING_AFTER_X_FRAMES
var ping_data = PingData.new()
var client_ahead_by = {}
var client_sent_ping = {}

func _ready():
	Server.connect("player_connected",Callable(self,"_on_player_connected"))
	Server.connect("player_disconnected",Callable(self,"_on_player_disconnected"))
	process_priority = ProjectSettings.get_setting("global/PROCESS_LAST")

func _physics_process(delta):
	if frames_since_ping == PING_AFTER_X_FRAMES:
		var comp_frame = CommandFrame.compressed_frame
		var frame_frac = Engine.get_physics_interpolation_fraction()
		var comp_frame_frac = BaseCompression.compress_float_between_zero_and_one(frame_frac)
		var comp_frac_bytes = BaseCompression.bit_array_to_int_array(comp_frame_frac)
		assert(comp_frac_bytes.size() == 2)
		for player_id in player_latencies.keys():
			send_ping(player_id, comp_frame, comp_frac_bytes)
		frames_since_ping = 0
	frames_since_ping += 1

func send_ping(player_id : int, comp_frame : Array, comp_frac_bytes : Array) -> void:
	var ping_latency = player_latencies[player_id].get_frame_latency()
	var ack_latency = LatencyTracker.get_frame_latency(player_id)
	Logging.log_line("Ping latency: " + str(ping_latency) + " VS ack latency: " + str(ack_latency) + " int ping latency = " + str( int(round(ping_latency))))
	var avg_ping_rounded_up = int(round(ping_latency)) + 1
	var data = comp_frame + comp_frac_bytes + [avg_ping_rounded_up]
	client_sent_ping[player_id] = avg_ping_rounded_up
	Server.ping_for_latency(player_id, data)

func get_frame_latency(player_id : int) -> float:
	return player_latencies[player_id].get_frame_latency()

func receive_packet(player_id : int, packet : Array) -> void:
	Logging.log_line("Received ping response for player_id " + str(player_id))
	var server_comp_frame = packet.slice(0, 3)#2)
	var server_comp_frame_frac = packet.slice(3, 5)#4)
	var client_comp_frame = packet.slice(5, 8)#7)
	var client_comp_frame_frac = packet.slice(7, 9)#8)
	var sent_frame = BaseCompression.decompress_frame_from_3_bytes(server_comp_frame)
	var sent_frame_frac_bits = BaseCompression.byte_array_to_bit_array(server_comp_frame_frac, BaseCompression.n_bits_for_float_between_zero_and_one)
	var sent_frame_frac = BaseCompression.decompress_float_from_bits(sent_frame_frac_bits, false, BaseCompression.n_decimals_for_float_between_zero_and_one)
	var client_frame = BaseCompression.decompress_frame_from_3_bytes(client_comp_frame)
	var client_frame_frac_bits = BaseCompression.byte_array_to_bit_array(client_comp_frame_frac, BaseCompression.n_bits_for_float_between_zero_and_one)
	var client_frame_frac = BaseCompression.decompress_float_from_bits(client_frame_frac_bits, false, BaseCompression.n_decimals_for_float_between_zero_and_one)
	sent_frame += sent_frame_frac
	client_frame += client_frame_frac
	var current_frame = CommandFrame.frame + Engine.get_physics_interpolation_fraction()
	var frame_latency = CommandFrame.frame_difference_float(current_frame, sent_frame)
	Logging.log_line("Received ping response for server frame " + str(sent_frame) + " and client frame " + str(client_frame) + " frame latency = " + str(frame_latency))
	player_latencies[player_id].add_frame_latency(frame_latency)
	var avg = player_latencies[player_id].average
	var half_rtt = get_half_rtt(player_id)
	#var c_ahead_by = CommandFrame.frame_difference_float(client_frame, sent_frame)
	var server_to_client_ahead = CommandFrame.frame_difference(client_frame, sent_frame)
	var client_to_server_ahaed = CommandFrame.frame_difference(client_frame + half_rtt, current_frame)
	# accounting for the different time it can take for the ping to go server -> client and client -> server
	var c_ahead_by = max(server_to_client_ahead, client_to_server_ahaed)
	client_ahead_by[player_id] = c_ahead_by
	Logging.log_line("Client is ahead by " + str(c_ahead_by) + " avg ping = " + str(avg))
	#PlayerSyncController.adjust_client(player_id, c_ahead_by, half_rtt)

func get_half_rtt(player_id : int) -> float:
	return player_latencies[player_id].average / 2.0

func get_client_ahead_by(player_id) -> int:
	if client_ahead_by.has(player_id):
		return client_ahead_by[player_id]
	return 0

func _on_player_connected(player_id : int) -> void:
	player_latencies[player_id] = FrameLatencyTracker.new()
	player_latencies[player_id].network_id = player_id
	client_ahead_by[player_id] = 0
	client_sent_ping[player_id] = 0

func _on_player_disconnected(player_id : int) -> void:
	if player_latencies.has(player_id):
		player_latencies.erase(player_id)
	if client_ahead_by.has(player_id):
		client_ahead_by.erase(player_id)
	if client_sent_ping.has(player_id):
		client_sent_ping.erase(player_id)
