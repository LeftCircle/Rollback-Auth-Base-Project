extends RefCounted
class_name BaseRollbackHistory

# Likely to be replaced by BaseModuleHistory

var array = []
var size = 120

#func init(data_type : Resource):
#	for i in range(size):
#		array.append(data_type.duplicate(true))

func add_data(frame : int, with_node) -> void:
	var old_hist = array[frame % size]
	old_hist.set_data(with_node)

func retrieve(frame : int):
	return array[frame % size]
