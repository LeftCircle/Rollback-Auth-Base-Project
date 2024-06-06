extends Node2D
class_name GrammarStartingCondition

@export var path_to_save_data setget set_path_to_save_data # (String, DIR)
@export var node_scene: Resource
@export var starting_save_class: Script

var n_nodes = 0

@onready var new_node_button = $NewNodeButton
@onready var save_button = $SaveButton
@onready var starting_name_line_edit = $StartingName
@onready var node_container = $StartingNodes
@onready var spring_container = $SpringContainer

func set_path_to_save_data(path : String) -> void:
	path_to_save_data = path

func _ready():
	pass

func _on_SaveButton_pressed():
	if starting_name_line_edit.text != "":
		_save_node_data(path_to_save_data)
		_set_node_states_to_saved()

func _set_node_states_to_saved():
	var all_nodes = node_container.get_children()
	for node in all_nodes:
		node.state = node.SAVED

func _save_node_data(data_path_folder : String) -> void:
	var all_nodes = node_container.get_children()
	var save = starting_save_class.new()
	for node in all_nodes:
		var data = node.get_save_data()
		save.LHS_node_info_array.append(data)
	var data_path_file = path_to_save_data + "/" + starting_name_line_edit.text + "_data.res"
	new_node_button.call_deferred("queue_free")
	save_button.call_deferred("queue_free")
	starting_name_line_edit.call_deferred("queue_free")
	$Title.call_deferred("queue_free")
	ResourceSaver.save(data_path_file, save)

func _on_NewNodeButton_pressed():
	var new_node = node_scene.instantiate()
	new_node.set_node_number(n_nodes)
	new_node.position = Vector2(64, 64)
	node_container.add_child(new_node)
	n_nodes += 1
