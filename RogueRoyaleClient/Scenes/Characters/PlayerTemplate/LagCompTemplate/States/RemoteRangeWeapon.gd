extends BaseRemoteState
class_name RemoteRangedState

#var ranged_weapon
#
#func init(new_entity) -> void:
#	entity = new_entity
#
#func set_ranged_weapon(new_weapon) -> void:
#	ranged_weapon = new_weapon
#
#func _ready():
#	state_enum = PlayerStateManager.RANGE_WEAPON
#	set_physics_process(false)
#
#func physics_process():
#	pass
#
#func enter():
#	ranged_weapon.draw()
#
#func exit():
#	ranged_weapon.holster()
