extends Node
class_name AudioStreamLoopingArray

var size = 32
var array = []
var head = 0
var index_to_write = 0
var debug_n_written = 0
var debug_n_read = 0

func _init():
	array = []
	for i in range(size):
		var new_player = AudioStreamPlayer.new()
		array.append(new_player)
		add_child(new_player)

func play_audio():
	while head != index_to_write:
		var audio_stream = get_head() as AudioStreamPlayer
		audio_stream.play()

func add_data(new_stream) -> void:
	debug_n_written += 1
	var player = array[index_to_write] as AudioStreamPlayer
	player.stream = new_stream
	player.volume_db = -12
	player.bus = "SFX"
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
