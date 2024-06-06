extends BaseModularHistory
class_name DashHistory

#func _init():
#	history.resize(size)
#	for i in range(size):
#		var data = DashModuleData.new()
#		history[i] = data

func _new_data_container():
	return DashModuleData.new()
