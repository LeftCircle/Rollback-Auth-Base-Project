extends RefCounted
class_name SlidingValueAverager

const AVERAGE_AFTER : float = 60.0
const SIZE = int(AVERAGE_AFTER)

var network_id : int
#var latency_array = []
var average : float = 0
var head = 0
var sum : float = 0
var array : Array[float] = []

#var mutex = Mutex.new()

func _init():
	for i in range(SIZE):
		array.append(0)

func add_value(value : float) -> void:
	#mutex.lock()
	sum -= array[head]
	array[head] = value
	sum += value
	average = sum / AVERAGE_AFTER
	head = (head + 1) % SIZE
	#mutex.unlock()
