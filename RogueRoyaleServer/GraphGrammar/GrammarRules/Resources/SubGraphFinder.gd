extends Resource
class_name SubGraphFinder

var rule : GRuleInfoReader
var graph : GRuleInfoReader
var p_subgraph_array : Array
var full_possible_subgraphs : Array


func find_subgraphs(new_graph : GRuleInfoReader, _rule : GRuleInfoReader):
	graph = new_graph
	rule = _rule
	p_subgraph_array = []
	full_possible_subgraphs = []
	_find_subgraphs()
	return full_possible_subgraphs

func _find_subgraphs():
	_create_possible_subgraphs_for_nodes_matching_rule_start()
	for subgraph in p_subgraph_array:
		var starting_graph_node = subgraph.get_starting_graph_node()
		var starting_rule_node = subgraph.get_starting_rule_node()
		_step_through_possible_subgraph(subgraph, starting_rule_node, starting_graph_node)
	_remove_invalid_subgraphs()
	return p_subgraph_array

func _create_possible_subgraphs_for_nodes_matching_rule_start():
	var starting_node = rule.starting_node
	for graph_node in graph.get_nodes_for_side("LHS"):
		if graph_node.node_matches_node_for_rule(starting_node, rule):
			var possible_subgraph = PossibleSubgraph.new()
			possible_subgraph.add_new_node(graph_node, starting_node)
			p_subgraph_array.append(possible_subgraph)

func _step_through_possible_subgraph(possible_subgraph : PossibleSubgraph, current_rule_node : LoadedNode, current_subgraph_node : LoadedNode) -> void:
	# Check to see if the subgraph passes!
	if possible_subgraph.subgraph_array.size() == rule.LHS_nodes.size():
		full_possible_subgraphs.append(possible_subgraph)
		return
	# Find the neighbor nodes that match the next node in the rule. For each match, create a new possible subgraph
	var next_rule_nodes = current_rule_node.get_connected_nodes()
	var connected_graph_nodes = current_subgraph_node.get_connected_nodes()
	for next_rule_node in next_rule_nodes:
		if not possible_subgraph.has_rule_node(next_rule_node):
			_step_through_connected_nodes_if_rule_not_in_subgraph(possible_subgraph, next_rule_node, connected_graph_nodes)

func _step_through_connected_nodes_if_rule_not_in_subgraph(possible_subgraph : PossibleSubgraph, next_rule_node : LoadedNode, connected_graph_nodes : Array) -> void:
		# Check to see if the current subgraph has a connection that matches the next rule node, and confirm that this connection is not already in the subgraph
		for connected_graph_node in connected_graph_nodes:
			if not possible_subgraph.has_graph_node(connected_graph_node):
				_continue_stepping_if_subgraph_matches(possible_subgraph, next_rule_node, connected_graph_node)

func _continue_stepping_if_subgraph_matches(possible_subgraph : PossibleSubgraph, next_rule_node : LoadedNode, connected_graph_node : LoadedNode):
	if connected_graph_node.node_matches_node_for_rule(next_rule_node, rule):
		# Create a new possible subgraph
		var new_possible_subgraph = PossibleSubgraph.new()
		new_possible_subgraph.copy(possible_subgraph)
		new_possible_subgraph.add_new_node(connected_graph_node, next_rule_node)
		_step_through_possible_subgraph(new_possible_subgraph, next_rule_node, connected_graph_node)

func _remove_invalid_subgraphs():
	for i in range(full_possible_subgraphs.size() - 1, -1, -1):
		if not full_possible_subgraphs[i].is_valid():
			full_possible_subgraphs.remove_at(i)

