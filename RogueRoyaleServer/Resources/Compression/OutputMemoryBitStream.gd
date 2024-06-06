extends RefCounted
class_name OutputMemoryBitStream

const WORD_SIZE = 32
const FOUR_BYTES = 65355
const WORD_SIZE_IN_BYTES = 4

var max_bytes = 1450 * 5

var mBuffer = []
# a 64 bit scratch so we can write to the buffer 32 bits (4 bytes, or one word) at a time
var scratch : int
var scratch_bits : int
var word_index : int = 0
var total_bits = 0
var read_bits = 0

func _init():
	_init_buffer()

func _init_buffer() -> void:
	mBuffer.resize(max_bytes)
	mBuffer.fill(0)

func reset():
	scratch = 0
	scratch_bits = 0
	total_bits = 0
	read_bits = 0
	word_index = 0

# The array MUST have the last x bytes be the total number of bits
func init_read(new_buffer : Array) -> void:
	var bytes_for_bits = new_buffer.slice(-BaseCompression.bytes_for_n_bits)
	total_bits = BaseCompression.decompress_byte_array_to_int(bytes_for_bits)
	gaffer_start_read(new_buffer, total_bits)

func gaffer_start_read(new_buffer : Array, bits_to_read : int) -> void:
	mBuffer = new_buffer
#	var size = mBuffer.size()
#	if size % WORD_SIZE != 0:
#		if size < WORD_SIZE:
#			var new_array = []
#			new_array.resize(WORD_SIZE - size)
#			new_array.fill(0)
#			mBuffer += new_array
#		else:
#			var new_array = []
#			new_array.resize(WORD_SIZE - (size % WORD_SIZE))
#			new_array.fill(0)
#			mBuffer += new_array
	scratch = 0
	scratch_bits = 0
	total_bits = bits_to_read
	read_bits = 0
	word_index = 0

func get_byte_array() -> Array:
	var word_index_to_grab
	if word_index < 2 * WORD_SIZE_IN_BYTES:
		word_index_to_grab = 2 * WORD_SIZE_IN_BYTES
	else:
		word_index_to_grab = word_index + (2 * WORD_SIZE_IN_BYTES) - (word_index % (2 * WORD_SIZE_IN_BYTES))
	return mBuffer.slice(0, (4 * word_index_to_grab))

func compress_int_into_x_bits(inData : int, inBitCount : int, is_signed = false) -> void:
	if is_signed:
		var is_negative = 1 if inData < 0 else 0
		gaffer_write_int(is_negative, 1)
		gaffer_write_int(abs(inData), inBitCount - 1)
	else:
		assert(inData >= 0) #," Cannot pass negative data without sign!")
		gaffer_write_int(inData, inBitCount)

func compress_int_array(int_array : Array, is_signed = false) -> void:
	var n_elements = int_array.size()
	variable_compress(n_elements)
	for i in range(n_elements):
		variable_compress(int_array[i], is_signed)

func decompress_int_array(is_signed = false) -> Array:
	var n_elements = variable_decompress(TYPE_INT)
	var int_array = []
	for i in range(n_elements):
		int_array.append(variable_decompress(TYPE_INT, is_signed))
	return int_array

func variable_compress(value, signed = false):
	var n_bits : int
	if typeof(value) == TYPE_INT:
		n_bits = BaseCompression.n_bits_for_int(value, signed)
		compress_int_into_x_bits(n_bits, BaseCompression.variable_compress_bits_for_size)
		compress_int_into_x_bits(value, n_bits, signed)
	elif typeof(value) == TYPE_VECTOR2:
		n_bits = BaseCompression.n_bits_for_vector(value, signed)
		compress_int_into_x_bits(n_bits / 2, BaseCompression.variable_compress_bits_for_size)
		compress_vector_into_x_bits(value, n_bits, signed)
	elif typeof(value) == TYPE_FLOAT:
		n_bits = BaseCompression.n_bits_for_float(value, signed)
		compress_int_into_x_bits(n_bits, BaseCompression.variable_compress_bits_for_size)
		compress_float_into_x_bits(value, n_bits, signed)
	else:
		assert(false) #,"variable compression does not support type for " + str(value))

func variable_decompress(type : int, signed = false):
	var n_bits = decompress_int(BaseCompression.variable_compress_bits_for_size)
	if type == TYPE_INT:
		return decompress_int(n_bits, signed)
	elif type == TYPE_VECTOR2:
		return decompress_vector(n_bits, signed)
	elif type == TYPE_FLOAT:
		return decompress_float(n_bits, signed)
	else:
		assert(false) #,"variable decompression does not support type for " + str(type))

func compress_vector_into_x_bits(vec : Vector2, n_bits : int, signed = false):
	assert(n_bits % 2 == 0)
	var bits_per_component = n_bits / 2
	var x_int = int(round(vec.x))
	var y_int = int(round(vec.y))
	compress_int_into_x_bits(x_int, bits_per_component, signed)
	compress_int_into_x_bits(y_int, bits_per_component, signed)

func compress_float_into_x_bits(in_float : float, n_bits : int, signed = false, n_decimals = 3):
	var float_to_int = int(round(in_float * pow(10.0, n_decimals)))
	compress_int_into_x_bits(float_to_int, n_bits, signed)

func decompress_int(inBitCount : int, is_signed = false) -> int:
	if is_signed:
		var neg_mod = -1 if gaffer_read(1) == 1 else 1
		var abs_val = gaffer_read(inBitCount - 1)
		return neg_mod * abs_val
	else:
		return gaffer_read(inBitCount)

func decompress_vector(bits_per_component : int, signed = false) -> Vector2:
	var x = decompress_int(bits_per_component, signed)
	var y = decompress_int(bits_per_component, signed)
	return Vector2(x, y)

func decompress_float(inBitCount : int, signed = false, n_decimals = 3) -> float:
	var float_as_int = decompress_int(inBitCount, signed)
	return float(float_as_int) / pow(10.0, n_decimals)

func compress_bool(bool_var : bool) -> void:
	gaffer_write_int(int(bool_var), 1)

func decompress_bool() -> bool:
	return bool(gaffer_read(1))

func compress_timer_data(timer_data : TimerData) -> void:
	variable_compress(timer_data.wait_frames)
	variable_compress(timer_data.current_frames)
	compress_bool(timer_data.is_running)
	compress_bool(timer_data.autostart)

func decompress_timer_data_into(timer_data : TimerData) -> void:
	timer_data.wait_frames = variable_decompress(TYPE_INT)
	timer_data.current_frames = variable_decompress(TYPE_INT)
	timer_data.is_running = decompress_bool()
	timer_data.autostart = decompress_bool()

func compress_unit_vector(invec : Vector2) -> void:
	compress_float_into_x_bits(invec.x, BaseCompression.unit_vector_float_bits, true)
	compress_float_into_x_bits(invec.y, BaseCompression.unit_vector_float_bits, true)

func decompress_unit_vector():
	var x = decompress_float(BaseCompression.unit_vector_float_bits, true)
	var y = decompress_float(BaseCompression.unit_vector_float_bits, true)
	return Vector2(x, y)

func compress_quantized_input_vec(input_vec : Vector2) -> void:
	var quantized_length = InputVecQuantizer.get_quantized_length(input_vec)
	var quantized_degrees = InputVecQuantizer.get_quantized_angle(input_vec)
	compress_int_into_x_bits(quantized_length, InputVecQuantizer.BITS_FOR_LENGTH)
	compress_int_into_x_bits(quantized_degrees, InputVecQuantizer.BITS_FOR_DEGREES)

func decompress_quantized_input_vec() -> Vector2:
	var quantized_length = gaffer_read(InputVecQuantizer.BITS_FOR_LENGTH)
	var quantized_degrees = gaffer_read(InputVecQuantizer.BITS_FOR_DEGREES)
	return InputVecQuantizer.quantized_len_and_deg_to_vector(quantized_length, quantized_degrees)

# TO DO -> optimize this so we don't have to find the required bits each time
func compress_enum(enum_value : int, n_enums : int):
	var required_bits = BaseCompression.n_bits_for_int(n_enums)
	compress_int_into_x_bits(enum_value, required_bits)

func compress_class_instance(instance_id : int) -> void:
	gaffer_write_int(instance_id, BaseCompression.n_class_instance_bits)

func gaffer_write_int(inData : int, inBitCount : int) -> void:
	if inBitCount > 32:
		assert(false) #," We must handle the case of writing values greater than 32 bits")
	if scratch_bits + inBitCount > 64:
		assert(false) #,"We must handle writing more than 32 bits to a nearly full scratch")
	# Shift the data to the left to insert it into the end of the scratch
	# Data is inserted from right to left
	var bits_to_write = inData << scratch_bits
	scratch = scratch | bits_to_write
	scratch_bits += inBitCount
	if scratch_bits >= WORD_SIZE:
		# Flush the word to memory!
		write_word_to_buffer(scratch)
		scratch_bits = scratch_bits - WORD_SIZE
		scratch = scratch >> WORD_SIZE
	total_bits += inBitCount

func write_word_to_buffer(word : int) -> void:
	# The word is packed in big Endian order
	# Data is inserted into the buffer from right to left
	var data_to_mem = word & 0xffffffff
	var byte_index = 4 * word_index
	mBuffer[byte_index] = data_to_mem & 0xff
	mBuffer[byte_index + 1] = data_to_mem >> 8 & 0xff
	mBuffer[byte_index + 2] = data_to_mem >> 16 & 0xff
	mBuffer[byte_index + 3] = data_to_mem >> 24 & 0xff
	word_index += 1

func flush_scratch_to_buffer():
	if scratch_bits != 0 or mBuffer.size() % 4 != 0:
		assert(scratch_bits <= WORD_SIZE) #,"somehow the scratch is larger than one word")
		#scratch = byteswap_word(scratch)
		write_word_to_buffer(scratch)

# Flushes the remaining data to memory and adds the number of bits as the last x bytes
func get_array_to_send() -> Array:
	flush_scratch_to_buffer()
	# Add the total bits at the end
	var byte_array = get_byte_array()
	byte_array += BaseCompression.compress_int_to_x_bytes(total_bits, BaseCompression.bytes_for_n_bits)
	return byte_array

func read_word() -> void:
	var word = 0
	var buffer_index = word_index * 4
	word = word | mBuffer[buffer_index]
	word = word | (mBuffer[buffer_index + 1] << 8)
	word = word | (mBuffer[buffer_index + 2] << 16)
	word = word | (mBuffer[buffer_index + 3] << 24)
	word = word << scratch_bits
	scratch = word | scratch
	scratch_bits += WORD_SIZE
	word_index += 1

func gaffer_read(x_bits : int) -> int:
	if scratch_bits < x_bits:
		read_word()
	var val = scratch & ((1 << x_bits) - 1)
	scratch = scratch >> x_bits
	scratch_bits -= x_bits
	read_bits += x_bits
	return val

func byteswap_word(inData):
	inData = inData & 0xffffffff
	return (((inData >> 24) & 0xff) |
		((inData >> 8) & 0xff00) |
		((inData << 8) & 0xff0000) |
		((inData << 24) & 0xff000000))

func compress_class_id(class_id : int) -> void:
	assert(class_id <= 878500) #,"id is greater than the max cantor of 'ZZZ'")
	gaffer_write_int(class_id, BaseCompression.n_class_id_bits)

func compress_class_str_id(class_id : String) -> void:
	var int_id = ObjectCreationRegistry.class_id_to_int_id[class_id]
	gaffer_write_int(int_id, BaseCompression.n_class_id_bits)

func decompress_class_id() -> int:
	return gaffer_read(BaseCompression.n_class_id_bits)

func compress_frame(frame : int) -> void:
	gaffer_write_int(frame, BaseCompression.frame_bits)

func decompress_frame() -> int:
	return gaffer_read(BaseCompression.frame_bits)

func is_finished() -> bool:
	assert(read_bits <= total_bits) #,"assert_debug")
	return read_bits == total_bits
