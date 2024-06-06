extends Resource
class_name BitArrayReader

var head = 0
var bit_array = []
var array_size : int

func set_bit_array(new_bit_array) -> void:
	bit_array = new_bit_array
	array_size = bit_array.size()
	head = 0

func get_x_bits(n_bits) -> Array:
	assert(head + n_bits <= array_size) #,"requesting too many bits")
	var result = bit_array.slice(head, head + n_bits)
	head = head + n_bits
	return result

func get_bool() -> bool:
	return bool(get_x_bits(1)[0])

func is_finished():
	return head == array_size
