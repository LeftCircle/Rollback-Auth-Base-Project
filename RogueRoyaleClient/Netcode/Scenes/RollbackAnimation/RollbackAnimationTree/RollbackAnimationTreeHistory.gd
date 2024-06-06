extends RefCounted
class_name RollbackAnimationTreeHistory

var size = 120
var array = []

func _init():
	for i in range(size):
		array.append(RollbackAnimationStateMachineData.new())

func add_data(frame, state_machine_playback : AnimationNodeStateMachinePlayback, blend_position : Vector2) -> void:
	array[frame % size].set_data(frame, state_machine_playback, blend_position)

func retrieve_data(frame : int) -> RollbackAnimationStateMachineData:
	var data = array[frame % size] as RollbackAnimationStateMachineData
	if not data.frame == frame:
		data.set_to_reset(frame)
	return data
