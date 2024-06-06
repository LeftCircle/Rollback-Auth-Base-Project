extends Resource
class_name BaseCompression

# A base class for anything compression related
const n_class_id_bits = 20
const n_class_instance_bits = 16
const variable_compress_bits_for_size = 5
const frame_bits = 24
const variable_compress_floating_point_precision = 3
const unit_vector_float_bits = 11
const n_bits_for_float_between_zero_and_one = 10
const n_decimals_for_float_between_zero_and_one = 3
const BYTES_FOR_FRAME = 3
const N_BITS_FOR_ANIM_FRAME = 8
const bytes_for_n_bits = 2
const starting_bits_for_n_bits_for_int = 10

var bit_array_reader = BitArrayReader.new()

# A function to be overridden by child classes # May not need to be used???
func compress_state(instance_id : int, state):
	pass

# Returns a big endian array of bits
static func compress_int_into_x_bits(in_int : int, n_bits : int, signed = false) -> Array:
	var number_bits = n_bits - 1 if signed else n_bits
	var binary = (1 << number_bits) - 1
	assert(abs(in_int) <= binary)
	var result = []
	if signed:
		var is_negative = 1 if in_int < 0 else 0
		result.append(is_negative)
	in_int = abs(in_int)
	for i in range(1, number_bits + 1):
		var bit = 1 if (1 << (number_bits - i)) & in_int != 0 else 0
		result.append(bit)
	return result

static func decompress_int_from_bits(array_of_bits : Array, signed = false) -> int:
	var result = 0
	if signed:
		var n_bits = array_of_bits.size()
		for i in range(1, n_bits):
			result = (result << 1) | array_of_bits[i]
		result = -result if array_of_bits[0] == 1 else result
	else:
		for bit in array_of_bits:
			result = (result << 1) | bit
	return result

static func decompress_int_from_x_bits(bit_reader : BitArrayReader, x_bits : int, signed = false) -> int:
	var bit_array = bit_reader.get_x_bits(x_bits)
	return decompress_int_from_bits(bit_array, signed)

static func compress_float_into_x_bits(in_float : float, n_bits : int, signed = false, n_decimals = 3) -> Array:
	var float_to_int = int(round(in_float * pow(10.0, n_decimals)))
	return compress_int_into_x_bits(float_to_int, n_bits, signed)

static func decompress_float_from_bits(array_of_bits : Array, signed = false, n_decimals = 3) -> float:
	var decomp_int = decompress_int_from_bits(array_of_bits, signed)
	return float(decomp_int) / pow(10.0, n_decimals)

static func compress_vector_into_x_bits(vec : Vector2, n_bits : int, signed = false) -> Array:
	assert(n_bits % 2 == 0)
	var bits_per_component = n_bits / 2
	var x_int = int(round(vec.x))
	var y_int = int(round(vec.y))
	var x_bit_array = compress_int_into_x_bits(x_int, bits_per_component, signed)
	var y_bit_array = compress_int_into_x_bits(y_int, bits_per_component, signed)
	var result = []
	result.append_array(x_bit_array)
	result.append_array(y_bit_array)
	return result

static func decompress_vector(in_bits : Array, signed = false) -> Vector2:
	var bits_per_component = in_bits.size() / 2
	var x_bits = in_bits.slice(0, bits_per_component)
	var y_bits = in_bits.slice(bits_per_component)
	var x_int = decompress_int_from_bits(x_bits, signed)
	var y_int = decompress_int_from_bits(y_bits, signed)
	return Vector2(x_int, y_int)

static func compress_frame_into_3_bytes(frame_n : int) -> Array:
	# 1111 1111 0000 0000 0000 0000
	var first_byte_check = 16711680
	# 0000 0000 1111 1111 0000 0000
	var second_byte_check = 65280
	# 0000 0000 0000 0000 1111 1111
	var third_byte_check = 255
	var first_byte = (first_byte_check & frame_n) >> 16
	var second_byte = (second_byte_check & frame_n) >> 8
	var third_byte = third_byte_check & frame_n
	return [first_byte, second_byte, third_byte]

static func decompress_frame_from_3_bytes(byte_array : Array) -> int:
	var result = 0
	for i in range(2):
		result = result | byte_array[i]
		result = result << 8
	result = result | byte_array[-1]
	return result

static func compress_radians(radian : float) -> int:
	var x_pi = radian / PI
	return int(round(x_pi * 100))

static func decompress_radian(compressed_as_int : int) -> int:
	var x_pi = compressed_as_int / 100.0
	return x_pi * PI

# Convert a big endian array of bits into an array of integers rangine from 0-255 that represent the bytes
static func bit_array_to_int_array(bit_array : Array) -> Array:
	var bits = bit_array.duplicate(true)
	var int_array = []
	var n_bits = bits.size()
	var remainder = n_bits % 8
	var insert_position = n_bits - remainder - 1
	for i in range(8 - remainder):
		bits.append(0)
	for i in range(0, n_bits, 8):
		var int_value = 0
		for j in range(8):
			var bit = bits[i + j]
			var bit_to_byte = bit << (7 - j)
			int_value |= bit_to_byte
		int_array.append(int_value)
	return int_array

static func byte_array_to_bit_array(bytes : Array, n_bits : int) -> Array:
	var bits = []
	for byte in bytes:
		for i in range(8):
			var bit = 1 if (byte & (1 << (7 - i))) != 0 else 0
			bits.append(bit)
	bits = bits.slice(0, n_bits)
	return bits

static func byte_array_to_int(array : Array) -> int:
	var n_bits = array.size() * 8
	return bit_array_to_int(byte_array_to_bit_array(array, n_bits))

static func partial_byte_array_to_int(array : Array, n_bits : int) -> int:
	return bit_array_to_int(byte_array_to_bit_array(array, n_bits))

static func bit_array_to_int(bit_array : Array) -> int:
	var size = bit_array.size()
	var val = 0
	for i in range(size):
		val = val | (bit_array[i] << (size - i - 1))
	return val

# TO DO -> we could do this once and store the result - Potentially in the ObjectCreationRegistry
# TO DO -> Just compress each character to 5 bits (0-25), then unpack the result. This should
# save us 5 bits per class
static func compress_class_id(class_id : int) -> Array:
	assert(class_id <= 878500) #,"id is greater than the max cantor of 'ZZZ'")
	return compress_int_into_x_bits(class_id, n_class_id_bits)

static func decompress_class_id(class_id_bits : Array) -> int:
	return decompress_int_from_bits(class_id_bits)

static func decompress_class_id_with_reader(bit_reader : BitArrayReader) -> int:
	var class_id_bits = bit_reader.get_x_bits(n_class_id_bits)
	return decompress_int_from_bits(class_id_bits)

static func compress_class_instance(class_instance : int) -> Array:
	assert(class_instance < (1 << n_class_instance_bits)) #,"Class instance must fit into x bits")
	return compress_int_into_x_bits(class_instance, n_class_instance_bits)

# TO DO -> optimize!!
static func n_bits_for_int(val : int, signed = false) -> int:
	val = abs(val)
	var bits = starting_bits_for_n_bits_for_int
	var max_value = 1
	while true:
		max_value = (1 << bits) - 1
		if max_value >= val or bits == 1000:
			break
		bits += 1
	if signed:
		bits += 1
	return bits

static func n_bits_for_vector(vec : Vector2, signed = false) -> int:
	var max_val = max(abs(vec.x), abs(vec.y))
	var n_bits = n_bits_for_int(int(round(max_val)), signed)
	return 2 * n_bits

static func n_bits_for_float(val : float, signed = false) -> int:
	var int_val = int(round(val * pow(10.0, variable_compress_floating_point_precision)))
	return n_bits_for_int(int_val, signed)

static func compress_unit_vector(vec : Vector2):
	var comp_x = compress_float_into_x_bits(vec.x, unit_vector_float_bits, true)
	var comp_y = compress_float_into_x_bits(vec.y, unit_vector_float_bits, true)
	return comp_x + comp_y

static func compress_float_between_zero_and_one(val : float) -> Array:
	assert(val >= 0 and val <= 1) #,"value must be between 0 and 1")
	return compress_float_into_x_bits(val, n_bits_for_float_between_zero_and_one, false, n_decimals_for_float_between_zero_and_one)

static func decompress_float_between_zero_and_one(bit_reader : BitArrayReader) -> float:
	var bits = bit_reader.get_x_bits(n_bits_for_float_between_zero_and_one)
	return decompress_float_from_bits(bits, false, n_decimals_for_float_between_zero_and_one)

static func decompress_unit_vector(bit_array : Array) -> Vector2:
	var bits_per_component = bit_array.size() / 2
	var x_bits = bit_array.slice(0, bits_per_component)
	var y_bits = bit_array.slice(bits_per_component)
	var x = decompress_float_from_bits(x_bits, true)
	var y = decompress_float_from_bits(y_bits, true)
	return Vector2(x, y)

static func decompress_unit_vec_with_bit_reader(bit_reader : BitArrayReader) -> Vector2:
	var bits = bit_reader.get_x_bits(2 * unit_vector_float_bits)
	return decompress_unit_vector(bits)

static func standard_compress(value, n_bits : int, signed = false) -> Array:
	var bits : Array
	if typeof(value) == TYPE_INT:
		bits = compress_int_into_x_bits(value, n_bits, signed)
	elif typeof(value) == TYPE_VECTOR2:
		bits = compress_vector_into_x_bits(value, n_bits, signed)
	return []

static func compress_enum(enum_value : int, n_enums : int) -> Array:
	var required_bits = n_bits_for_int(n_enums)
	return compress_int_into_x_bits(enum_value, required_bits)

static func decompress_enum(bit_reader : BitArrayReader, n_enums : int) -> int:
	var required_bits = n_bits_for_int(n_enums)
	var bits = bit_reader.get_x_bits(required_bits)
	return decompress_int_from_bits(bits)

static func compress_bool(bool_val : bool) -> Array:
	return [1] if bool_val == true else [0]

static func compress_timer_data(timer_data : TimerData) -> Array:
	var timer_bits = []
	var current_frames : int
	var wait_frames : int
	var is_running : bool
	timer_bits += variable_compress(timer_data.wait_frames)
	timer_bits += variable_compress(timer_data.current_frames)
	timer_bits += [1] if timer_data.is_running else [0]
	return timer_bits

static func decompress_timer_data_into(timer_data : TimerData, bit_reader : BitArrayReader) -> void:
	timer_data.wait_frames = variable_decompress(bit_reader, TYPE_INT)
	timer_data.current_frames = variable_decompress(bit_reader, TYPE_INT)
	timer_data.is_running = bit_reader.get_bool()

static func compress_int_to_x_bytes(inData : int, n_bytes : int) -> Array:
	var byte_array = []
	for i in range(n_bytes):
		byte_array.append(inData & 0xff)
		inData = inData >> 8
	return byte_array

static func decompress_byte_array_to_int(byte_array : Array) -> int:
	var val = 0
	var n_bytes = byte_array.size()
	for i in range(n_bytes):
		val = val | (byte_array[i] << (8 * i))
	return val

# Reserves the first 4 bits to specify the number of bits used. For vectors, it
# gives the number of bits per component
static func variable_compress(value, signed = false) -> Array:
	var bits : Array
	var n_bits : int
	if typeof(value) == TYPE_INT:
		n_bits = n_bits_for_int(value, signed)
		bits = compress_int_into_x_bits(n_bits, variable_compress_bits_for_size)
		bits += compress_int_into_x_bits(value, n_bits, signed)
	elif typeof(value) == TYPE_VECTOR2:
		n_bits = n_bits_for_vector(value, signed)
		bits = compress_int_into_x_bits(n_bits / 2, variable_compress_bits_for_size)
		bits += compress_vector_into_x_bits(value, n_bits, signed)
	elif typeof(value) == TYPE_FLOAT:
		n_bits = n_bits_for_float(value, signed)
		bits = compress_int_into_x_bits(n_bits, variable_compress_bits_for_size)
		bits += compress_float_into_x_bits(value, n_bits, signed)
	else:
		assert(false) #,"variable compression does not support type for " + str(value))
	return bits

static func variable_decompress(bit_reader : BitArrayReader, type : int, signed = false):
	var size_bits = bit_reader.get_x_bits(variable_compress_bits_for_size)
	var n_bits = decompress_int_from_bits(size_bits)
	if type == TYPE_INT:
		var data_bits = bit_reader.get_x_bits(n_bits)
		return decompress_int_from_bits(data_bits, signed)
	elif type == TYPE_VECTOR2:
		var data_bits = bit_reader.get_x_bits(2 * n_bits)
		return decompress_vector(data_bits, signed)
	elif type == TYPE_FLOAT:
		var data_bits = bit_reader.get_x_bits(n_bits)
		return decompress_float_from_bits(data_bits, signed)
	else:
		assert(false) #,"variable decompression does not support type for " + str(type))
