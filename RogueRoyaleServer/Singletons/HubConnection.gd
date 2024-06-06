extends Node

var network = ENetMultiplayerPeer.new()
var gateway_api = SceneMultiplayer.new()
var ip = "127.0.0.1"
var port = 28840 # 1912 in tutorial, same as the gameservers in authentication

@onready var gameserver = get_node("/root/Server")

func _ready():
	connect_to_server()

func _physics_process(delta):
	#if get_custom_multiplayer() == null:
	#	return
	if not gateway_api.has_multiplayer_peer():
		#print("Gateway api still has no peer")
		return
	gateway_api.poll()

func connect_to_server():
	var client_status = network.create_client(ip, port)
	if client_status != OK:
		OS.alert("Client creation failed")
	if network.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		OS.alert("Failed to connect to the authintiaction server")
	gateway_api.multiplayer_peer = network
	gateway_api.root_path = get_path()
	get_tree().set_multiplayer(gateway_api, get_path())
	#print("HubConnection started - Should connect to Auth server")
	#set_custom_multiplayer(gateway_api)
	#custom_multiplayer.set_root_node(self)
	#custom_multiplayer.set_multiplayer_peer(network)
	gateway_api.connection_failed.connect(self._on_connection_failed)
	gateway_api.connected_to_server.connect(self._on_connection_succeeded)


func _on_connection_failed():
	print("Failed to connect to Game Server Hub")

func _on_connection_succeeded():
	print("Successfully connected to Game Server Hub")

@rpc("any_peer")
func receive_login_token(token):
	print("received a login token of ", token)
	gameserver.expected_tokens.append(token)
	print("Expected tokens are now :")
	print(gameserver.expected_tokens)

