extends BaseModularHistory
class_name ActionLoopingArray

#var size = 60
#var array = []
#
#func _init():
#	array.resize(size)
#	for i in range(size):
#		array[i] = ActionFromClient.new()
#
#func add_data(frame : int, data : ActionFromClient) -> void:
#	array[frame % size].duplicate(data)
#
#func retrieve(frame : int):
#	return array[frame % size]

func _new_data_container():
	return ActionFromClient.new()

func add_data(frame : int, with_node) -> void:
	var data = retrieve_data(frame)
	if data == NO_DATA_FOR_FRAME:
		data = _new_data_container()
	#var data = history[frame % size]
	data.action_data.set_data_with_obj(with_node.action_data)
	data.frame = frame
	history[frame % size] = data
