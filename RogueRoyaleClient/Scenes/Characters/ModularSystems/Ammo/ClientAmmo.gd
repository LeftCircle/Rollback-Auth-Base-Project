extends AmmoBase
class_name ClientAmmo

signal ammo_changed(max_ammo, current_ammo)

func _init_history():
	history = AmmoHistory.new()

func _ready():
	super._ready()
	emit_signal("ammo_changed", max_ammo, current_ammo)

func _on_ammo_used(frame : int):
	super._on_ammo_used(frame)
	netcode.on_client_update(frame)
	emit_signal("ammo_changed", max_ammo, current_ammo)

func _on_refill_ammo(frame : int):
	super._on_refill_ammo(frame)
	netcode.on_client_update(frame)
	emit_signal("ammo_changed", max_ammo, current_ammo)

func set_max_and_current(frame : int, new_max : int, new_current : int) -> void:
	super.set_max_and_current(frame, new_max, new_current)
	netcode.on_client_update(frame)
	emit_ammo_changed_signal()

func emit_ammo_changed_signal():
	emit_signal("ammo_changed", max_ammo, current_ammo)
