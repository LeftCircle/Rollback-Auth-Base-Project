extends Node2D

@export var grammar_spring : Resource : set = set_grammar_spring
@export var line: Resource : set = set_line

func set_line(res):
	line = res

func set_grammar_spring(res : Resource) -> void:
	grammar_spring = res

func _physics_process(_delta):
	var selected_nodes = get_tree().get_nodes_in_group("SelectedNodes")
	if selected_nodes.size() > 2:
		_deselect_nodes(selected_nodes)
	elif selected_nodes.size() == 2:
		if selected_nodes[0] != selected_nodes[1]:
			if selected_nodes[0].is_connected_to_node_number(selected_nodes[1].node_info.node_number):
				selected_nodes[0].disconnect_nodes(selected_nodes[1].node_info.node_number)
			else:
				var spring = grammar_spring.new()
				spring.connect_nodes(selected_nodes[0], selected_nodes[1])
				#spring.spring_as_line = true
				spring.allow_pull = true
				add_child(spring)
		_deselect_nodes(selected_nodes)

func _deselect_nodes(selected_nodes : Array):
	for node in selected_nodes:
		node.deselect_node()
