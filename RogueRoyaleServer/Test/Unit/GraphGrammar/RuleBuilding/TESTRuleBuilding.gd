extends GutTest

var rule_builder_scene_path = "res://GraphGrammar/GrammarRules/RuleMaker/GrammarRuleMaker.tscn"
var path_to_rules = "res://GraphGrammar/GrammarRules/GrammarRuleData/"

func test_init():
	var rule_builder = _spawn_rule_buider_scene()
	assert_true(is_instance_valid(rule_builder))
	rule_builder.queue_free()

func test_node_zero_is_first_node():
	var rule_builder = _spawn_rule_buider_scene()
	_spawn_new_node(rule_builder)
	var node_zero = rule_builder.get_lhs_node(0)
	assert_true(node_zero.node_info.is_starting_node == true)
	rule_builder.queue_free()

func test_all_rules_have_start_and_finish():
	var rules = _get_all_rule_resources_paths()
	var do_all_rules_have_start_and_finish = true
	for rule in rules:
		if not _does_rule_have_start_and_finish(rule):
			print("Rule: " + rule + " does not have a start and finish")
			do_all_rules_have_start_and_finish = false
	assert_true(do_all_rules_have_start_and_finish)

func _does_rule_have_start_and_finish(rule : String) -> bool:
	var rule_save = load(rule)
	var grammar_data = GRuleInfoReader.new()
	grammar_data.connect_reader_to_rule(rule_save)
	return grammar_data.has_start_and_finish()

func _get_all_rule_resources_paths() -> Array:
	var file_lister = FileLister.new()
	file_lister.folder_path = path_to_rules
	file_lister.file_ending = ".res"
	file_lister.load_resources()
	return file_lister.all_file_paths

func _spawn_new_node(rule_builder : GraphGrammarRuleMaker) -> void:
	rule_builder._on_NewLHSButton_button_down()

func _spawn_rule_buider_scene():
	var rule_builer = load(rule_builder_scene_path).instantiate()
	ObjectCreationRegistry.add_child(rule_builer)
	return rule_builer
