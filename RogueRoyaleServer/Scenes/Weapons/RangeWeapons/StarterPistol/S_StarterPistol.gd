extends StarterPistol
class_name S_StarterPistol



func execute(frame : int, input_actions : InputActions) -> void:
	super.execute(frame, input_actions)
	#netcode.set_state_data(self)
	netcode.send_to_clients()
