extends Resource
class_name RollbackFrameTracker

var oldest_correct_frame = -1
var most_recent_frame = -1


func reset():
	oldest_correct_frame = -1
	most_recent_frame = -1

func set_oldest_correct_frame(frame) -> void:
	var previous_frame = CommandFrame.get_previous_frame(frame)
	if oldest_correct_frame == -1:
		oldest_correct_frame = previous_frame
	else:
		if CommandFrame.command_frame_greater_than_previous(oldest_correct_frame, previous_frame):
			oldest_correct_frame = previous_frame
	Logging.log_rollback("oldest correct frame = " + str(oldest_correct_frame) + " received " + str(frame))

func set_most_recent_frame(frame) -> void:
	if most_recent_frame == -1:
		most_recent_frame = frame
	else:
		if CommandFrame.command_frame_greater_than_previous(most_recent_frame, frame):
			most_recent_frame = most_recent_frame
		else:
			most_recent_frame = frame
	Logging.log_rollback("most_recent_frame = " + str(most_recent_frame) + " received " + str(frame))
