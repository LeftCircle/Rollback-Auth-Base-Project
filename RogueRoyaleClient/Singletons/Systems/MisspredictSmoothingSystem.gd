extends Node
# MissPredictSmoothingSystem

func execute_normal_frame() -> void:
	var smoothers = get_tree().get_nodes_in_group("NewMisspredictSmoothing")
	for smoother in smoothers:
		smoother.execute()

#func execute_corrected_frame() -> void:
#	var smoothers = get_tree().get_nodes_in_group("NewMisspredictSmoothing")
#	for smoother in smoothers:
#		smoother.add_position_to_smooth(smoother.parent.global_position)
