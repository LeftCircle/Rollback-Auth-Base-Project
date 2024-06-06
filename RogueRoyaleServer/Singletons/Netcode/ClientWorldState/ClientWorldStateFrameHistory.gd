extends RefCounted
class_name ClientWorldStateFrameHistory

const size = 60

var player_id : int
var history = []
var previous_retreived_frame : int = 0

func _init():
	for i in range(size):
		history.append(ClientWorldStateData.new())

func retrieve_world_state_frame(frame : int):
	var hist = history[frame % size]
	if hist.command_frame == frame:
		previous_retreived_frame = hist.world_state_frame
		return hist.world_state_frame
	else:
		# Make a guess
		Logging.log_line("Guessing world state frame is " + str(previous_retreived_frame + 1))
		previous_retreived_frame = CommandFrame.get_next_frame(previous_retreived_frame)
		return previous_retreived_frame

func retrieve_data(frame : int):
	var hist = history[frame % size]
	if hist.command_frame == frame:
		return hist
	else:
		var guessed_hist = ClientWorldStateData.new()
		guessed_hist.command_frame = frame
		guessed_hist.world_state_frame = previous_retreived_frame
		return guessed_hist

func add_data(command_frame : int, world_state_frame : int) -> void:
	var data = history[command_frame % size]
	data.command_frame = command_frame
	data.world_state_frame = world_state_frame
