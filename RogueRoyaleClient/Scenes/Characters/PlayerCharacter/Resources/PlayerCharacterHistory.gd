extends ServerHistoryCorrector
class_name PlayerCharacterHistory

var input_history_compresser = InputHistoryCompresser.new()

func _init():
	for i in range(history_size):
		history_array.append(PlayerHistoryData.new())

func send_sliding_buffer(frame):
	input_history_compresser.send_sliding_buffer(last_frame_checked_against_server, frame)

#func add_history_and_queue_send(frame : int, player_state : PlayerState, inputs : InputActions):
#	add_history(frame, player_state, inputs)
#	input_history_compresser.add_action_to_send(frame, inputs.get_current_action())

func queue_polled_inputs(frame : int, polled_inputs : InputActions) -> void:
	input_history_compresser.add_action_to_send(frame, polled_inputs.get_current_action())
