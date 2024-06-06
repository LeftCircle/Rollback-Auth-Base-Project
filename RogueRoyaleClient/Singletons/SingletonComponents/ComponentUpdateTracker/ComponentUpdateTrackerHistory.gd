extends BaseModularHistory
class_name ComponentUpdateTrackerHistory

func _new_data_container():
	return ComponentUpdateTrackerData.new()

func add_data(frame : int, component) -> void:
	var data = retrieve_data(frame)
	if data == NO_DATA_FOR_FRAME:
		data = _new_data_container()
		history[frame % size] = data
	data.updated_components[component] = null
	data.frame = frame
