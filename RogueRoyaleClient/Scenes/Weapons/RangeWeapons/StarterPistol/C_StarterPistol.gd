extends StarterPistol
class_name C_StarterPistol

func _init():
	super._init()
	history = BaseRangeWeaponHistory.new()

func execute(frame : int, input_actions : InputActions) -> void:
	super.execute(frame, input_actions)
	netcode.on_client_update(frame)
