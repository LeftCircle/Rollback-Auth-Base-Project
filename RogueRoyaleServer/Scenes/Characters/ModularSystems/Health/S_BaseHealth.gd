extends BaseHealth
class_name S_BaseHealth



func damage(frame : int, amount : int) -> void:
	super.damage(frame, amount)
	#netcode.set_state_data(self)
	netcode.send_to_clients()

func heal(frame : int, amount : int) -> void:
	super.heal(frame, amount)
	#netcode.set_state_data(self)
	netcode.send_to_clients()

func _heal_shields(amount : int) -> int:
	var leftover = super._heal_shields(amount)
	#netcode.set_state_data(self)
	netcode.send_to_clients()
	return leftover

func physics_process(frame : int) -> void:
	super.physics_process(frame)
	#netcode.set_state_data(self)
