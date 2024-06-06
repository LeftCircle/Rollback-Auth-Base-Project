extends Node2D
class_name NewMissPredictSmoother

var positions_to_smooth = []

@onready var parent = get_parent()

func _ready():
	FrameSmoother.add_include_node(self)

func on_misspredict():
	positions_to_smooth.append(global_position)
	add_to_group("NewMisspredictSmoothing")
	#FrameSmoother.remove_include_node(parent)
	#FrameSmoother.add_include_node(self)

func add_position_to_smooth(new_position : Vector2) -> void:
	positions_to_smooth.append(new_position)

func execute() -> void:
	if positions_to_smooth.size() > 1:
		var smoothed_position = Vector2()
		for pos in positions_to_smooth:
			smoothed_position += pos
		smoothed_position /= positions_to_smooth.size()
		global_position = smoothed_position
		positions_to_smooth.pop_front()
		positions_to_smooth.pop_front()
		print("Misspredict frame array size = %s" % [positions_to_smooth.size()])
	else:
		remove_from_group("NewMisspredictSmoothing")
		#FrameSmoother.add_include_node(parent)
		#FrameSmoother.remove_include_node(self)
