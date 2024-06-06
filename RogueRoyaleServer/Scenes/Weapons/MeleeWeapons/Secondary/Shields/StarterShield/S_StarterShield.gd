extends StarterShield
class_name S_StarterShield



func _ready():
	shape = $Hitbox
	super._ready()

func execute(frame, input_actions : InputActions) -> int:
	super.execute(frame, input_actions)
	#netcode.set_state_data(weapon_data)
	netcode.send_to_clients()
	return weapon_data.attack_end

func end_execution(frame : int):
	super.end_execution(frame)
	show()
	#netcode.set_state_data(weapon_data)
	netcode.send_to_clients()

func physics_process(frame : int, input_actions : InputActions) -> void:
	pass
	#.physics_process(frame, input_actions)
	#netcode.set_state_data(self)
	#netcode.send_to_clients()
	#print("Is in parry = ", is_in_parry)
	#print("Shield state = ", state)
