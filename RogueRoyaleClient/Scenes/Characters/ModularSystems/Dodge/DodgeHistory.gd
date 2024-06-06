extends BaseModularHistory
class_name DodgeHistory

#func _init():
#	for i in range(size):
#		history.append(DodgeData.new())

func _new_data_container():
	return DodgeData.new()
