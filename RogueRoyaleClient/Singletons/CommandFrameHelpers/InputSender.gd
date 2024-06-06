extends Node
class_name InputSenderOld

var reliable_actions = [
	"spell1",
	"dodge",
	"attack_weapon_primary"
]

var all_actions = [
	"spell1",
	"dodge",
	"attack_weapon_primary",
	"up",
	"down",
	"left",
	"right"
]
# TO DO!!! SEND THE INPUT ARRAY INSTEAD OF ACTIONS FOR MOVEMENT!!!!
# The action is an array to ensure proper ordering is sent to the server
# [{command_step : {action : [InputStrength]}, ...] (an array of command frames for the process frame
var physics_frames = []
# {command_step : {action : [InputStrength], ... }}
var history_0 : Array = []
var history_1 : Array = []
var history_2 : Array = []
var history_3 : Array = []
var history_extra_buffer : Array = []
var unreliable_history_array : Array
var current_action = ActionFromClient.new()

func receive_current_frame_data(physics_frame : Array) -> void:
	physics_frames.append_array(physics_frame)

func send_input_history_and_swap_buffers():
	if not physics_frames.is_empty():
		history_0 = physics_frames.duplicate(true)
		unreliable_history_array = history_0 + history_1 + history_2 + history_3
		Server.send_player_inputs_unreliable(unreliable_history_array)
		physics_frames.clear()
		__swap_history_buffers()

func __swap_history_buffers():
	history_3 = history_2
	history_2 = history_1
	history_1 = history_0
	history_0 = history_extra_buffer
	history_extra_buffer = history_3
	history_0.clear()

func copy_last_input() -> void:
	var previous_command_frame
	if physics_frames.is_empty():
		previous_command_frame = history_1[-1]
	else:
		previous_command_frame = physics_frames[-1]
	var previous_frame = previous_command_frame.keys()[0]
	var previous_data = previous_command_frame[previous_frame].duplicate(true)
	physics_frames.append({previous_frame + 1 : previous_data})

func create_empty_input(frame_n : int) -> void:
	physics_frames.append({frame_n : {}})
