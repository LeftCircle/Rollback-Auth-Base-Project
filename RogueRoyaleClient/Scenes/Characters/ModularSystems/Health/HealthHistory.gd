extends BaseModularHistory
class_name HealthHistory

#func _init():
#	for i in range(size):
#		history.append(HealthData.new())

func _new_data_container():
	return HealthData.new()
