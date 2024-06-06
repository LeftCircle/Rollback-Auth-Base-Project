extends RefCounted
class_name ActionFromClientComparer

enum MISSMATCH_TYPE{NONE, SILENT, ROLLBACK}

static func compare(action_a : ActionFromClient, action_b : ActionFromClient) -> MISSMATCH_TYPE:
	# The only silent action is looking_vector
	var action_a_bitmap = action_a.get_action_bitmap()
	var action_b_bitmap = action_b.get_action_bitmap()
	if action_a_bitmap != action_b_bitmap:
		return MISSMATCH_TYPE.ROLLBACK
	elif not vectors_match(action_a.get_input_vector(), action_b.get_input_vector(), 0.01):
		return MISSMATCH_TYPE.ROLLBACK
	elif not vectors_match(action_a.get_looking_vector(), action_b.get_looking_vector(), 0.01):
		return MISSMATCH_TYPE.SILENT
	return MISSMATCH_TYPE.NONE

static func vectors_match(vector1, vector2, threshold = 0.1) -> bool:
	var matches =  (vector1 - vector2).length_squared() < threshold
	if matches:
		return true
	else:
		Logging.log_line("Vectors do not match. length squared = " + str((vector1 - vector2).length_squared()))
		return false
