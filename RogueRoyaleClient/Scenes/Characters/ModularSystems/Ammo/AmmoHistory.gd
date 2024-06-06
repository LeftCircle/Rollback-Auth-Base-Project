extends BaseModularHistory
class_name AmmoHistory

#func _init():
#	for i in range(size):
#		history.append(AmmoData.new())

func _new_data_container():
	return AmmoData.new()
