extends Node
class_name CommandLatencyTracker

var player_id : int = 0
var latency_array = []
var average_step_latency : float

func init(_player_id : int) -> void:
	player_id = _player_id

func _ready():
	build_step_latency_clock()

func build_step_latency_clock() -> void:
	var timer = Timer.new()
	timer.wait_time = 0.2
	timer.autostart = true
	timer.connect("timeout",Callable(self,"determine_latency"))
	self.add_child(timer)

func determine_latency():
	if player_id in multiplayer.get_peers():
		Server.get_player_command_step_latency(player_id)
	else:
		queue_free()

func receive_command_step_latency(client_command_step_n : int, old_server_command_step : int) -> void:
	latency_array.append(float(CommandFrame.get_command_frame_number() - old_server_command_step) / 2.0)
	if latency_array.size() == 9:
		average_step_latency = (average_size_9_array_values(latency_array))

func average_size_9_array_values(array_to_average : Array) -> float:
	var total_value = 0
	array_to_average.sort()
	var midpoint = array_to_average[4]
	for i in range(array_to_average.size() - 1, -1, -1):
		if array_to_average[i] > (3 * midpoint) and midpoint != 0:
			array_to_average.remove_at(i)
		else:
			total_value += array_to_average[i]
	var average_value = float(total_value) / float(array_to_average.size())
	array_to_average.clear()
	Logging.log_line("Average latency = " + str(average_value))
	#print("Average latency = " + str(average_value))
	return average_value

func queue_free_command_latency_tracker():
	call_deferred("queue_free")
