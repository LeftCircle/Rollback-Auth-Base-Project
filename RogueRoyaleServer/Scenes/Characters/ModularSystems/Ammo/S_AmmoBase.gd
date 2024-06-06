extends AmmoBase
class_name S_AmmoBase

func _on_ammo_used(frame : int):
	super._on_ammo_used(frame)
	#netcode.set_state_data(self)
	netcode.send_to_clients()

func _on_refill_ammo(frame : int):
	super._on_refill_ammo(frame)
	#netcode.set_state_data(self)
	netcode.send_to_clients()
