extends VisibleOnScreenNotifier2D
class_name SmoothingRegisterer

var node_to_smooth

func add_node_to_smooth(new_node_to_smooth) -> void:
	node_to_smooth = new_node_to_smooth
	self.connect("screen_entered", _on_screen_entered)
	self.connect("screen_exited", _on_screen_exited)

func _on_screen_entered():
	FrameSmoother.add_include_node(node_to_smooth)

func _on_screen_exited():
	FrameSmoother.remove_include_node(node_to_smooth)

func _exit_tree():
	FrameSmoother.remove_include_node(node_to_smooth)
