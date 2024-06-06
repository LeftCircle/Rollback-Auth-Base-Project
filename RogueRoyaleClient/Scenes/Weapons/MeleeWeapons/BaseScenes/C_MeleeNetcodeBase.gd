extends MeleeNetcodeBase
class_name C_MeleeNetcodeBase

signal frame_to_reset_to(frame)

@export var is_lag_comp: bool = true

var history

func _init_history():
	pass

func connect_to_entity(connected_entity):
	entity = connected_entity

func disconnect_from_entity():
	#entity = null
	pass
