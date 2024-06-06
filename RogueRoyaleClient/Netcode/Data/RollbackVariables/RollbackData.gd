extends RefCounted
class_name RollbackData

var frame : int
var value

func update(new_frame : int, new_value) -> void:
	frame = new_frame
	value = new_value
