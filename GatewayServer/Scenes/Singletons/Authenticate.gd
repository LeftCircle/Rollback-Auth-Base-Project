extends Node

var network = ENetMultiplayerPeer.new()
var ip = "127.0.0.1" # This ip address loops back to yourself!
# Also needs a unique port
var port = 28839 # 1911 in tutorial

func _ready():
	connect_to_server()

func connect_to_server():
	var client_status = network.create_client(ip, port)
	if client_status != OK:
		OS.alert("Client creation failed")
	if network.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		OS.alert("Failed to connect to the authintiaction server")
	var multiplayer_api : MultiplayerAPI = get_tree().get_multiplayer()
	multiplayer_api.multiplayer_peer = network
	get_tree().set_multiplayer(multiplayer_api, get_path())
	multiplayer_api.connection_failed.connect(self._on_connection_failed)
	multiplayer_api.connected_to_server.connect(self._on_connection_succeeded)

func _on_connection_failed():
	print("Failed to connect to authentication server from gateway server")

func _on_connection_succeeded():
	print("Successfully connected Authentication Servers!")

@rpc("any_peer")
func authenticate_player(username, password, player_id):
	print("Sending out authentication request")
	# RPC ID of 1 to poll the authentication server
	rpc_id(1, "authenticate_player", username, password, player_id)
	
@rpc("any_peer")
func authentication_results(result, player_id, token):
	print("results received and replying to player login request")
	Gateway.return_login_request(result, player_id, token)

@rpc("any_peer")
func create_account(username : String, password : String, player_id):
	print("Sending out create accound request to authentication server")
	rpc_id(1, "create_account", username, password, player_id)

@rpc("any_peer")
func create_account_results(result : bool, player_id, message : int):
	print("Results received, replying to player create account request")
	Gateway.return_create_account_request_func(result, player_id, message)

################################################################################
#### Auth functions
################################################################################
#@rpc("any_peer")
#func authenticate_player(username, password, player_id):
#	pass

#@rpc("any_peer")
#func create_account(username : String, password : String, player_id):
#	pass
