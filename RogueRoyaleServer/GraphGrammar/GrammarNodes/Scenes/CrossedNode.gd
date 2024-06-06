extends LoadedNode
class_name CrossedNode

var crossed_path_a : Array
var crossed_path_b : Array

func set_crossed_paths(spring_a, spring_b):
	crossed_path_a = [spring_a.g_node_a, spring_a.g_node_b]
	crossed_path_b = [spring_b.g_node_a, spring_b.g_node_b]
