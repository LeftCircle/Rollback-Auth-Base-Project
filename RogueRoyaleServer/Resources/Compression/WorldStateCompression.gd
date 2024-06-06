extends RefCounted
class_name WorldStateCompression

# The world state will be first added to a dictionary of class types and data, then converted
# to a single ByteArray

const bits_for_n_objects = 9
const bits_for_frame = 24
const bytes_for_n_bits = 2
const bytes_for_frame = 3
var class_dictionary = {}
var bits_in_byte_array = 0
var objects_per_class = {}
var bit_packer = OutputMemoryBitStream.new()

func reset():
	class_dictionary.clear()
	objects_per_class.clear()
	bits_in_byte_array = 0
	bit_packer.reset()

func add_data(netcode) -> void:
	if netcode.class_id in class_dictionary.keys():
		class_dictionary[netcode.class_id].append(netcode)
		objects_per_class[netcode.class_id] += 1
	else:
		class_dictionary[netcode.class_id] = [netcode]
		objects_per_class[netcode.class_id] = 1

func _add_data_depricated(class_id : String, compressed_data : Array) -> void:
	if class_id in class_dictionary.keys():
		class_dictionary[class_id] += compressed_data
		objects_per_class[class_id] += 1
	else:
		class_dictionary[class_id] = compressed_data
		objects_per_class[class_id] = 1
	bits_in_byte_array += compressed_data.size()

func create_array_to_send() -> Array:
	# [class_id, n_objects, object_data, class_id, n_objects, object_data, ....]
	# Start by sending the player data
	for class_id in class_dictionary.keys():
		compress_class_objects(class_id)
	# Flush the last word to memory
	bit_packer.flush_scratch_to_buffer()
	var byte_array = bit_packer.get_byte_array()
	byte_array += BaseCompression.compress_int_to_x_bytes(CommandFrame.frame, bytes_for_frame)
	byte_array += BaseCompression.compress_int_to_x_bytes(bit_packer.total_bits, bytes_for_n_bits)
	return byte_array

func compress_class_objects(class_id : String) -> void:
	bit_packer.compress_class_id(ObjectCreationRegistry.class_id_to_int_id[class_id])
	bit_packer.compress_int_into_x_bits(objects_per_class[class_id], bits_for_n_objects)
	Logging.log_line(str(objects_per_class[class_id]) + " objects for " + class_id)
	# Could step through and check to see if any of the instances are freed
	# Because we have to send the correct number of instances from this frame
	for netcode in class_dictionary[class_id]:
		netcode.write_compressed_data_to_stream(bit_packer)

# class_id, n_members, instance_id, data, ...
func _create_array_to_send_depricated() -> Array:
	var full_bit_array = []
	for class_id in class_dictionary.keys():
		var compressed_class_id = ObjectCreationRegistry.class_id_to_compressed_id[class_id]
		bits_in_byte_array += BaseCompression.n_class_id_bits
		var n_objects = objects_per_class[class_id]
		#print(n_objects, " for class id ", class_id)
		var compressed_n_objects = BaseCompression.compress_int_into_x_bits(n_objects, bits_for_n_objects)
		bits_in_byte_array += bits_for_n_objects
		full_bit_array += compressed_class_id
		full_bit_array += compressed_n_objects
		full_bit_array += class_dictionary[class_id]
	var byte_array = BaseCompression.bit_array_to_int_array(full_bit_array)
	var frame_bytes = BaseCompression.compress_frame_into_3_bytes(CommandFrame.frame)
	byte_array += frame_bytes
	# now append the total number of bits onto the end of the ByteArray
	# If this doesn't work, add them to the front
	var n_bit_array = BaseCompression.compress_int_into_x_bits(bits_in_byte_array, bytes_for_n_bits * 8)
	var n_bit_byte_array = BaseCompression.bit_array_to_int_array(n_bit_array)
	byte_array += n_bit_byte_array
	Logging.log_line("Byte array = " + str(byte_array))
	Logging.log_line("WorldState Array size = " + str(byte_array.size()))
	assert(byte_array.size() < 1450) #," Too much data in byte array. UDP packets must be less than 1500 bytes")
	return byte_array
