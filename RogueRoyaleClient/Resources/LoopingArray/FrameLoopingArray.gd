extends RefCounted
class_name FrameLoopingArray

enum {POOL_BYTE_ARRAY, POOL_VECTOR_ARRAY, POOL_INT_ARRAY, ARRAY}
var array = []
var size = 120

func init(type : int, new_size : int, default_value = 0) -> void:
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
	else:
		assert(false) #,"Invalid type")
	size = new_size
	for _i in range(size):
		array.append(default_value)

func add_data(data, frame : int) -> void:
	array[frame % size] = data

func retrieve(frame : int):
	return array[frame % size]
