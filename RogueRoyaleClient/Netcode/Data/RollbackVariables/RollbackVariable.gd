extends RefCounted
class_name RollbackVariable

var size = 120
var history = []
var current_value

func init(default_value):
	for i in range(size):
		var data = RollbackData.new()
		data.value = default_value
		history.append(data)

func update(frame : int, value) -> void:
	history[frame % size].update(frame, value)
	current_value = value

func _on_rollback(frame : int) -> void:
	current_value = history[frame % size].value
