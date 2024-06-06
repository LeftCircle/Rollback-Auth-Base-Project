extends Node2D


var network = ENetMultiplayerPeer.new()
var gateway_api = SceneMultiplayer.new()
var ip = "127.0.0.1"
# MUST match the port on the gateway server
var port = 12345

var username : String
var password : String

func _ready():
	connect_to_server("asdf", "asdfasdf")

func _physics_process(_delta):
	if not gateway_api.has_multiplayer_peer():
		return
	if Input.is_action_just_pressed("ui_accept"):
		request_login()
	gateway_api.poll()

func connect_to_server(_username : String, _password : String):
	username = _username
	password = _password.sha256_text()
	network.create_client(ip, port)
	gateway_api.multiplayer_peer = network
	gateway_api.root_path = get_path() # This wasn't here when it worked??
	gateway_api.connection_failed.connect(self._on_connection_failed)
	gateway_api.connected_to_server.connect(self._on_connection_succeeded)

func _on_connection_failed():
	print("Failed to connect")

func _on_connection_succeeded():
	print("Successfully connected")
	print("Connected peers are ", gateway_api.get_peers())
	request_login()

func request_login():
	print("requesting login")
	#gateway_api.rpc(1, ".", "login_request", [username, password])
	rpc_id(1, "login_request", username, password)

@rpc("any_peer")
func login_request(username : String, password : String):
	pass
