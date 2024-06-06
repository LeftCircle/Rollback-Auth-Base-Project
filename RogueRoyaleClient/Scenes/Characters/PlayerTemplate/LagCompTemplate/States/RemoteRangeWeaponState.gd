extends BaseRemoteState
class_name RemoteRangeWeaponState

var ranged_weapon

func init(new_entity) -> void:
	entity = new_entity

func set_ranged_weapon(new_weapon) -> void:
	ranged_weapon = new_weapon

func _ready():
	state_enum = PlayerStateManager.RANGE_WEAPON

func physics_process():
	pass

func exit():
	ranged_weapon.holster()
