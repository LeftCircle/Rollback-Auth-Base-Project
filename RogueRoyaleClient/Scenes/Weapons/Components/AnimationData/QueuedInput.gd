extends RefCounted
class_name QueuedInput

var input : String = ""
var is_released : bool = false
var held_frames = 0


func reset():
	input = ""
	is_released = false
	held_frames = 0

func queue_input(input_actions : InputActions) -> void:
	if input == "":
		if input_actions.is_action_just_pressed("attack_primary"):
			input = "attack_primary"
		elif input_actions.is_action_just_pressed("attack_secondary"):
			input = "attack_secondary"
		elif input_actions.is_action_just_pressed("fire_ranged_weapon"):
			input = "fire_ranged_weapon"
		elif input_actions.is_action_just_pressed("health_flask"):
			input = "health_flask"
		elif input_actions.is_action_just_pressed("special_1"):
			input = "special_1"
		elif input_actions.is_action_just_pressed("special_2"):
			input = "special_2"
	else:
		if input_actions.is_action_released(input):
			is_released = true
		elif not is_released:
			held_frames += 1
