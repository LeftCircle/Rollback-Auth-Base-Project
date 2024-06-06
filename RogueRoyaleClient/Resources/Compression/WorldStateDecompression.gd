extends RefCounted
class_name WorldStateDecompression
# The world state decompression is decoupled from the compression
# because the client decompression calls some functions the server should
# never have.
signal done_processing()

const bits_for_n_objects = 9
const bits_for_frame = 24
const bytes_for_n_bits = 2
const bytes_for_frame = 3
var class_dictionary = {}
var bits_in_byte_array = 0
var objects_per_class = {}
var bit_array_reader = BitArrayReader.new()
var head = 0
var bit_packer = OutputMemoryBitStream.new()

func decompress_world_state(world_state : WorldStateData) -> void:
	var n_bits = get_n_bits(world_state.compressed_data)
	bit_packer.gaffer_start_read(world_state.compressed_data, n_bits)
	_process_bit_array(world_state.frame)

#func __decompress_world_state_depricated(world_state : Array) -> void:
#	Logging.log_line("WorldState size = " + str(world_state.size()))
#	var array_size = world_state.size()
#	var n_bits = _get_n_bits(world_state, array_size)
#	var frame = get_frame(world_state)
#	var bit_array = _get_bit_array(world_state, array_size, n_bits)
#	if n_bits > 0:
#		# Now we have to read through each bit array to see if there is an existing class memeber
#		_process_bit_array(frame, bit_array)

static func get_n_bits(world_state : Array) -> int:
	var array_size = world_state.size()
	var n_bits_start_index = array_size - bytes_for_n_bits
	var byte_array_for_n_bits = world_state.slice(n_bits_start_index)
	var n_bits = BaseCompression.decompress_byte_array_to_int(byte_array_for_n_bits)
	return n_bits

static func get_frame(world_state : Array) -> int:
	var array_size = world_state.size()
	var frame_start_index = array_size - bytes_for_n_bits - bytes_for_frame
	var frame_end_index = array_size - bytes_for_n_bits - 1
	var frame_bytes = world_state.slice(frame_start_index, frame_end_index + 1)
	var frame = BaseCompression.decompress_byte_array_to_int(frame_bytes)
	return frame

func _get_bit_array(world_state : Array, array_size : int, n_bits : int) -> Array:
	var data_ends = array_size - bytes_for_frame - bytes_for_n_bits - 1
	var data_bytes = world_state.slice(0, data_ends + 1)
	return BaseCompression.byte_array_to_bit_array(data_bytes, n_bits)

func _process_bit_array(frame : int):
	while !bit_packer.is_finished():
		var class_id : int = bit_packer.decompress_class_id()
		var n_objects : int = bit_packer.decompress_int(bits_for_n_objects)
		for i in range(n_objects):
			var entity = ObjectsInScene.find_and_decompress(frame, class_id, bit_packer)
	emit_signal("done_processing")

func _process_bit_array_depricated(frame : int, bit_array : Array):
	# Start by figuring out what class we have
	#Logging.log_line("Full bit array for frame " + str(frame))
	#Logging.log_line(str(bit_array))
	bit_array_reader.set_bit_array(bit_array)
	while !bit_array_reader.is_finished():
		var class_id_bits = bit_array_reader.get_x_bits(BaseCompression.n_class_id_bits)
		var class_id = BaseCompression.decompress_class_id(class_id_bits)
		#Logging.log_line("Decompressed class id = " + str(ObjectCreationRegistry.int_id_to_str_id[class_id]))
		var n_objects_bits = bit_array_reader.get_x_bits(bits_for_n_objects)
		var n_objects = BaseCompression.bit_array_to_int(n_objects_bits)
		Logging.log_line("N objects = " + str(n_objects))
		for i in range(n_objects):
			var class_instance_id_bits = bit_array_reader.get_x_bits(BaseCompression.n_class_instance_bits)
			var class_instance_id = BaseCompression.bit_array_to_int(class_instance_id_bits)
			var entity = ObjectCreationRegistry.find_and_queue_spawn_if_needed(frame, class_id, class_instance_id)
			entity.decompress(frame, bit_array_reader)


func slice(array : Array, size_of_slice) -> Array:
	assert(head + size_of_slice <= array.size()) #,"Slice is too large")
	var result = array.slice(head, head + size_of_slice)
	head += size_of_slice
	return result

