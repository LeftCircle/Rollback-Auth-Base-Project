extends DashModular
class_name ClientDash

@export var starting_dash_speed : int = 1500# setget set_start_dash_speed # (int, 0, 10000)
@export var starting_dash_seconds : float = 0.5# setget set_start_dash_seconds # (float, 0, 3)

#var last_execute_frame : int = 0
var dash_frames_for_export_var
var dash_speed_for_export_var

func _init():
	super._init()
	data_container = DashModuleData.new()
	#data_container.dash_frames = float(int(starting_dash_seconds / CommandFrame.frame_length_sec))
	#data_container.dash_speed = starting_dash_speed

func set_start_dash_seconds(new_val : float):
	starting_dash_seconds = new_val
	dash_frames_for_export_var = float(int(starting_dash_seconds / CommandFrame.frame_length_sec))

func set_start_dash_speed(new_val : int) -> void:
	starting_dash_speed = new_val

func _init_history():
	history = DashHistory.new()

func execute(frame : int, entity, input_actions: InputActions):
	#var set_data = history.retrieve_data_at_pos(frame)
	#var data = history.retrieve_data_at_pos(last_execute_frame)
	data_container.frame = frame
	super.execute_system(frame, entity, input_actions, data_container)
	netcode.on_client_update(frame)

func reset_to_frame(frame : int) -> void:
	#mutex.lock()
	var hist = history.retrieve_data(frame)
	if not hist == BaseModularHistory.NO_DATA_FOR_FRAME:
		data_container.set_data_with_obj(hist)
