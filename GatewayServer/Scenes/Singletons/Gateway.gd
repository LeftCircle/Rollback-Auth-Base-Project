extends Node

var network = ENetMultiplayerPeer.new()
#var gateway_api = MultiplayerAPIExtension.new()
var gateway_api = SceneMultiplayer.new()
# Set a new port number!
var port = 28838 # 1910 in tutorial 
var max_players = 100
var cert = load("res://Certificate/X509_Certificate.crt")
var key = load("res://Certificate/x509_Key.key")


func _ready():
	start_gateway_server()
	
func _process(delta):
	#if not custom_multiplayer.has_multiplayer_peer():
	if not gateway_api.has_multiplayer_peer():
		return
	# No need to check if custom_multiplayer exists because it is made in ready
	gateway_api.poll()
	
func start_gateway_server():
	#network.set_dtls_enabled(true)
	#network.set_dtls_key(key)
	#network.set_dtls_certificate(cert)
	network.create_server(port, max_players)
	##get_tree().network_peer = network
	#set_custom_multiplayer(gateway_api)
	# once the custom multiplayer has been set, the variable becomes avaliable
	#custom_multiplayer.set_root_node(self)
	#custom_multiplayer.set_multiplayer_peer(network)
	#gateway_api.auth_callback = cert
	gateway_api.multiplayer_peer = network
	gateway_api.root_path = get_path()
	get_tree().set_multiplayer(gateway_api, self.get_path()) # allows @rpc calls to work for this scene!
	print("Gateway server started")
	
	network.connect("peer_connected",Callable(self,"_peer_connected"))
	network.connect("peer_disconnected",Callable(self,"_peer_disconnected"))
	
func _peer_connected(player_id):
	print("User " + str(player_id) + " Connected")
	await get_tree().process_frame # For some reason we have to wait before the peer appears?
	print("Connected peers are ", gateway_api.get_peers())

func _peer_disconnected(player_id):
	print("User " + str(player_id) + " Disonnected")

@rpc("any_peer")
func login_request(username : String, password : String):
	print("Login request received")
	var player_id = gateway_api.get_remote_sender_id()
	Authenticate.authenticate_player(username, password, player_id)

func return_login_request(result, player_id, token):
	rpc_id(player_id, "return_login_request_rpc", result, token)
	# Disconnect the player from the gatway because they aren't needed here
	print("Login request returned. Disconnecting player ", player_id)
	# wait for a bit to disconnect the player
	await get_tree().create_timer(2).timeout
	network.disconnect_peer(player_id)


@rpc("any_peer")
func return_login_request_rpc(results, token):
	print("Somehow hit the return login request rpc. Should go to client.")
	pass

@rpc("any_peer")
func create_account_request(username : String, password : String):
	var player_id = gateway_api.get_remote_sender_id()
	var valid_request = true
	if username == "" or password == "" or password.length() <= 6:
		valid_request = false
	if valid_request == false:
		return_create_account_request_func(valid_request, player_id, 1)
	else:
		Authenticate.create_account(username.to_lower(), password, player_id)

# for the message, 1 = failed to create, 2 = exisiting username, 3 = welcome!
func return_create_account_request_func(result : bool, player_id, message):
	rpc_id(player_id, "return_create_account_request", result, message)
	network.disconnect_peer(player_id)

@rpc("any_peer")
func return_create_account_request(result : bool, message : int):
	pass
