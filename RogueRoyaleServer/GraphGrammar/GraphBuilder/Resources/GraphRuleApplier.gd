#extends RefCounted
#class_name GraphRuleApplier
#
## Once a graph has been established and the rules chosen, this will apply
## the rules based on the graph
#
#var starting_rules : Array = []
#var grammar_data : GRuleInfoReader
#var current_rule : GRuleInfoReader
#
#
#func apply_graph_rule():
#	var array_of_rules = starting_rules.duplicate(true)
#	if array_of_rules.is_empty():
#		_finished_applying_rules()
#		return
#	var subgraph_n_rule = _get_random_matching_subgraph_and_rule(array_of_rules)
#	if subgraph_n_rule.is_empty():
#		_finished_applying_rules()
#		return
#	var subgraph = subgraph_n_rule[0]
#	var rule = subgraph_n_rule[1]
#	grammar_data = apply_rule(rule, subgraph)
#	_add_child_nodes()
#
#func _get_random_matching_subgraph_and_rule(current_array_of_rules : Array):
#	if current_array_of_rules.is_empty():
#		return []
#	var n_rules = current_array_of_rules.size()
#	var random_rule = current_array_of_rules[Map.map_rng.randi() % n_rules]
#	var subgraphs = subgraph_finder.find_subgraphs(grammar_data, random_rule)
#	if subgraphs.is_empty():
#		current_array_of_rules.erase(random_rule)
#		return _get_random_matching_subgraph_and_rule(current_array_of_rules)
#	return [subgraphs[Map.map_rng.randi() % subgraphs.size()], random_rule]
#
#func apply_rule(rule : GRuleInfoReader, subgraph : PossibleSubgraph):
#	current_rule = rule
#	current_rule.prep_rule_for_graph(nodes_to_rooms)
#	current_rule.compress_nodes()
#	_match_rule_to_graph(subgraph)
#	_decrement_rule_executions()
#	_number_new_nodes()
#	_update_grammar_data()
#	current_rule.reset_rule()
#	return grammar_data
#
#func _add_child_nodes():
#	var old_springs = spring_container.get_children()
#	var old_nodes = node_container.get_children()
#	_remove_unused_nodes_and_springs(old_nodes, old_springs)
#	_add_new_nodes_and_springs(old_nodes, old_springs)
#
#func _remove_unused_nodes_and_springs(old_nodes, old_springs):
#	for old_node in old_nodes:
#		if not old_node in grammar_data.LHS_nodes:
#			if is_instance_valid(old_node.room_scene):
#				old_node.room_scene.queue_free()
#			old_node.queue_free()
#	for old_spring in old_springs:
#		if not old_spring in grammar_data.LHS_springs:
#			old_spring.queue_free()
#
#func _add_new_nodes_and_springs(old_nodes, old_springs):
#	for spring in grammar_data.LHS_springs:
#		if not spring in old_springs:
#			spring_container.add_child(spring)
#	for node in grammar_data.LHS_nodes:
#		node.state = node.LOADED
#		if not node in old_nodes:
#			if nodes_to_rooms:
#				room_path_locations.assign_room_to_node(node)
#				node.set_node_size(node.room_scene.border_rect2.size)
#			node_container.add_child(node)
#
## This function will have to be modified to either emit a signal or return
## that it is completed so that the parent class can get to the correct state
#func _finished_applying_rules():
#	state = PULLING
#	physics_process_counter = -1
#	for spring in grammar_data.LHS_springs:
#		spring.call_deferred("queue_collisions_free")
