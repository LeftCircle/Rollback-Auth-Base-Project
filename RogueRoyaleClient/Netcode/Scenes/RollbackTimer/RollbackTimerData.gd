extends RefCounted
class_name RollbackTimerData

var frame : int
var is_running : bool
var current_frames : int

func set_data(new_frame : int, rollback_timer) -> void:
	frame = new_frame
	is_running = rollback_timer.is_running
	current_frames = rollback_timer.current_frames

func log_data():
	Logging.log_line("Frame = " + str(frame))
	Logging.log_line("current_time = " + str(current_frames) + " is_running = " + str(is_running))
