extends BaseModularHistory
class_name HealingHistory

#func _init():
#	for i in range(size):
#		history.append(HealingData.new())

func _new_data_container():
	return HealingData.new()
