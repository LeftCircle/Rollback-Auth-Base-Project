extends RefCounted
class_name RollbackTimerHistory

var size = 120
var history = []
var logging_enabled = false

func _init():
	for i in range(size):
		history.append(RollbackTimerData.new())

func add_data(frame : int, rollback_timer) -> void:
	history[frame % size].set_data(frame, rollback_timer)

func get_data_or_null(frame : int) -> RollbackTimerData:
	var data = history[frame % size] as RollbackTimerData
	if not data.frame == frame:
		return null
	return data

func rollback_the_timer(frame : int, timer) -> void:
	var data = history[frame % size] as RollbackTimerData
	if data.frame == frame:
		timer.current_time = data.current_time
		timer.is_running = data.is_running
	else:
		if logging_enabled:
			Logging.log_line("Old data when resetting timer. data = ")
			data.log_data()
