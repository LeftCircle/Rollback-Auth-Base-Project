extends Node
#class_name PlayerSyncController
# This dictates if a client should speed up or slow down processing to stay
# as close to the server as possible and to handle ping fluctuations

enum {FAST, SLOW, NORMAL, DOUBLE_FAST, HALF_SPEED}
const ADJUST_EVERY_X_FRAMES = 5
#const MINIMUM_BUFFER = 2.75

var NORMAL_ITERATIONS = int(ProjectSettings.get_setting("physics/common/physics_ticks_per_second"))
var FAST_ITERATIONS = NORMAL_ITERATIONS + 5
var SLOW_ITERATIONS = NORMAL_ITERATIONS - 5
var DOUBLE_FAST_ITERATIONS = 2 * NORMAL_ITERATIONS
var DOUBLE_SLOW_ITERATIONS = NORMAL_ITERATIONS / 2
var SLOW_OVER_FAST = float(SLOW_ITERATIONS) / float(FAST_ITERATIONS)
var BUFFER_DENOM = float(NORMAL_ITERATIONS) * (1.0 / float(SLOW_ITERATIONS) - 1.0 / float(NORMAL_ITERATIONS))

var iteration_speed = {}
var client_ahead_by = {}
var client_buffer_ranges = {}
var frames_since_adjust = 0
var adjusting_process_speeds = false
var reset_counter = false
#var stable_buffer_size = 4
var stable_buffer_finder = StableBufferFinder.new()

func _init():
	Server.connect("player_connected",Callable(self,"_on_player_connect"))
	Server.connect("player_disconnected",Callable(self,"_on_player_disconnect"))

func _ready():
	_build_max_latency_timer()

func _physics_process(delta):
	if reset_counter:
		frames_since_adjust = 0
		reset_counter = false
	frames_since_adjust += 1

func adjust_processing_speeds(player_id : int):
	if adjusting_process_speeds and frames_since_adjust >= ADJUST_EVERY_X_FRAMES:
		var average_buffer : float = InputProcessing.get_average_buffer(player_id)
		var stable_buffer : float = stable_buffer_finder.get_stable_buffer(player_id)
		Logging.log_line("Average buffer = " + str(average_buffer) + " vs stable of: " + str(stable_buffer))
		#print("Average buffer = ", average_buffer)
		adjust_client_with_input_buffer(player_id, average_buffer, stable_buffer)
		reset_counter = true

func _on_player_connect(network_id : int) -> void:
	iteration_speed[network_id] = NORMAL
	client_ahead_by[network_id] = 0
	client_buffer_ranges[network_id] = ClientBufferRanges.new()
	stable_buffer_finder.track_player(network_id)

func _on_player_disconnect(network_id : int) -> void:
	iteration_speed.erase(network_id)
	client_ahead_by.erase(network_id)
	stable_buffer_finder.stop_tracking(network_id)

func adjust_client(network_id : int, c_ahead_by : float, half_rtt : float):
	client_ahead_by[network_id] = c_ahead_by
	var buffer_ranges = client_buffer_ranges[network_id]
	buffer_ranges.set_buffer_ranges(half_rtt)
	Logging.log_line("Client is ahead by " + str(c_ahead_by) + " vs too_close " + str(buffer_ranges.too_close) + " vs too far " + str(buffer_ranges.too_far))
	if c_ahead_by > buffer_ranges.too_close and c_ahead_by < buffer_ranges.too_far:
		_run_at_normal_speed(network_id)
	elif c_ahead_by < 0:
		#print("Doubling ", network_id)
		double_client_speed(network_id)
	elif c_ahead_by < buffer_ranges.too_close:
		_speed_up(network_id)
	elif c_ahead_by > buffer_ranges.way_too_far:
		_half_speed(network_id)
	elif c_ahead_by > buffer_ranges.too_far:
		_slow_down(network_id)

func adjust_client_with_input_buffer(network_id : int, input_buffer_size : float, stable_buffer : float) -> void:
	if input_buffer_size < stable_buffer:
		_speed_up(network_id)
	elif input_buffer_size > stable_buffer + StableBufferFinder.MAX_AHEAD_OF_STABLE:
		slow_down_buffer_to_stable(network_id, input_buffer_size, stable_buffer)

func slow_down_buffer_to_stable(network_id : int, input_buffer_size : float, stable_buffer : float) -> void:
	Logging.log_line("Iteration speed of " + str(network_id) + " = " + str(iteration_speed[network_id]))
	if iteration_speed[network_id] != SLOW:
		var slow_frames = input_buffer_size - stable_buffer # - 1 ?
		if slow_frames <= 0:
			return
		Logging.log_line("Buffer = " + str(input_buffer_size) + " slowing " + str(slow_frames))
		var n_slow_frames = int(round((slow_frames) / BUFFER_DENOM))
		Logging.log_line("Slowing down " + str(network_id) + " for " + str(n_slow_frames) + " frames")
		Logging.log_line("Sending slow_down to " + str(network_id))
		Logging.log_line("Should slow client down for " + str(slow_frames / float(NORMAL_ITERATIONS)) + "seconds")
		Server.send_iteration_change(network_id, SLOW, n_slow_frames)
		iteration_speed[network_id] = SLOW


func adjust_client_buffer_ranges(network_id : int) -> void:
	var half_rtt = Server.ping_tracker.get_half_rtt(network_id)
	var buffer_ranges = client_buffer_ranges[network_id]
	buffer_ranges.set_buffer_ranges(half_rtt)

func adjust_client_from_input_frame(network_id : int, input_frame : int) -> void:
	var c_ahead_by = CommandFrame.frame_difference(input_frame, CommandFrame.frame)
	var buffer_ranges = client_buffer_ranges[network_id]
	if c_ahead_by > buffer_ranges.too_close and c_ahead_by < buffer_ranges.too_far:
		_run_at_normal_speed(network_id)
	elif c_ahead_by < 0:
		#print("Doubling ", network_id)
		double_client_speed(network_id)
	elif c_ahead_by < buffer_ranges.too_close:
		_speed_up(network_id)
	elif c_ahead_by > buffer_ranges.way_too_far:
		_half_speed(network_id)
	elif c_ahead_by > buffer_ranges.too_far:
		_slow_down(network_id)

func _run_at_normal_speed(network_id) -> void:
	if iteration_speed[network_id] != NORMAL:
		Server.send_iteration_change(network_id, NORMAL)
		iteration_speed[network_id] = NORMAL

func _speed_up(network_id) -> void:
	if adjusting_process_speeds:
		Logging.log_line("Sending speed up to " + str(network_id))
		Server.send_iteration_change(network_id, FAST)
		iteration_speed[network_id] = FAST

func _slow_down(network_id) -> void:
	Logging.log_line("Sending slow_down to " + str(network_id))
	Server.send_iteration_change(network_id, SLOW)
	iteration_speed[network_id] = SLOW

func _half_speed(network_id) -> void:
	Logging.log_line("Sending half_speed to " + str(network_id))
	Server.send_iteration_change(network_id, HALF_SPEED)
	iteration_speed[network_id] = HALF_SPEED

func double_client_speed(network_id : int) -> void:
	Logging.log_line("Sending double_speed to " + str(network_id))
	Server.send_iteration_change(network_id, DOUBLE_FAST)
	iteration_speed[network_id] = DOUBLE_FAST
	#print("SENDING DOUBLE FAST!!")

func client_is_at_normal_iterations(player_id : int) -> void:
	iteration_speed[player_id] = NORMAL
	Logging.log_line(str(player_id) + " sent that they are now at normal iterations")

func _build_max_latency_timer():
	var timer = Timer.new()
	timer.wait_time = 60.0
	timer.autostart = true
	timer.set_name("MaxLatencyTimer")
	timer.connect("timeout",Callable(self,"_on_MaxLatencyTimer_timeout"))
	add_child(timer, true)

func _on_MaxLatencyTimer_timeout():
	LatencyTracker.get_max_average_latency()
