extends Node2D

var network = ENetMultiplayerPeer.new()
var gateway_api = SceneMultiplayer.new()
var port = 12345 
var max_players = 100

func _ready():
	start_gateway_server()

func _process(delta):
	if not gateway_api.has_multiplayer_peer():
		return
	gateway_api.poll() # THIS IS IMPORTANT!!
	
func start_gateway_server():
	network.create_server(port, max_players)
	gateway_api.multiplayer_peer = network
	gateway_api.root_path = get_path()
	print("Gateway server started")
	network.connect("peer_connected",Callable(self,"_peer_connected"))
	network.connect("peer_disconnected",Callable(self,"_peer_disconnected"))
	
func _peer_connected(player_id):
	print("User " + str(player_id) + " Connected")

func _peer_disconnected(player_id):
	print("User " + str(player_id) + " Disonnected")

@rpc("any_peer")
func login_request(username : String, password : String):
	print("Login request received!!!")
	var player_id = gateway_api.get_remote_sender_id()
