extends RefCounted
class_name ComponentData

var creation_frame : int = 0


func _init():
	creation_frame = CommandFrame.execution_frame
