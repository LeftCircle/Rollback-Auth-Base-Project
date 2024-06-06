extends OutputMemoryBitStream
class_name DynamicOutputBitStream
# this is like the original, except it starts with a small size and
# allocates space as needed

func _init_buffer() -> void:
	max_bytes = 32
	mBuffer.resize(max_bytes)
	mBuffer.fill(0)

func add_more_to_buffer():
	max_bytes += WORD_SIZE
	var new_array = []
	new_array.resize(WORD_SIZE)
	new_array.fill(0)
	mBuffer = mBuffer + new_array

func write_word_to_buffer(word : int) -> void:
	# The word is packed in big Endian order
	# Data is inserted into the buffer from right to left
	var data_to_mem = word & 0xffffffff
	var byte_index = 4 * word_index
	mBuffer[byte_index] = data_to_mem & 0xff
	mBuffer[byte_index + 1] = data_to_mem >> 8 & 0xff
	mBuffer[byte_index + 2] = data_to_mem >> 16 & 0xff
	mBuffer[byte_index + 3] = data_to_mem >> 24 & 0xff
	if (byte_index + 4) >= max_bytes:
		add_more_to_buffer()
	word_index += 1

func finish_compress():
	flush_scratch_to_buffer()

func write_into_other_stream(bit_stream : OutputMemoryBitStream) -> void:
	_reset_to_write_to_other_buffer()
	gaffer_start_read(mBuffer, total_bits)
	while read_bits != total_bits:
		var bits_left = total_bits - read_bits
		if bits_left < WORD_SIZE:
			assert(bits_left != 0)
			var val = gaffer_read(bits_left)
			bit_stream.gaffer_write_int(val, bits_left)
		else:
			var val = gaffer_read(WORD_SIZE)
			bit_stream.gaffer_write_int(val, WORD_SIZE)

func _reset_to_write_to_other_buffer():
	# Don't reset the total bits
	scratch = 0
	scratch_bits = 0
	read_bits = 0
	word_index = 0
