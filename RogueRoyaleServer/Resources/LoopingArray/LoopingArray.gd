extends Resource
class_name LoopingArray

enum {POOL_BYTE_ARRAY, POOL_VECTOR_ARRAY, POOL_INT_ARRAY, AUDIO_PLAYER,
	AUDIO_PLAYER_2D, ARRAY}
var array
var size = 0
var index_to_write = 0
var head = 0
var debug_n_written = 0
var debug_n_read = 0
var cleanup = false

func init(type : int, new_size : int, default_value = 0) -> void:
	size = new_size
	if type == POOL_BYTE_ARRAY:
		array = PackedByteArray([])
		default_value = 0
	elif type == POOL_VECTOR_ARRAY:
		array = PackedVector2Array([])
		default_value = Vector2.ZERO
	elif type == POOL_INT_ARRAY:
		array = PackedInt32Array([])
		default_value = 0
	elif type == ARRAY:
		array = []
		default_value = default_value
	elif type == AUDIO_PLAYER:
		cleanup = true
		array = []
		for i in range(new_size):
			array.append(AudioStreamPlayer.new())
		return
	elif type == AUDIO_PLAYER_2D:
		array = []
		for i in range(size):
			array.append(AudioStreamPlayer2D.new())
	else:
		assert(false) #,"Invalid type")
	for _i in range(size):
		array.append(default_value)

func add_data(data) -> void:
	debug_n_written += 1
	array[index_to_write] = data
	index_to_write = (index_to_write + 1) % size
	assert(index_to_write != head)

func get_head():
	assert(head != index_to_write)
	debug_n_read += 1
	var data = array[head]
	head = (head + 1) % size
	return data

func get_last_entered_data():
	if index_to_write == 0:
		return array[-1]
	else:
		return array[index_to_write - 1]

func get_previous_index():
	if index_to_write == 0:
		return size - 1
	else:
		return index_to_write - 1

func is_buffered_data() -> bool:
	#print("Head ", head, " vs index ", index_to_write, " is_buffered = ", head != index_to_write)
	return head != index_to_write

func get_buffer_size():
	if head == index_to_write:
		return 0
	elif head < index_to_write:
		return index_to_write - head
	elif head > index_to_write:
		return size - head + index_to_write

func _exit_tree():
	if cleanup:
		for node in array:
			if is_instance_valid(node):
				node.queue_free()
