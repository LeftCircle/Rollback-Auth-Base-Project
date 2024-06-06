extends BaseHealing
class_name C_Healing

func _init_history():
	history = HealingHistory.new()

func execute(frame : int) -> bool:
	var is_running = super.execute(frame)
	netcode.on_client_update(frame)
	return is_running
