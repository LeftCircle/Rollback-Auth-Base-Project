extends Resource
class_name WorldStateData

var frame : int = -1
# {class_id : {class_instance_id : data}, ... }
var data = {}


func reset_world_state_data():
	data = {}
	frame = 0

func add_data(state_data) -> void:
	if is_instance_valid(state_data.entity):
		Logging.log_line("Adding data to be saved")
		# These calls to get to the class id and instance id are kind of awful
		var class_id = state_data.entity.netcode.class_id
		var class_instance_id = state_data.entity.netcode.class_instance_id
		if class_id in data.keys():
			data[class_id][class_instance_id] = state_data
		else:
			data[class_id] = {}
			data[class_id][class_instance_id] = state_data

func get_state(class_id : String, class_instance : int):
	if class_id in data.keys():
		if class_instance in data[class_id].keys():
			return data[class_id][class_instance]
	Logging.log_line("State data does not exist for class " + class_id + " instance " + str(class_instance) + " for frame " + str(frame))
	return null

#func duplicate_state_deep(world_state : WorldStateData) -> void:
#	Logging.log_line("Duplicating state " + str(world_state.data))
#	data = world_state.data.duplicate(true)
#	frame = world_state.frame

func set_frame(new_frame : int) -> void:
	frame = new_frame

func get_frame():
	return frame

#func get_player_state(serialized_id : int) -> PlayerState:
#	if not serialized_id in players.keys():
#		var new_state = PlayerState.new()
#		players[serialized_id] = new_state
#	return players[serialized_id]

#func log_world_state():
#	Logging.log_line("World State for frame " + str(frame))
#	Logging.log_line("Players: ")
#	for player_id in players.keys():
#		Logging.log_line("Player " + str(player_id))
#		players[player_id].log_state()


