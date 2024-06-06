extends Resource
class_name RuleDoubleBuffer
# Handles deleting springs and nodes from a graph, or reverting back to the 
# previous state if the springs overlap

var old_lhs_springs : Array
var old_lhs_nodes : Array
var new_lhs_springs : Array
var new_lhs_nodes : Array
var old_node_positions : Dictionary

func add_new_spring(spring : GrammarSpring) -> void:
	new_lhs_springs.append(spring)

func add_new_node(node : LoadedNode) -> void:
	new_lhs_nodes.append(node)

func swap_buffer():
	old_lhs_nodes = new_lhs_nodes.duplicate(true)
	old_lhs_springs = new_lhs_springs.duplicate(true)

func set_old_springs(springs : Array) -> void:
	old_lhs_springs = springs

func set_old_nodes(nodes : Array) -> void:
	old_lhs_nodes = nodes
	create_snapshot()

func set_new_nodes(nodes : Array) -> void:
	new_lhs_nodes = nodes

func set_new_lhs_springs(springs : Array) -> void:
	new_lhs_springs = springs
	create_snapshot()

func create_snapshot():
	old_node_positions.clear()
	for node in old_lhs_nodes:
		old_node_positions[node] = node.get_global_position()

func get_old_nodes():
	for node in old_lhs_nodes:
		node.set_node_global_position(old_node_positions[node])
	return old_lhs_nodes
