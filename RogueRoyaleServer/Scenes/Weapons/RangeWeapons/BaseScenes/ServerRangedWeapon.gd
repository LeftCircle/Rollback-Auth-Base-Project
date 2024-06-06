extends BaseRangedWeapon
class_name ServerRangedWeapon


func _init_bullet(new_bullet, frame) -> void:
	new_bullet.fire(entity, weapon_data, aiming_direction, global_position, frame)

func set_state_data():
	netcode.state_data.set_data_with_obj(self)
