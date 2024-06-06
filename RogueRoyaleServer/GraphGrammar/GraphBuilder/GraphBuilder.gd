extends Node2D
class_name GraphBuilder

@export var wait_time_between_graph_replacement = 5 # (float, 0.1, 5)

@export var server_char: PackedScene

var grammar_data : GRuleInfoReader
var grammar_save = GrammarSaveInfo.new()
var rule_applier = GrammarRuleApplier.new()

@onready var starting_viewer = $StartingViewer
@onready var grammar_graph = $GrammarGraph
@onready var rule_selector = $RuleSelector
@onready var rule_viewer = $RuleViewer
@onready var apply_rules_button = $ApplyRulesButton
@onready var node_container = $NodeContainer
@onready var spring_container = $SpringContainer
@onready var save_button = $SaveButton
@onready var final_save_gui = $FinalSaveGUI
@onready var g_name_line_edit = $GrammarName

func _ready():
	var room_path_locations = RoomPathLocations.new()
	room_path_locations.set_floor_to_load("FirstFloor")
	rule_applier.set_room_paths(room_path_locations)
	add_child(rule_applier)
	starting_viewer.connect("start_rule_selected",Callable(self,"_on_start_condition_selected"))
	rule_selector.connect("add_rule_pressed",Callable(self,"_on_add_rule_pressed"))
	rule_viewer.connect("rule_selected",Callable(self,"_on_rule_selected"))

func _on_start_condition_selected(starting_rule : GRuleInfoReader) -> void:
	grammar_save.set_starting_save(starting_rule.get_rule_save())
	grammar_data = starting_rule
	rule_selector.show()
	apply_rules_button.show()

func _on_add_rule_pressed():
	rule_selector.hide()
	apply_rules_button.hide()
	_hide_starting_viewer()
	rule_viewer.show()
	rule_viewer.show_file_browser()

func _hide_starting_viewer():
	starting_viewer.free_graph_nodes()
	starting_viewer.hide()

func _on_rule_selected(rule : Resource) -> void:
	_hide_rule_viewer()
	rule_selector.add_new_rule_selection(rule)
	rule_selector.show()
	apply_rules_button.show()
	starting_viewer.show()

func _hide_rule_viewer():
	rule_viewer.hide()
	rule_viewer.free_graph_nodes()

func _on_ApplyRulesButton_pressed():
	add_child(server_char.instantiate())
	g_name_line_edit.show()
	save_button.show()
	grammar_save.set_rule_saves(rule_selector.get_rule_saves())
	rule_selector.hide()
	apply_rules_button.hide()
	_hide_starting_viewer()
	_apply_rules()

func _apply_rules():
	rule_applier.apply_rules(node_container, spring_container, grammar_data, rule_selector.get_active_rules())
	save_button.show()

func _on_FinalSaveGUI_dir_selected(dir):
	_save_grammar(dir)

func _save_grammar(dir) -> void:
	if not g_name_line_edit.text == "":
		var data_path_file = dir + "/" + g_name_line_edit.text + "_grammar.res"
		ResourceSaver.save(data_path_file, grammar_save)

func _on_SaveButton_pressed():
	final_save_gui.show()
