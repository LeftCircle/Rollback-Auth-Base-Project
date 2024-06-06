extends RefCounted
class_name GrammarDistanceFromSpawnSetter
# GDScript class that sets the distance from spawn for each node in the grammar.

var checked_nodes = []

func set_distance_from_closest_spawn(grammar : GRuleInfoReader) -> void:
	_reset_closest_spawn_info_for_all_nodes(grammar)
	var spawn_nodes = grammar.get_lhs_nodes_of_room_type("SpawnRooms")
	for spawn_node in spawn_nodes:
		spawn_node.node_info.dist_from_closest_spawn = 0
		checked_nodes.append(spawn_node.node_info.node_number)
		_set_distance_from_spawn_for_connected_nodes(spawn_node, spawn_node, 1)
		checked_nodes.clear()

func _set_distance_from_spawn_for_connected_nodes(current_node : GrammarNode, spawn_node : GrammarNode, distance_from_spawn : int) -> void:
	var connected_nodes = current_node.get_connected_nodes()
	for connected_node in connected_nodes:
		var has_not_been_checked = !checked_nodes.has(connected_node.node_info.node_number)
		_update_closest_spawn_info_for_node(connected_node, spawn_node, distance_from_spawn)
		if has_not_been_checked:
			checked_nodes.append(connected_node.node_info.node_number)
			_set_distance_from_spawn_for_connected_nodes(connected_node, spawn_node, distance_from_spawn + 1)

func _update_closest_spawn_info_for_node(node : GrammarNode, spawn_node : GrammarNode, distance_from_spawn) -> void:
	if distance_from_spawn <= node.node_info.dist_from_closest_spawn:
		if not node.node_info.closest_spawn_nodes.has(spawn_node):
			node.node_info.closest_spawn_nodes.append(spawn_node)
		node.node_info.dist_from_closest_spawn = distance_from_spawn

func _set_all_nodes_to_unchecked(grammar : GRuleInfoReader) -> void:
	var nodes = grammar.get_all_nodes()
	for node in nodes:
		node.set_checked_distance_from_spawn_checked(false)

func _reset_closest_spawn_info_for_all_nodes(grammar : GRuleInfoReader) -> void:
	var nodes = grammar.get_nodes_for_side("LHS")
	for node in nodes:
		node.node_info.dist_from_closest_spawn = 999999
		node.node_info.closest_spawn_nodes.clear()
