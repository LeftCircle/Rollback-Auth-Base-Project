extends Resource
class_name MatchingRuleNodes

# Creates a dict of the rule nodes where the key is another dict that contains all of the graph nodes that match the rule node
var matching_nodes = {}

func add_matching_node(graph_node, rule_node):
	matching_nodes[rule_node.node_info.node_number][graph_node] = null

func rule_has_node(rule_number, node) -> bool:
	if matching_nodes[rule_number].has(node):
		return true
	return false

func find_matching_nodes(graph : GRuleInfoReader, rule : GRuleInfoReader):
	for rule_node in rule.LHS_nodes:
		matching_nodes[rule_node.node_info.node_number] = {}
	for graph_node in graph.LHS_nodes:
		var matching_rule_nodes = graph_node.get_matching_nodes_in_rule(rule)
		for rule_node in matching_rule_nodes:
			var rule_node_n = rule_node.node_info.node_number
			matching_nodes[rule_node_n][graph_node] = null
