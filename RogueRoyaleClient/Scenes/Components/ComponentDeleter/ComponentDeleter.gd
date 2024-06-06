#extends Node2D
#class_name ComponentDeleter
#
#var components_to_delete : Dictionary = {}
#
#func _ready():
#	visible = false
#
#func defer_delete(component : Node) -> void:
#	if not CommandFrame.execution_frame in components_to_delete:
#		var new_array : Array[Node] = [component]
#		components_to_delete[CommandFrame.execution_frame] = [component]
#	else:
#		components_to_delete[CommandFrame.execution_frame].append(component)
#	component.reparent(self)
