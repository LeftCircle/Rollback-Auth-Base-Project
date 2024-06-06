extends Node

var network = ENetMultiplayerPeer.new()
var gateway_api = SceneMultiplayer.new()
var port = 28840 # 1912 in tutorial
var max_players = 100

var gameserver_dict = {}


func _ready():
	start_server()
	
func _process(_delta):
	if not gateway_api.has_multiplayer_peer():
		return
	gateway_api.poll()

func start_server():
	network.create_server(port, max_players)
	if network.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		OS.alert("Failed to start ent server for authintication")
		assert(false)
	#get_tree().network_peer = network
	gateway_api.multiplayer_peer = network
	gateway_api.root_path = get_path()
	get_tree().set_multiplayer(gateway_api, self.get_path())
	#set_custom_multiplayer(gateway_api)
	#custom_multiplayer.set_root_node(self)
	#custom_multiplayer.set_multiplayer_peer(network)
	print("GameserverHub started")
	
	network.connect("peer_connected",Callable(self,"_peer_connected"))
	network.connect("peer_disconnected",Callable(self,"_peer_disconnected"))
	
func _peer_connected(gameserver_id):
	print("Game Server " + str(gameserver_id) + " Connected")
	print("Currently hardcoding the gameserver dict to GameServer1")
	gameserver_dict["GameServer1"] = gameserver_id
	print("GameServers Dict = ", gameserver_dict)
	
func _peer_disconnected(gameserver_id):
	print("Game Server " + str(gameserver_id) + " Disconnected")
	
func distribute_login_token(token, gameserver):
	print(gameserver)
	var gameserver_peer_id = gameserver_dict[gameserver]
	print("Sending token to gameserver ", gameserver_peer_id)
	rpc_id(gameserver_peer_id, "receive_login_token", token)

################################################################################
#### Server functions
################################################################################
@rpc("any_peer")
func receive_login_token(token):
	pass
