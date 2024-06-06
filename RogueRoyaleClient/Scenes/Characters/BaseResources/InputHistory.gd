extends RefCounted
class_name InputHistory

var size = 180
var history = []
var empty_action = InputActions.new()

#func _init():
#	for _i in range(size):
#		history.append(InputActions.new())

func _new_data_container():
	return InputActions.new()

func add_inputs(frame : int, input_actions : InputActions) -> void:
	history[frame % size].duplicate(input_actions)

# TO DO -> could put a frame on InputActions and check to see if they match
func get_inputs(frame : int) -> InputActions:
	return history[frame % size]

func get_buffered_inputs(frame : int, input_buffer : int) -> InputActions:
	var buffered_frame = CommandFrame.get_previous_frame(frame, input_buffer)
	var buffered_inputs = get_inputs(buffered_frame)
#	Logging.log_line("Buffered inputs for buffered frame = " + str(buffered_frame))
#	buffered_inputs.log_input_actions()
	return buffered_inputs
