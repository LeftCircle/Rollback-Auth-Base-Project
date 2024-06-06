extends RefCounted
class_name TimerData

var current_frames : int = 0
var wait_frames : int = 0
var is_running : bool = false
var autostart = false

func set_data_with_obj(other_obj): 
	current_frames = other_obj.current_frames
	wait_frames = other_obj.wait_frames
	is_running = other_obj.is_running
	autostart = other_obj.autostart

func set_obj_with_data(other_obj): 
	other_obj.current_frames = current_frames
	other_obj.wait_frames = wait_frames
	other_obj.is_running = is_running
	other_obj.autostart = autostart

func matches(other_obj) -> bool: 
	return (
	(ModularDataComparer.compare_values(current_frames, other_obj.current_frames) == true) and
	(ModularDataComparer.compare_values(wait_frames, other_obj.wait_frames) == true) and
	(ModularDataComparer.compare_values(is_running, other_obj.is_running) == true) and
	(ModularDataComparer.compare_values(autostart, other_obj.autostart) == true)
	)
