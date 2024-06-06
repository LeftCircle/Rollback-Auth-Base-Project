extends RefCounted
class_name PredictedActionsLoopingArray

var size = 60
var array = []

func _init():
	array.resize(size)
	for i in range(size):
		array[i] = InputActions.new()

func add_data(frame : int, data : InputActions) -> void:
	array[frame % size].duplicate(data)

func retrieve(frame : int):
	return array[frame % size]
