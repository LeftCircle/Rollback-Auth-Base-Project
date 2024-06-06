extends InputQueueComponent
class_name C_InputQueue

@export var to_log : bool = false

func _init_history():
	history = InputQueueHistory.new()

func execute(frame : int, input_actions : InputActions) -> void:
	super.execute(frame, input_actions)
	#if to_log:
	Logging.log_line("Input queued on frame " + str(frame))
	input_actions.log_input_actions()
	log_data(frame, data_container)
	netcode.on_client_update(frame)

func reset(frame : int) -> void:
	super._reset_system(data_container)
	if to_log:
		Logging.log_line("Resetting input queue on frame " + str(frame))
		log_data(frame, data_container)
	netcode.on_client_update(frame)

func set_queued_input(frame : int, action : String) -> void:
	super.set_queued_input(frame, action)
	if to_log:
		Logging.log_line("Setting queued input on frame " + str(frame))
		log_data(frame, data_container)
	netcode.on_client_update(frame)

func set_data_to(frame : int, other_data : InputQueueData) -> void:
	super.set_data_to(frame, other_data)
	netcode.on_client_update(frame)
