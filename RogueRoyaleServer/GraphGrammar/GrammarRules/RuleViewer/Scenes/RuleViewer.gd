extends Node2D

@export var grammar_node_scene: Resource
@export var loaded_node_scene: Resource
@export var rule_info_reader: Script
var rule_save : Resource
var grammar_rule : GRuleInfoReader
var rule_for_child_nodes : GRuleInfoReader

@onready var add_child_nodes_funcref = funcref(self, "_add_child_nodes")
@onready var add_child_springs_funcref = funcref(self, "_add_child_springs")
@onready var file_browser = $FileBrowser
@onready var back_button = $BackButton
@onready var lhs = $LHS
@onready var rhs = $RHS
@onready var select_rule_button = $SelectRuleButton

signal rule_selected(rule_data)

func _ready():
	if self.visible:
		file_browser.show()

func _process(_delta):
	if not self.visible and file_browser.visible:
		file_browser.hide()

func show_file_browser():
	file_browser.show()

func _on_FileBrowser_file_selected(path):
	rule_for_child_nodes = rule_info_reader.new()
	back_button.show()
	select_rule_button.show()
	var file = File.new()
	if file.file_exists(path):
		rule_save = load(path)
		grammar_rule = rule_info_reader.new()
		grammar_rule.connect_reader_to_rule(rule_save)
		rule_for_child_nodes.connect_reader_to_rule(rule_save)
		PhysicsFunctions.execute_func(add_child_nodes_funcref, [rule_for_child_nodes])
		PhysicsFunctions.execute_func(add_child_springs_funcref, [rule_for_child_nodes])
	file.close()

func _add_child_nodes(rule : GRuleInfoReader) -> void:
	for node in rule.LHS_nodes:
		lhs.add_child(node)
		node.state = node.LOADED
	for node in rule.RHS_nodes:
		rhs.add_child(node)
		#rhs.call_deferred("add_child", node)
		node.state = node.LOADED

func _add_child_springs(rule : GRuleInfoReader) -> void:
	for spring in rule.LHS_springs:
		lhs.add_child(spring)
	for spring in rule.RHS_springs:
		rhs.add_child(spring)
		#rhs.call_deferred("add_child", spring)

func _on_BackButton_pressed():
	back_button.hide()
	select_rule_button.hide()
	free_graph_nodes()
	file_browser.show()

func free_graph_nodes():
	var nodes_and_springs = lhs.get_children() + rhs.get_children()
	for obj in nodes_and_springs:
		obj.call_deferred("queue_free")

func _on_SelectRuleButton_pressed():
	emit_signal("rule_selected", grammar_rule)

func _exit_tree():
	if is_instance_valid(grammar_rule):
		grammar_rule.free_resource()
	if is_instance_valid(rule_for_child_nodes):
		rule_for_child_nodes.free_resource()
