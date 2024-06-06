extends BaseModuleData
class_name InputQueueData

var input : int = 0
var is_released : bool = false
var held_frames = 0

func set_data_with_obj(other_obj):
	input = other_obj.input
	is_released = other_obj.is_released
	held_frames = other_obj.held_frames
	frame = other_obj.frame

func set_obj_with_data(other_obj):
	other_obj.input = input
	other_obj.is_released = is_released
	other_obj.held_frames = held_frames
	other_obj.frame = frame

func matches(other_obj) -> bool:
	return (
	(ModularDataComparer.compare_values(input, other_obj.input) == true) and
	(ModularDataComparer.compare_values(is_released, other_obj.is_released) == true) and
	(ModularDataComparer.compare_values(held_frames, other_obj.held_frames) == true) and
	(ModularDataComparer.compare_values(frame, other_obj.frame) == true)
	)
