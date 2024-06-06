extends GutTest

var spawn_norm_norm_boss_lhs_path = "res://GraphGrammar/StartingConditions/StartingConditionData/s-n-n-b_data.res"
var n_n_to_cross_rule_path = "res://GraphGrammar/GrammarRules/GrammarRuleData/n-n_to_cross_data.res"
var n_n_to_k_n_n_lock_path = "res://GraphGrammar/GrammarRules/GrammarRuleData/n-n_to_k-n-n-l_data.res"
var region_from_grammar_path = "res://Scenes/Map/regionGeneration/RegionFromGrammar/RegionFromGrammar.tscn"

func test_find_subgraphs():
	var graph = _init_s_n_n_b()
	var rule = _init_n_n_to_cross()
	var subgraph_finder = SubGraphFinder.new()
	var actual_subgraphs = subgraph_finder.find_subgraphs(graph, rule)
	assert_true(actual_subgraphs.size() == 1)
	#rule.reset_rule()
	graph.free_resource()

func test_subgraph_renumberer():
	var graph = _init_s_n_n_b()
	var rule = _init_n_n_to_k_n_n_l()
	var subgraph_finder = SubGraphFinder.new()
	var actual_subgraphs = subgraph_finder.find_subgraphs(graph, rule)
	var possible_subgraph = actual_subgraphs[0]
	var subgraph_renumberer = GrammarSubgraphRenumberer.new()
	subgraph_renumberer.renumber_rule_nodes_for_graph(rule, possible_subgraph, graph)
	assert_true(subgraph_renumberer.original_rule_map[0].node_info.node_number == 1)
	assert_true(subgraph_renumberer.original_rule_map[1].node_info.node_number == 2)
	assert_true(subgraph_renumberer.original_rule_map[2].node_info.node_number == 4)
	assert_true(subgraph_renumberer.original_rule_map[3].node_info.node_number == 5)
	# Confirm that the springs are attached properly
	var new_node_1_connected_nodes = rule.get_node(1, "RHS").get_connected_nodes()
	assert_true(new_node_1_connected_nodes.size() == 1 and new_node_1_connected_nodes[0].node_info.node_number == 4)
	var new_node_2_connected_nodes = rule.get_node(2, "RHS").get_connected_nodes()
	assert_true(new_node_2_connected_nodes.size() == 1 and new_node_2_connected_nodes[0].node_info.node_number == 5)
	var new_node_4_connected_nodes = rule.get_node(4, "RHS").get_connected_nodes()
	assert_true(new_node_4_connected_nodes.size() == 2 and new_node_4_connected_nodes[0].node_info.node_number == 1)
	rule.reset_rule()
	graph.free_resource()

func test_find_subgraph_with_key_lock():
	var graph = _init_s_n_n_b()
	var rule = _init_n_n_to_k_n_n_l()
	var subgraph_finder = SubGraphFinder.new()
	var actual_subgraphs = subgraph_finder.find_subgraphs(graph, rule)
	var possible_subgraph = actual_subgraphs[0]
	assert_true(possible_subgraph.starting_node_graph.node_info.dist_from_closest_spawn == 1)
	# Now we have to actually apply the rule into the graph and confirm that the
	# node connected to the spawn node is a key
	#assert_true(false) # see below
	var region_from_grammar = _spawn_region_from_grammar()
	region_from_grammar.rule_applier.grammar_data = graph
	region_from_grammar.rule_applier.current_rule = rule
	region_from_grammar.rule_applier.apply_rule(rule, possible_subgraph)
	var spawn_node = graph.get_lhs_nodes_of_room_type("SpawnRooms")[0]
	assert_true(spawn_node.get_connected_nodes()[0].node_info.room_type == "Key")
	region_from_grammar.queue_free()
	rule.reset_rule()
	graph.free_resource()

func test_rooms_get_a_max_of_8_doors():
	# If you set up s-n-n-b and run multiple n-n_to_cross, the normal room gets too many doors
	assert_true(false, "Not yet implemented")

func _apply_rule_to_graph(rule: GRuleInfoReader, graph: GRuleInfoReader, subgraph : PossibleSubgraph, region_from_grammar) -> GRuleInfoReader:
	region_from_grammar.rule_applier.grammar_data = graph
	region_from_grammar.rule_applier.current_rule = rule
	region_from_grammar.rule_applier.apply_rule(rule, subgraph)
	return graph

func _init_s_n_n_b() -> GRuleInfoReader:
	var rule = load(spawn_norm_norm_boss_lhs_path)
	var rule_reader = GRuleInfoReader.new()
	rule_reader.connect_reader_to_rule(rule)
	var closest_spawn_setter = GrammarDistanceFromSpawnSetter.new()
	closest_spawn_setter.set_distance_from_closest_spawn(rule_reader)
	return rule_reader

func _init_n_n_to_cross() -> GRuleInfoReader:
	var rule = load(n_n_to_cross_rule_path)
	var rule_reader = GRuleInfoReader.new()
	rule_reader.connect_reader_to_rule(rule)
	# TO DO -> \/
	# For some reason, doing this breaks the closest spawn node array in _init_s_n_n_b
	#var closest_spawn_setter = GrammarDistanceFromSpawnSetter.new()
	#closest_spawn_setter.set_distance_from_closest_spawn(rule_reader)
	return rule_reader

func _init_n_n_to_k_n_n_l() -> GRuleInfoReader:
	var rule = load(n_n_to_k_n_n_lock_path)
	var rule_reader = GRuleInfoReader.new()
	rule_reader.connect_reader_to_rule(rule)
	#var closest_spawn_setter = GrammarDistanceFromSpawnSetter.new()
	#closest_spawn_setter.set_distance_from_closest_spawn(rule_reader)
	return rule_reader

func _spawn_region_from_grammar(test_path : String = ""):
	var region_from_grammar = load(region_from_grammar_path).instantiate()
	if not test_path == "":
		region_from_grammar.is_test = true
		region_from_grammar.grammar_path_to_test = test_path
	ObjectCreationRegistry.add_child(region_from_grammar)
	return region_from_grammar
