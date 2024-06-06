extends BaseModularHistory
class_name InputQueueHistory

#func _init():
#	history.resize(size)
#	for i in range(size):
#		var data = InputQueueData.new()
#		history[i] = data

func _new_data_container():
	return InputQueueData.new()
