extends Node2D
class_name GraphGrammarRuleMaker

const GRID_SIZE = 16

@export_dir var path_to_save_data# setget set_path_to_save_data # (String, DIR)
@export var grammar_node: Resource : set = set_grammar_node
@export var grammar_rule_save_class: Script

var starting_rule_node = null
var ending_rule_node = null

@onready var lhs = $LHS
@onready var spring_container = $SpringContainer
@onready var rhs = $RHS
@onready var save_button = $SaveRuleButton
@onready var rule_name = $RuleName
@onready var nodes_to_save = [lhs, rhs, spring_container]

func set_grammar_node(g_node_scene : Resource) -> void:
	grammar_node = g_node_scene

func set_path_to_save_data(path : String) -> void:
	path_to_save_data = path

func _ready():
	pass

func _on_NewLHSButton_button_down():
	var new_node = grammar_node.instantiate()
	new_node.connect("starting_node_updated",Callable(self,"_on_starting_node_updated"))
	new_node.connect("ending_node_updated",Callable(self,"_on_ending_node_updated"))
	new_node.position = Vector2.ONE * GRID_SIZE * 5
	_number_node(lhs, new_node)
	lhs.add_child(new_node)
	new_node.set_owner(self)

func _on_NewRHSButton_button_down():
	var new_node = grammar_node.instantiate()
	_number_node(rhs, new_node)
	new_node.position = Vector2(GRID_SIZE * 35, GRID_SIZE * 5)
	rhs.add_child(new_node)
	new_node.set_owner(self)

func _number_node(side : Node, grammar_node) -> void:
	if side == lhs:
		_number_lhs_node(grammar_node)
	else:
		grammar_node.set_node_number(rhs.get_children().size())

func _number_lhs_node(grammar_node) -> void:
	var num = lhs.get_children().size()
	grammar_node.set_node_number(num)
	if num == 0:
		_set_starting_rule_node(grammar_node)

func _set_starting_rule_node(node : GrammarNode) -> void:
	if starting_rule_node != null:
		starting_rule_node.set_starting_rule_node(false)
	starting_rule_node = node
	starting_rule_node.set_starting_rule_node(true)

func _set_ending_rule_node(node : GrammarNode) -> void:
	if ending_rule_node != null:
		ending_rule_node.set_ending_rule_node(false)
	if is_instance_valid(node):
		ending_rule_node = node
		ending_rule_node.set_ending_rule_node(true)

func _on_SaveRuleButton_pressed():
	# TODO -> confirm that the rule does not already exist
	if not rule_name.text == "" and not ending_rule_node == null:
		set_process(false)
		set_physics_process(false)
		_remove_unecessary_nodes()
		_save_node_data(path_to_save_data)
		_set_node_states_to_saved()
	else:
		print("Set an end rule node and name the rule!")

func _set_node_states_to_saved():
	var all_nodes = lhs.get_children() + rhs.get_children()
	for node in all_nodes:
		node.state = node.SAVED

func _save_node_data(path_to_save_data : String) -> void:
	var save = grammar_rule_save_class.new()
	save.rule_name = rule_name.text
	save.LHS_node_info_array = _get_node_info_array("LHS")
	save.RHS_node_info_array = _get_node_info_array("RHS")
	var data_path_file = path_to_save_data + "/" + rule_name.text + "_data.res"
	ResourceSaver.save(data_path_file, save)

func _expand_nodes():
	var rhs_nodes = rhs.get_children()
	var rhs_center = get_rhs_center(rhs_nodes)
	for node in rhs_nodes:
		_move_nodes_away_from_center(node, rhs_center)

func _get_max_distance_from_center(nodes : Array, center : Vector2) -> Vector2:
	var max_distance = Vector2.ZERO
	for node in nodes:
		var center_to_node = node.get_global_position() - center
		if max_distance.length_squared() < center_to_node.length_squared():
			max_distance = center_to_node
	return max_distance

func get_rhs_center(RHS_nodes : Array):
	var rhs_center = Vector2.ZERO
	for node in RHS_nodes:
		rhs_center += node.get_global_position()
	rhs_center /= RHS_nodes.size()
	return rhs_center

func _move_nodes_towards_center(nodes : Array, center : Vector2, max_vector : Vector2) -> void:
	for node in nodes:
		var center_to_node = node.get_global_position() - center
		var scale_f = center_to_node.length_squared() / max_vector.length_squared()
		center_to_node = center_to_node.normalized() * scale_f
		node.set_global_position(center + center_to_node)

func _move_nodes_away_from_center(node, center):
	var center_to_node = node.get_global_position() - center
	center_to_node *= 10
	node.set_global_position(center + center_to_node)

func _get_node_info_array(rule_side : String) -> Array:
	var side = lhs if rule_side == "LHS" else rhs
	var info_array = []
	for node in side.get_children():
		info_array.append(node.get_save_data())
	return info_array

func _remove_unecessary_nodes():
	for node in get_children():
		if not node in nodes_to_save:
			node.set_owner(null)
			node.call_deferred("queue_free")
	await get_tree().create_timer(0.2).timeout

func get_lhs_node(node_number : int):
	for node in lhs.get_children():
		if node.node_info.node_number == 0:
			return node
	assert(false) #,"Node " + str(node_number) + " does not exist on lhs")
	return null

func _on_starting_node_updated(new_node : GrammarNode) -> void:
	var new_starting_node = new_node.node_info.is_starting_node
	if new_starting_node:
		_set_starting_rule_node(new_node)
	else:
		var zero_node = get_lhs_node(0)
		_set_starting_rule_node(zero_node)

func _on_ending_node_updated(new_node : GrammarNode) -> void:
	var new_ending_node = new_node.node_info.is_ending_node
	if new_ending_node:
		_set_ending_rule_node(new_node)
	else:
		_set_ending_rule_node(null)


#func _on_get_spring_container(calling_node : GrammarNode) -> void:
#	calling_node.spring_container = spring_container
