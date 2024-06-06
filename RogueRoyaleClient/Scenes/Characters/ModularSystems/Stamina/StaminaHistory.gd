extends BaseModularHistory
class_name StaminaHistory

#func _init():
#	for i in range(size):
#		history.append(StaminaData.new())

func _new_data_container():
	return StaminaData.new()
