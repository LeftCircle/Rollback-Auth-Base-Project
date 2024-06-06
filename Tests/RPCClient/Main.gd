extends Node2D

#const ip = "127.0.0.1"
const ip = "20.185.61.230" # server
const DEFUALT_PORT : int = 28838

var network = ENetMultiplayerPeer.new()
var server_api = SceneMultiplayer.new()
var has_ping = false
var new_packet : PackedByteArray = []
var physics_step = 0
var connected = false
var bit_packer = OutputMemoryBitStream.new()

func _ready():
	#multiplayer.connected_to_server.connect(self.join_as_client)
	connect_to_server()

func _process(_delta):
	if not server_api.has_multiplayer_peer():
		return
	server_api.poll()

func connect_to_server():
	network.create_client(ip, DEFUALT_PORT)
	server_api.multiplayer_peer = network
	server_api.root_path = get_path()
	get_tree().set_multiplayer(server_api, get_path())
	#get_tree().multiplayer_poll = false
	server_api.connection_failed.connect(self._on_connection_failed)
	server_api.connected_to_server.connect(self._on_connection_succeeded)
	server_api.peer_packet.connect(self._on_packet_received)

func _on_packet_received(id : int, packet : PackedByteArray) -> void:
	print("Received ping")
	has_ping = true
	new_packet = packet

func _physics_process(delta):
	if connected:
		physics_step += 1
		if has_ping:
			has_ping = false
			server_api.send_bytes(new_packet, 1)
		#if physics_step >= 20 and not new_packet.is_empty():
		var bytes = PackedByteArray(get_frame_bytes(physics_step))
		server_api.send_bytes(bytes, 1, MultiplayerPeer.TRANSFER_MODE_UNRELIABLE)

func get_frame_bytes(frame : int):
	bit_packer.reset()
	bit_packer.compress_frame(frame)
	var bytes = bit_packer.get_array_to_send()
	return bytes

#func join_server():
#	var peer = ENetMultiplayerPeer.new()
#	peer.create_client(ip, DEFUALT_PORT)
#	multiplayer.multiplayer_peer = peer
#	print("Joining server")

func join_as_client() -> void:
	print("Connection established, calling to spawn player")
	var client_id = multiplayer.get_unique_id()
	var player_name : String = "TestName"
	rpc_id(1, "server_spawn_player", client_id, player_name)

@rpc("any_peer")
func server_spawn_player(client_id : int, player_name : String) -> void:
	print("placeholder server spawn player called")

@rpc
func create_player_node() -> void:
	print("Now actually running create player function")

func _on_connection_failed():
	print("Failed to connect")

func _on_connection_succeeded():
	print("Successfully connected")
	join_as_client()
	connected = true

