extends GutTest

var region_from_grammar_path = "res://Scenes/Map/regionGeneration/RegionFromGrammar/RegionFromGrammar.tscn"
var test_closest_spawn_resource = "res://Scenes/Map/regionGeneration/RegionFromGrammar/GrammarSaves/TestFloor/testclosestspawn_grammar.res"

func test_is_instance_valid() -> void:
	var region_from_grammar = _spawn_region_from_grammar()
	assert_true(is_instance_valid(region_from_grammar))
	region_from_grammar.queue_free()

func test_get_spawn_nodes_from_GRuleInfoReader() -> void:
	var test_reader = GRuleInfoReader.new()
	var test_closest_spawn = load(test_closest_spawn_resource)
	test_reader.connect_reader_to_rule(test_closest_spawn.starting_save)
	var spawn_nodes = test_reader.get_lhs_nodes_of_room_type("SpawnRooms")
	assert_true(spawn_nodes.size() == 2)

func test_distance_from_spawn() -> void:
	var test_reader = GRuleInfoReader.new()
	var test_closest_spawn = load(test_closest_spawn_resource)
	test_reader.connect_reader_to_rule(test_closest_spawn.starting_save)
	var dist_from_spawn_setter = GrammarDistanceFromSpawnSetter.new()
	dist_from_spawn_setter.set_distance_from_closest_spawn(test_reader)
	var node_2 = test_reader.get_node(2, "LHS")
	assert_true(test_reader.get_node(0, "LHS").node_info.dist_from_closest_spawn == 0)
	assert_true(test_reader.get_node(2, "LHS").node_info.dist_from_closest_spawn == 1)
	assert_true(test_reader.get_node(4, "LHS").node_info.dist_from_closest_spawn == 3)
	assert_true(test_reader.get_node(5, "LHS").node_info.dist_from_closest_spawn == 1)
	assert_true(test_reader.get_node(6, "LHS").node_info.dist_from_closest_spawn == 4)
	assert_true(test_reader.get_node(2, "LHS").node_info.closest_spawn_nodes.size() == 2)

func _spawn_region_from_grammar(test_path : String = ""):
	var region_from_grammar = load(region_from_grammar_path).instantiate()
	if not test_path == "":
		region_from_grammar.is_test = true
		region_from_grammar.grammar_path_to_test = test_path
	ObjectCreationRegistry.add_child(region_from_grammar)
	return region_from_grammar

func _build_closest_spawn_test_grammar(region_from_grammar):
	# Spawns rooms in the following shape:
	#B(6) - B(4) - B(7)
	#        |
	# B(5) - B(3)
	# |      |
	# S(1) - B(2) - S(0)
	var rule_saves = []
	var grammar_data = GRuleInfoReader.new()
	grammar_data.connect_reader_to_rule(load(test_closest_spawn_resource))
	region_from_grammar.rule_applier.apply_rules_from_array(region_from_grammar.node_container, region_from_grammar.spring_container, grammar_data, rule_saves)
