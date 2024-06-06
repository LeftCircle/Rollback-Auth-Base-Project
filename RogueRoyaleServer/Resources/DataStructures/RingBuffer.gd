extends Resource
class_name RingBuffer

var buffer_size : int = 1024
var buffer : Array = []
# Head is the oldest -> where data is read from
var head : int = 0
# Tail is the newest -> where data is written to. DATA DOES NOT YET EXIST AT THE TAIL
var tail : int = 0

func init(new_size = buffer_size):
	buffer_size = new_size
	for _i in range(buffer_size):
		buffer.append(null)

func add(data) -> void:
	assert((tail + 1) % buffer_size != head)
	buffer[tail] = data
	tail = (tail + 1) % buffer_size

func get_all_data() -> Array:
	var data = buffer.slice(head, tail + 1, 1, true)
	head = tail
	return data
