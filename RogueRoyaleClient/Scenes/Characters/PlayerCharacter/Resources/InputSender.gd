extends Resource
class_name InputSender

# Stores a looping array of inputs that can be sent to and interpreted by the server.
const MAX_FRAME_DIFF = 50
var history_size : int = 255
var frames_to_send = 10
# [{frame_n : action_data}, ...]
var array_to_server = []
var compression_functions = ActionFromClientCompression.new()

func init(new_size : int) -> void:
	history_size = new_size
	for i in range(new_size):
		array_to_server.append([])

func add_action_to_send(frame : int, actions : ActionFromClient) -> void:
	var server_data = compression_functions.compress_action_history(frame, actions)
	array_to_server[frame % history_size] = server_data

func get_sliding_buffer_to_send(last_frame_acknowledged, current_frame) -> Array:
	if last_frame_acknowledged > current_frame:
		Logging.log_line("Last frame greater than current? ")
	var frame_diff = CommandFrame.frame_difference(current_frame, last_frame_acknowledged)
	if frame_diff >= MAX_FRAME_DIFF:
		print("max frame diff last ack = ", last_frame_acknowledged, " current = ", current_frame)
		last_frame_acknowledged = CommandFrame.get_previous_frame(current_frame, MAX_FRAME_DIFF)
	#var last_frame_index = last_frame_acknowledged % history_size
	#var current_frame_index = current_frame % history_size
	#var array_to_send = slice_array(array_to_server, last_frame_index, current_frame_index)
	# Sending the data in order so the server knows the most recent
	var array_to_send = []
	for i in range(last_frame_acknowledged, current_frame + 1):
		array_to_send.append(array_to_server[i % history_size])
	Logging.log_line("Array to send for frames " + str(last_frame_acknowledged) + " through " + str(current_frame))
	return array_to_send

func send_sliding_buffer(last_frame_acknowledged : int, current_frame : int) -> void:
	var array_to_send = get_sliding_buffer_to_send(last_frame_acknowledged, current_frame)
	# A quick way to slap the frame on there with no compression or anything
	array_to_send.append(last_frame_acknowledged)
	Logging.log_line(str(array_to_send))
	Server.send_player_inputs_unreliable(array_to_send)

func slice_array(array, start, stop):
	var result = []
	if stop < start or (start < 0 and stop >= 0):
		result = array.slice(start)
		result.append_array(array.slice(0, stop + 1))
	else:
		result = array.slice(start, stop + 1)
	return result
