extends Resource
class_name EnemyHistory

var history_size = 180
var history_array = []

func _init():
	for i in range(history_size):
		history_array.append(EnemyHistoryData.new())

func get_history_for_frame(frame : int) -> EnemyHistoryData:
	assert(history_array[frame % history_size].frame == frame)
	return history_array[frame % history_size]

func add_data(history_to_add : EnemyHistory) -> void:
	var hist = get_history_for_frame(history_to_add.frame)
	hist.set_data_with_obj(history_to_add)
