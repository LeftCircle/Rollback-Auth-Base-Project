extends Resource
class_name OrderedRingBuffer
# This is similar to a ring buffer, but each index must occur sequentially. 
# The primary use case for this is for receiving potentially out of order 
# command frames, or storing and retreiving command frames in order. This
# method confirms that we do not skip any command frames, since the head will 
# always keep track of the last pulled command frame

var buffer_size : int = 1024
var buffer : Array = []
# Head is the oldest -> where data is read from
var head : int = 0

func init(new_size = buffer_size):
	buffer_size = new_size
	for _i in range(buffer_size):
		buffer.append(null)

func init_with_buffer(new_buffer) -> void:
	buffer = new_buffer
	buffer_size = buffer.size()
	head = 0

func add(data, position : int) -> void:
	buffer[position % buffer_size] = data

func get_unused_data_including(frame : int ) -> Array:
	var position = frame % buffer_size
	var data = []
	if position < head or (position < 0 and head >= 0):
		data.append_array(buffer.slice(head, buffer_size + 1))
		data.append_array(buffer.slice(0, position + 1))
	else:
		data.append_array(buffer.slice(head, position + 1))
	head = (position + 1) % buffer_size
	return data
