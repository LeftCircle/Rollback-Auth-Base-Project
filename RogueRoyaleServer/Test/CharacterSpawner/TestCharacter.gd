extends ServerPlayerCharacter
class_name TestCharacter

var random = RandomNumberGenerator.new()

@onready var input_action_generator = $InputActionGenerator

func _init():
	random.randomize()
	Server.on_player_verified(random.randi_range(1000000, 9999999))

#func _standard_character_functions():
#	var frame = CommandFrame.frame
#	inputs = input_action_generator.get_inputs()
#	input_actions.receive_action(inputs)
#	Logging.log_line("executing input action:")
#	input_actions.log_input_actions()
#	states.physics_process(frame, input_actions)
#	stamina.physics_process(frame)
#	health.physics_process(frame)
#	_weapon_physics_process(frame)
#	_update_player_state(frame)
