extends BaseModularHistory
class_name StateSystemHistory

#func _init():
#	for _i in range(size):
#		history.append(StateSystemData.new())

func _new_data_container():
	return StateSystemData.new()
