extends Resource
class_name BaseModularHistory

const NO_ROLLBACK_FRAME = INF
const NO_DATA_FOR_FRAME = null

var size = 60
var history : Array[RefCounted] = []

func _init():
	history.resize(size)

func add_data(frame : int, with_node) -> void:
	var data = retrieve_data(frame)
	if data == NO_DATA_FOR_FRAME:
		data = _new_data_container()
		history[frame % size] = data
	data.set_data_with_obj(with_node)
	data.frame = frame

func _new_data_container():
	assert(false) #,"must be overwritten with the data container for the history")

func retrieve_data(frame : int):
	var data = history[frame % size]
	if not is_instance_valid(data) or data.frame != frame:
		return NO_DATA_FOR_FRAME
	return data

func retrieve_data_at_pos(frame : int):
	var data = history[frame % size]
	if not is_instance_valid(data):
		data = _new_data_container()
		history[frame % size] = data
		data.frame = frame
	return data

func server_matches_history(server_hist) -> bool:
	var old_data = retrieve_data(server_hist.frame)
	if old_data == NO_DATA_FOR_FRAME:
		Logging.log_line("Does not match because no data for frame %s. Server hist: " % [server_hist.frame])
		#history[server_hist.frame % size].set_data_with_obj(server_hist)
		Logging.log_object_vars(server_hist)
		add_data(server_hist.frame, server_hist)
		return false
	var matches = old_data.matches(server_hist)
	if not matches:
		Logging.log_line("Missmatch in data for server frame " + str(server_hist.frame))
		Logging.log_line("Server:")
		Logging.log_object_vars(server_hist)
		Logging.log_line("Client:")
		Logging.log_object_vars(old_data)
		old_data.set_data_with_obj(server_hist)
		return false
	return true
