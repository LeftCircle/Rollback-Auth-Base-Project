extends Dodge
class_name S_Dodge

func execute(frame : int, entity, input_actions : InputActions) -> bool:
	var can_execute = super.execute(frame, entity, input_actions)
	#netcode.set_state_data(self)
	netcode.send_to_clients()
	return can_execute
