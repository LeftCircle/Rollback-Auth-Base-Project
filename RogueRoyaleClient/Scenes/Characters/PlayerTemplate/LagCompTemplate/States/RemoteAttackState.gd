extends BaseRemoteState
class_name RemotePlayerAttackState


#enum WEAPON_SLOT{PRIMARY, SECONDARY}
#@export var weapon_slot: WEAPON_SLOT = WEAPON_SLOT.PRIMARY
#
#var weapon
#
#func _ready():
#	if weapon_slot == WEAPON_SLOT.PRIMARY:
#		state_enum = RemotePlayerStateManager.ATTACK_PRIMARY
#	else:
#		state_enum = RemotePlayerStateManager.ATTACK_SECONDARY
#
## The remote attack state does nothing, but is required for ending the execution
## of the weapon when the state changes
#func physics_process():
#	pass
#
#func exit():
#	weapon.end_execution()
#
#func set_primary_weapon(with_weapon):
#	if with_weapon != weapon:
#		weapon = with_weapon
#		weapon.connect("execution_finished",Callable(self,"_on_execution_finished"))
