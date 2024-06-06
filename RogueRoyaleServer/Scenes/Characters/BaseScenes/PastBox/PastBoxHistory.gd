extends RefCounted
class_name PastBoxHistory

const NO_DATA_FOR_FRAME = null

var size = 180
var history = []

func _init():
	for i in range(size):
		history.append(PastBoxData.new())

func add_data(frame : int, collision_shape) -> void:
	var data = history[frame % size]
	data.set_data_with_obj(collision_shape)
	data.frame = frame

func retrieve_data(frame : int):
	var data = history[frame % size]
	if data.frame != frame:
		return NO_DATA_FOR_FRAME
	return data
