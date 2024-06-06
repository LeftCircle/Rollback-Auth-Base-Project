extends BaseModularHistory
class_name ShieldHistory

#func _init():
#	for i in range(size):
#		history.append(MeleeWeaponData.new())

func _new_data_container():
	return MeleeWeaponData.new()

