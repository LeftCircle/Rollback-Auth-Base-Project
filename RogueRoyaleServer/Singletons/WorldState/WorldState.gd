extends PackageBuilder


var world_state_data = WorldStateData.new()
var previous_command_step : int = -1
var physics_frames = 0

func _ready():
	set_physics_process(false)

func start_sending_world_state():
	set_physics_process(true)

func _physics_process(delta):
	_compress_netcode_objects()
	_send_all_world_states()
	_reset()

func _send_all_world_states():
	for client_id in packets_to_players.keys():
		var comp_world_state = packets_to_players[client_id].create_array_to_send()
		Server.send_world_state(client_id, comp_world_state)
		packets_to_players[client_id].reset()

