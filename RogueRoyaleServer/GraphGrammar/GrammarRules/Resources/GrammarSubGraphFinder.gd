extends RefCounted

var rule : GRuleInfoReader
var graph : GRuleInfoReader
var matching_nodes : MatchingRuleNodes
var p_subgraph_array : Array
var new_p_subgraph_array : Array

func find_subgraphs(new_graph : GRuleInfoReader, _rule : GRuleInfoReader):
	graph = new_graph
	rule = _rule
	p_subgraph_array = []
	new_p_subgraph_array = []
	matching_nodes = MatchingRuleNodes.new()
	matching_nodes.find_matching_nodes(graph, rule)
	_find_subgraphs()
	_remove_invalid_subgraphs()
	return p_subgraph_array

func _find_subgraphs():
	_find_all_nodes_matching_first_node_in_rule(0)
	# We need to check all but the last rule node ?
	var n_rule_nodes_to_check = rule.LHS_nodes.size() - 1
	for i in range(n_rule_nodes_to_check):
		var rule_node = rule.LHS_nodes[i]
		for rule_spring in rule_node.springs:
			_get_valid_subgraph_arrays(rule_node, rule_spring)
		p_subgraph_array = new_p_subgraph_array.duplicate(true)
		new_p_subgraph_array.clear()
	return p_subgraph_array

func _find_all_nodes_matching_first_node_in_rule(starting_rule_node_n : int):
	var node_matches = matching_nodes.matching_nodes[starting_rule_node_n]
	for node in node_matches.keys():
		var possible_subgraph = PossibleSubgraph.new()
		possible_subgraph.add_new_node(node, rule.get_node(starting_rule_node_n, "LHS"))
		p_subgraph_array.append(possible_subgraph)

func _get_valid_subgraph_arrays(rule_node, rule_spring) -> void:
	var conn_rule_node = rule_spring.get_other_node(rule_node)
	for i in range(p_subgraph_array.size() - 1, -1, -1):
		var node_to_check = p_subgraph_array[i].get_node_to_check(rule_node)
		if node_to_check == null:
			p_subgraph_array.remove(i)
			continue # Was a break for some reason?
		_extend_valid_subgraphs(i, conn_rule_node, node_to_check)

func _extend_valid_subgraphs(i, conn_rule_node, node_to_check):
	var nodes_to_check_against = matching_nodes.matching_nodes[conn_rule_node.node_info.node_number]
	var conn_graph_nodes = node_to_check.get_connected_nodes()
	for conn_node in conn_graph_nodes:
		if not p_subgraph_array[i].has_graph_node(conn_node):
			if conn_node in nodes_to_check_against:
				_create_new_p_subgrap(i, conn_node, conn_rule_node)
				#p_subgraph_array[i].add_new_node(conn_node, conn_rule_node)

func _remove_invalid_subgraphs():
	for i in range(p_subgraph_array.size() - 1, -1, -1):
		if not p_subgraph_array[i].is_valid():
			p_subgraph_array.remove(i)

func _create_new_p_subgrap(i : int, conn_node, conn_rule_node) -> void:
	var new_p_subgraph = PossibleSubgraph.new()
	new_p_subgraph.copy(p_subgraph_array[i])
	new_p_subgraph.add_new_node(conn_node, conn_rule_node)
	new_p_subgraph_array.append(new_p_subgraph)
