extends Node

var network = ENetMultiplayerPeer.new()
var auth_api = SceneMultiplayer.new()
var port = 28839 #1911 in tutorial
var max_servers = 5

func _ready():
	start_server()

func _process(_delta):
	if not auth_api.has_multiplayer_peer():
		return
	auth_api.poll()

func start_server():
	network.create_server(port, max_servers)
	if network.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		OS.alert("Failed to start ent server for authintication")
		assert(false)
	auth_api.multiplayer_peer = network
	auth_api.root_path = get_path()
	get_tree().set_multiplayer(auth_api, self.get_path()) # Not sure if this is a good idea?
	print("Authentication server started")
	network.connect("peer_connected",Callable(self,"_peer_connected"))
	network.connect("peer_disconnected",Callable(self,"_peer_disconnected"))
	
func _peer_connected(gateway_id):
	print("Gateway " + str(gateway_id) + " Connected")
	
func _peer_disconnected(gateway_id):
	print("Gateway " + str(gateway_id) + " Disconnected")

@rpc("any_peer")
func authenticate_player(username, password, player_id): 
	print("Authentication request received")
	var token : String
	var result : bool
	var hashed_password : String
	#var gateway_id = get_tree().get_remote_sender_id()
	var gateway_id = auth_api.get_remote_sender_id()
	print("Starting Authentication")
	if not PlayerData.player_ids.has(username):
		print("User not found")
		result = false
	else:
		var retrieved_salt = PlayerData.player_ids[username].Salt
		hashed_password = generate_hashed_password(password, retrieved_salt)
		if not PlayerData.player_ids[username].Password == hashed_password:
			print("Incorrect password")
			result = false
		else:
			print("Succesful password authentication!! Generating token")
			result = true
			randomize()
			token = str(randi()).sha256_text() + str(Time.get_unix_time_from_system())
			var gameserver = "GameServer1" # will be replaced with loadbalancer in the futre
			print("Gameserver1 declared when authenticating player")
			GameServers.distribute_login_token(token, gameserver)
	print("authentication result sent to gateway server")
	rpc_id(gateway_id, "authentication_results", result, player_id, token)

@rpc("any_peer")
func create_account(username : String, password : String, player_id):
	# message 1 = failed, 2 = username exists, 3 = success!
	print("Trying to create account for username %s" % [username])
	var gateway_id = auth_api.get_remote_sender_id()
	var result : bool
	var message : int
	if PlayerData.player_ids.has(username):
		result = false
		message = 2
		print("Failed, username already exists %s" % [username])
	else:
		result = true
		message = 3
		var salt = generate_salt()
		var hashed_password = generate_hashed_password(password, salt)
		PlayerData.player_ids[username] = {"Password" : hashed_password, "Salt" : salt}
		PlayerData.save_player_ids()
		print("Saved new login info for username: %s Password: %s" % [username, password])
	rpc_id(gateway_id, "create_account_results", result, player_id, message)

func generate_salt() -> String:
	randomize()
	var salt = str(randi()).sha256_text()
	return salt

func generate_hashed_password(password : String, salt) -> String:
	#print("Hash start = " + str(OS.get_system_time_msecs()))
	var hashed_password = password
	var rounds = 20 # = pow(2, 18) is a good but slow number 
	while rounds > 0:
		hashed_password = (hashed_password + salt).sha256_text()
		rounds -= 1
	#print("Hash end = " + str(OS.get_system_time_msecs()))
	return hashed_password

################################################################################
#### Gateway functions
################################################################################

@rpc("any_peer")
func authentication_results(result, player_id, token):
	pass

@rpc("any_peer")
func create_account_results(result : bool, player_id, message : int):
	pass
