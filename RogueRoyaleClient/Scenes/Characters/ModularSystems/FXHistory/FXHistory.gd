extends RefCounted
class_name FXHistory

var array = []
var size = 32

func _init():
	array.resize(size)
	for i in range(size):
		array[i] = [0, false]

func has_fx_for(frame : int) -> bool:
	var hist = array[frame % size]
	return hist[0] == frame and hist[1]

func add_data(frame : int, val : bool) -> void:
	var hist = array[frame % size]
	hist[0] = frame
	hist[1] = val
