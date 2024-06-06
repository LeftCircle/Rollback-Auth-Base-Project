extends RefCounted
class_name GrammarSubgraphRenumberer

# node # to grammar node
var original_rule_map = {}
var rule : GRuleInfoReader
var graph : GRuleInfoReader
var subgraph : PossibleSubgraph

func _reset():
	original_rule_map.clear()

func renumber_rule_nodes_for_graph(new_rule : GRuleInfoReader, new_subgraph : PossibleSubgraph, new_graph : GRuleInfoReader) -> void:
	_reset()
	rule = new_rule
	graph = new_graph
	subgraph = new_subgraph
	_init_original_rule_map_for_testing()
	_renumber_rule_nodes_for_graph()

func _init_original_rule_map_for_testing():
	for node in rule.get_nodes_for_side("RHS"):
		original_rule_map[node.node_info.node_number] = node

func _renumber_rule_nodes_for_graph():
	_renumber_new_nodes_in_rule()
	# Must occur second
	_renumber_rule_nodes_in_graph()

func _renumber_new_nodes_in_rule():
	var max_graph_node_number = graph.get_max_node_number()
	var new_rule_nodes = _get_rule_nodes_greater_than_max_lhs_number()
	for node in new_rule_nodes:
		max_graph_node_number += 1
		node.set_node_number(max_graph_node_number)

func _get_rule_nodes_greater_than_max_lhs_number():
	var max_lhs_node_number = rule.get_max_node_number("LHS")
	var rule_nodes_greater_than_max_lhs_number = []
	for node in rule.get_nodes_for_side("RHS"):
		if node.node_info.node_number > max_lhs_node_number:
			rule_nodes_greater_than_max_lhs_number.append(node)
	return rule_nodes_greater_than_max_lhs_number

func _renumber_rule_nodes_in_graph():
	for graph_rule_match in subgraph.subgraph_array:
		var graph_node = graph_rule_match["GraphNode"]
		var rule_node = graph_rule_match["RuleNode"]
		var rhs_rule_node = original_rule_map[rule_node.node_info.node_number]
		rhs_rule_node.set_node_number(graph_node.node_info.node_number)



