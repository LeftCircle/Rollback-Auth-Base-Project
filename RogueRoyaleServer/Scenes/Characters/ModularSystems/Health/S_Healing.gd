extends BaseHealing
class_name S_Healing

func execute(frame : int) -> bool:
	var is_running = super.execute(frame)
	#netcode.set_state_data(self)
	netcode.send_to_clients()
	return is_running
