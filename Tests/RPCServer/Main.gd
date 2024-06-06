extends Node2D

const DEFUALT_PORT : int = 28838
var network = ENetMultiplayerPeer.new()
var server_api = SceneMultiplayer.new()
var port = 28838 
var max_players = 100
var bit_packer = OutputMemoryBitStream.new()
var to_send = false
var packet_to_send

@onready var process_thread = $ProcessThread

func _ready():
	start_server()
	process_thread.init(server_api)

func _process(_delta):
	if not server_api.has_multiplayer_peer():
		return
	#server_api.poll()

func start_server():
	network.create_server(port, max_players)
	server_api.multiplayer_peer = network
	server_api.root_path = get_path()
	get_tree().set_multiplayer(server_api, get_path())
	get_tree().multiplayer_poll = false
	network.connect("peer_connected",Callable(self,"_peer_connected"))
	network.connect("peer_disconnected",Callable(self,"_peer_disconnected"))
	#server_api.peer_packet.connect(self._on_packet_received)

func _peer_connected(id : int) -> void:
	print("Peer %s connected" % id)

func _peer_disconnected(gateway_id):
	print("Gateway " + str(gateway_id) + " Disconnected")

func _input(event):
	if event.is_action_released("send_ping"):
		print("Send ping")
		var frame = CommandFrame.frame
		var frame_bytes = get_frame_bytes(frame)
		frame_bytes = PackedByteArray(frame_bytes)
		print("Frame %s bytes %s" % [frame, frame_bytes])
#		for id in server_api.get_peers():
#			print("Sending to %s" % [id])
#			server_api.send_bytes(frame_bytes, id, MultiplayerPeer.TRANSFER_MODE_UNRELIABLE)
		packet_to_send = frame_bytes
		to_send = true

func _physics_process(delta):
	#server_api.poll()
	if to_send:
		to_send = false
#		for id in server_api.get_peers():
#			print("Sending to %s" % [id])
#			server_api.send_bytes(packet_to_send, id, MultiplayerPeer.TRANSFER_MODE_UNRELIABLE)
		process_thread.send_data(packet_to_send)
	var processed_polls = process_thread.get_processed_polls()
	if not processed_polls.is_empty():
		print("Processed polls = %s" % [processed_polls])

func _on_packet_received(id : int, packet) -> void:
	packet = Array(packet)
	var return_frame = decompress_frame(packet)
	var frame_diff = CommandFrame.frame_difference(CommandFrame.frame, return_frame)
	var frame_ping = frame_diff * 16.6667
	var enet_ping = get_enet_ping(id)
	print("Frame difference: %s. Frame ping: %s ms. Enet ping: %s ms." % [frame_diff, frame_ping, enet_ping])

func get_enet_ping(id : int) -> float:
	var peer : ENetPacketPeer = network.get_peer(id)
	return peer.get_statistic(ENetPacketPeer.PEER_ROUND_TRIP_TIME)

func get_frame_bytes(frame : int):
	bit_packer.reset()
	bit_packer.compress_frame(frame)
	var bytes = bit_packer.get_array_to_send()
	return bytes

func decompress_frame(bytes : Array):
	bit_packer.init_read(bytes)
	var frame = bit_packer.decompress_frame()
	return frame

@rpc("any_peer")
func server_spawn_player(client_id : int, player_name : String) -> void:
	print("Spawning player %s on network ID %s" % [player_name, client_id])
	rpc_id(client_id, "create_player_node")
	#OtherServer.connect_to_server("asdf", "asdfasdf")

@rpc
func create_player_node():
	pass
