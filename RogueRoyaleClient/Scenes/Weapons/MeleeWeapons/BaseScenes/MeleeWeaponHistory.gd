extends BaseModularHistory
class_name MeleeWeaponHistory

var to_log = false

#func _init():
#	for _i in range(size):
#		history.append(MeleeWeaponData.new())

func _new_data_container():
	return MeleeWeaponData.new()

