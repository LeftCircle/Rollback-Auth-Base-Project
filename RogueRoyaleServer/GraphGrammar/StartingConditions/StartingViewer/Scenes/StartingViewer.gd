extends Node2D

@export var loaded_node_scene: Resource
@export var rule_info_reader: Script

var grammar_rule : GRuleInfoReader
var rule_for_child_nodes : GRuleInfoReader
var start_save : Resource
@onready var file_browser = $FileBrowser
@onready var back_button = $BackButton
@onready var starting_container = $StartingScene
@onready var select_start_button = $SelectStartButton

signal start_rule_selected(start_data)

func _ready():
	if self.visible:
		file_browser.show()

func view_lhs_from_rule_reader(rule_reader) -> void:
	var node_array = rule_reader.LHS_nodes
	for node in node_array:
		starting_container.add_child(node)

func _on_FileBrowser_file_selected(path):
	rule_for_child_nodes = rule_info_reader.new()
	back_button.show()
	select_start_button.show()
	var file = File.new()
	if file.file_exists(path):
		start_save = load(path)
		grammar_rule = rule_info_reader.new()
		grammar_rule.connect_reader_to_rule(start_save)
		rule_for_child_nodes.connect_reader_to_rule(start_save)
		PhysicsFunctions.execute_func(funcref(self, "_add_child_nodes"), [rule_for_child_nodes])
		PhysicsFunctions.execute_func(funcref(self, "_add_child_springs"), [rule_for_child_nodes])
	file.close()

func _add_child_nodes(rule : GRuleInfoReader) -> void:
	for node in rule.LHS_nodes:
		starting_container.add_child(node)
		node.state = node.LOADED

func _add_child_springs(rule : GRuleInfoReader) -> void:
	for spring in rule.LHS_springs:
		starting_container.add_child(spring)

func _on_BackButton_pressed():
	back_button.hide()
	select_start_button.hide()
	free_graph_nodes()
	file_browser.show()

func free_graph_nodes():
	var nodes_and_springs = starting_container.get_children()
	for obj in nodes_and_springs:
		#obj.call_deferred("queue_free")
		obj.queue_free()

func _on_SelectStartButton_pressed():
	back_button.call_deferred("queue_free")
	select_start_button.call_deferred("queue_free")
	emit_signal("start_rule_selected", grammar_rule)

func _exit_tree():
	if is_instance_valid(grammar_rule):
		grammar_rule.free_resource()
	if is_instance_valid(rule_for_child_nodes):
		rule_for_child_nodes.free_resource()
