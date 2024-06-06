extends BaseModularHistory
class_name RollbackAnimationLoopingArray


#func _init():
#	for i in range(size):
#		array.append(RollbackAnimationData.new())

func _new_data_container():
	return RollbackAnimationData.new()

func add_data(frame, anim_player : AnimationPlayer) -> void:
	var data = retrieve_data(frame)
	data.set_data(frame, anim_player)

func retrieve_data(frame : int):
	var data = history[frame % size]
	if not is_instance_valid(data):
		data = _new_data_container()
		data.set_to_reset(frame)
	elif data.frame != frame:
		data.set_to_reset(frame)
	return data

#func get_data(frame : int) -> RollbackAnimationData:
#	var data = array[frame % size] as RollbackAnimationData
#	if not data.frame == frame:
#		data.set_to_reset(frame)
#	return data
