extends BaseModularHistory
class_name BaseRangeWeaponHistory

#func _init():
#	for i in range(size):
#		history.append(BaseRangeWeaponData.new())

func _new_data_container():
	return BaseRangeWeaponData.new()

