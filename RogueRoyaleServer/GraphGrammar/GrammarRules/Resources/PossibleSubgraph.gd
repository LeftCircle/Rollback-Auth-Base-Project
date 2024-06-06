extends Resource
class_name PossibleSubgraph

var subgraph_array = []
var rule_zero_match : Dictionary
var rule_one_match : Dictionary
var starting_node_graph : GrammarNode
var ending_node_graph : GrammarNode

func add_new_node(graph_node, rule_node) -> void:
	var dict = {
		"GraphNode" : graph_node,
		"RuleNode" : rule_node
	}
	_check_for_rule_0_or_1(dict)
	_check_for_starting_and_ending_node(graph_node, rule_node)
	subgraph_array.append(dict)

func copy(other_subgraph : PossibleSubgraph):
	subgraph_array = other_subgraph.subgraph_array.duplicate(true)
	rule_zero_match = other_subgraph.rule_zero_match
	rule_one_match = other_subgraph.rule_one_match
	starting_node_graph = other_subgraph.starting_node_graph
	ending_node_graph = other_subgraph.ending_node_graph

func _check_for_rule_0_or_1(dict : Dictionary) -> void:
	if dict["RuleNode"].node_info.node_number == 0:
		rule_zero_match = dict
	elif dict["RuleNode"].node_info.node_number == 1:
		rule_one_match = dict

func _check_for_starting_and_ending_node(graph_node, rule_node) -> void:
	if rule_node.node_info.is_starting_node:
		starting_node_graph = graph_node
	elif rule_node.node_info.is_ending_node:
		ending_node_graph = graph_node

func get_node_to_check(rule_node):
	for dict in subgraph_array:
		if dict["RuleNode"] == rule_node:
			return dict["GraphNode"]
	return null

func get_angle_to_rotate_rule() -> float:
	var graph_v = rule_zero_match["GraphNode"].get_global_position().direction_to(rule_one_match["GraphNode"].get_global_position())
	var rule_v = rule_zero_match["RuleNode"].get_global_position().direction_to(rule_one_match["RuleNode"].get_global_position())
	return rule_v.angle_to(graph_v)

func get_angle_to_rotate_rule_data() -> float:
	var graph_v = rule_zero_match["GraphNode"].position.direction_to(rule_one_match["GraphNode"].position)
	var rule_v = rule_zero_match["RuleNode"].position.direction_to(rule_one_match["RuleNode"].position)
	return rule_v.angle_to(graph_v)

# TO DO -> these functions are stupid slow
func has_graph_node(graph_node) -> bool:
	for dict in subgraph_array:
		if dict["GraphNode"] == graph_node:
			return true
	return false

func has_rule_node(rule_node) -> bool:
	for dict in subgraph_array:
		if dict["RuleNode"] == rule_node:
			return true
	return false

func get_starting_graph_node():
	return starting_node_graph

func get_starting_rule_node():
	return subgraph_array[0]["RuleNode"]

func get_subgraph_center():
	var center = Vector2.ZERO
	for dict in subgraph_array:
		center += dict["GraphNode"].get_global_position()
	return center / subgraph_array.size()

func get_subgraph_center_data():
	var center = Vector2.ZERO
	for dict in subgraph_array:
		center += dict["GraphNode"].position
	return center / subgraph_array.size()

func get_shift_amount():
	return rule_zero_match["GraphNode"].get_global_position() - rule_zero_match["RuleNode"].get_global_position()

func log_p_subgraph():
	Logging.log_line("\n Potential subgraph: " + self.to_string())
	Logging.log_line(str(subgraph_array) + " Size = " + str(subgraph_array.size()))
	for dict in subgraph_array:
		Logging.log_line(" Graph Node = ")
		dict["GraphNode"].log_node()
		Logging.log_line(" Rule Node = ")
		dict["RuleNode"].log_node()

func get_springs_connecting_graph_nodes() -> Array:
	var springs = []
	var graph_nodes = get_graph_nodes()
	var n_nodes = graph_nodes.size()
	for i in range(n_nodes - 1):
		for spring in graph_nodes[i].springs:
			if not spring in springs:
				for j in range(i + 1, n_nodes):
					if spring.is_connected_to_node(graph_nodes[j]):
						springs.append(spring)
						break
	return springs

func get_graph_nodes() -> Array:
	var nodes = []
	for dict in subgraph_array:
		nodes.append(dict["GraphNode"])
	return nodes

func is_valid() -> bool:
	if not is_instance_valid(starting_node_graph):
		starting_node_graph = get_starting_node_or_null()
	if not is_instance_valid(ending_node_graph):
		ending_node_graph = get_ending_node_or_null()
	if not is_instance_valid(starting_node_graph) or not is_instance_valid(ending_node_graph):
		return false
	var start_closer_than_end = starting_node_graph.node_info.dist_from_closest_spawn <= ending_node_graph.node_info.dist_from_closest_spawn
	var same_closest_spawn = nodes_have_same_closest_spawn(starting_node_graph, ending_node_graph)
	return start_closer_than_end and same_closest_spawn

func nodes_have_same_closest_spawn(starting_node : GrammarNode, ending_node : GrammarNode) -> bool:
	for nearest_spawn in starting_node.node_info.closest_spawn_nodes:
		if nearest_spawn in ending_node.node_info.closest_spawn_nodes:
			return true
	return false

func get_starting_node_or_null():
	for node_pairs in subgraph_array:
		if node_pairs["RuleNode"].node_info.is_starting_node:
			return node_pairs["GraphNode"]
	return null

func get_ending_node_or_null():
	for node_pairs in subgraph_array:
		if node_pairs["RuleNode"].node_info.is_ending_node:
			return node_pairs["GraphNode"]
	return null
