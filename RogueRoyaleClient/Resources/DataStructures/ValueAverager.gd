extends RefCounted
class_name ValueAverager

const AVERAGE_AFTER : float = 10.0
const SIZE = int(AVERAGE_AFTER)

var network_id : int
#var latency_array = []
var average : float = 0
var head = 0
var sum : float = 0
var array = []

#var mutex = Mutex.new()

func _init():
	for i in range(SIZE):
		array.append(0)

func add_value(frame_latency : float) -> void:
	#mutex.lock()
	sum -= array[head]
	array[head] = frame_latency
	sum += frame_latency
	average = sum / AVERAGE_AFTER
	head = (head + 1) % SIZE
	#mutex.unlock()
	#mutex.unlock()
