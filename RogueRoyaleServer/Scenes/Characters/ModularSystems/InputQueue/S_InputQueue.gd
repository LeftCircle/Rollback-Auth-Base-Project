extends InputQueueComponent
class_name S_InputQueue


func execute(frame : int, input_actions : InputActions) -> void:
	super.execute(frame, input_actions)
	Logging.log_line("Input queued on frame " + str(frame))
	input_actions.log_input_actions()
	log_data(frame, data_container)
	netcode.send_to_clients()

func reset(frame : int) -> void:
	super._reset_system(data_container)
	netcode.send_to_clients()

func set_queued_input(frame : int, action : String) -> void:
	super.set_queued_input(frame, action)
	netcode.send_to_clients()

func set_data_to(frame : int, other_data : InputQueueData) -> void:
	super.set_data_to(frame, other_data)
	netcode.send_to_clients()
