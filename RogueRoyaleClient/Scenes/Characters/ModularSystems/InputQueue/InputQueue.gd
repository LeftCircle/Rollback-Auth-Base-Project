extends ClientNetcodeModule
class_name InputQueueComponent

const MAX_HELD_FRAMES = 180

const string_to_int = {
	"NONE": 0,
	"attack_secondary" : 1,
	"fire_ranged_weapon" : 2,
	"health_flask": 3,
	"special_1": 4,
	"special_2": 5,
	"attack_primary" : 6,
	"dodge" : 7,
	"dash" : 8,
	"draw_ranged_weapon" : 9
}
const int_to_string = {
	0 : "NONE",
	1 : "attack_secondary",
	2 : "fire_ranged_weapon",
	3 : "health_flask",
	4 : "special_1",
	5 : "special_2",
	6 : "attack_primary",
	7 : "dodge",
	8 : "dash",
	9 : "draw_ranged_weapon"
}

func _netcode_init():
	data_container = InputQueueData.new()
	netcode.init(self, "IQU", data_container, InputQueueCompression.new())

func _ready():
	add_to_group("InputQueue")

func execute(frame : int, input_actions : InputActions) -> void:
	_execute_system(data_container, input_actions)

func set_queued_input(frame : int, action : String) -> void:
	_reset_system(data_container)
	data_container.input = string_to_int[action]

func _execute_system(data : InputQueueData, input_actions : InputActions) -> void:
	if data.input == string_to_int["NONE"]:
		_queue_input(data, input_actions)
	else:
		_update_queued_input(data, input_actions)

func _queue_input(data : InputQueueData, input_actions : InputActions):
	if input_actions.is_action_just_pressed("dodge"):
		data.input = string_to_int["dodge"]
	elif input_actions.is_action_just_pressed("attack_primary"):
		data.input = string_to_int["attack_primary"]
	elif input_actions.is_action_just_pressed("attack_secondary"):
		data.input = string_to_int["attack_secondary"]
	elif input_actions.is_action_just_pressed("fire_ranged_weapon"):
		data.input = string_to_int["fire_ranged_weapon"]
	elif input_actions.is_action_just_pressed("health_flask"):
		data.input = string_to_int["health_flask"]
	elif input_actions.is_action_just_pressed("special_1"):
		data.input = string_to_int["special_1"]
	elif input_actions.is_action_just_pressed("special_2"):
		data.input = string_to_int["special_2"]
	else:
		data.input = string_to_int["NONE"]

func _update_queued_input(data : InputQueueData, input_actions : InputActions) -> void:
	if input_actions.is_action_just_pressed("dodge"):
		data.input = string_to_int["dodge"]
		data.held_frames = 0
	else:
		if input_actions.is_action_released(int_to_string[data.input]):
			data.is_released = true
		elif not data.is_released:
			data.held_frames += 1
			data.held_frames = min(data.held_frames, MAX_HELD_FRAMES)

func _reset_system(data : InputQueueData) -> void:
	data.input = string_to_int["NONE"]
	data.is_released = false
	data.held_frames = 0

func is_input_queued() -> bool:
	return data_container.input != string_to_int["NONE"]

func queued_input_is(action : String) -> bool:
	return data_container.input == string_to_int[action]

static func queued_input_of_other_data_is(data : InputQueueData, action : String) -> bool:
	return data.input == string_to_int[action]

func set_data_to(frame : int, other_data : InputQueueData) -> void:
	data_container.set_data_with_obj(other_data)

func log_data(frame : int, data : InputQueueData):
	Logging.log_line("Input queue data for frame " + str(frame))
	Logging.log_line("Input = " + str(data.input) + " is_released = " +
					str(data.is_released) + " held frames = " + str(data.held_frames))
