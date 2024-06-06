extends RefCounted
class_name DelayedFunctionExecutioner

var execute_after_x_frames = 0
var _frames_since_last_execute = 0
var funcref_to_execute

func delay_execute() -> void:
	if _frames_since_last_execute >= execute_after_x_frames:
		_frames_since_last_execute = 0
		funcref_to_execute.call()
	else:
		_frames_since_last_execute += 1
