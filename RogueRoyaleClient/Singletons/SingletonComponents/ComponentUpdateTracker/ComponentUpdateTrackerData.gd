extends RefCounted
class_name ComponentUpdateTrackerData

var updated_components : Dictionary = {}
var frame : int = -1

func frame_init(new_frame : int) -> void:
	frame = new_frame
	updated_components.clear()
