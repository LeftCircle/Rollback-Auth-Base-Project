extends GrammarRuleInfo
class_name GRuleInfoReader

var LHS_nodes = []
var RHS_nodes = []
var LHS_springs = []
var RHS_springs = []
var og_data = {"LHS" : {}, "RHS" : {}, "NewConnections" : {}}
var rhs_center = null
var old_node_positions : Dictionary
var expansion_mod = 0.5
var starting_node = null
var ending_node = null

func connect_reader_to_rule(grammar_rule : GrammarRuleInfo) -> void:
	rule_name = grammar_rule.rule_name
	executions = grammar_rule.executions
	LHS_node_info_array = grammar_rule.LHS_node_info_array
	RHS_node_info_array = grammar_rule.RHS_node_info_array
	for old_node_info in grammar_rule.LHS_node_info_array:
		var loaded_node = LoadedNode.new()
		loaded_node.name = "LoadedNode_" + grammar_rule.rule_name
		loaded_node.load_node(old_node_info)
		starting_node = loaded_node if loaded_node.node_info.is_starting_node and starting_node == null else starting_node
		ending_node = loaded_node if loaded_node.node_info.is_ending_node and ending_node == null else ending_node
		add_node_to_side(loaded_node, "LHS")
		og_data["LHS"][loaded_node] = {
			"Number": loaded_node.node_info.node_number,
			"Position" : loaded_node.position
		}
	for old_node_info in grammar_rule.RHS_node_info_array:
		var loaded_node = LoadedNode.new()
		loaded_node.name = "LoadedNode_" + grammar_rule.rule_name
		loaded_node.load_node(old_node_info)
		add_node_to_side(loaded_node, "RHS")
		og_data["RHS"][loaded_node] = {
			"Number": loaded_node.node_info.node_number,
			"Position" : loaded_node.position
		}
	_build_new_connection_number_dict(grammar_rule)
	rebuild_spring_from_save("LHS")
	rebuild_spring_from_save("RHS")

func _build_new_connection_number_dict(grammar_rule : GrammarRuleInfo):
	for lhs_node in LHS_nodes:
		var rhs_node = get_node(lhs_node.node_info.node_number, "RHS")
		if is_instance_valid(rhs_node):
			var spring_diff = rhs_node.node_info.springs_info.size() - lhs_node.node_info.springs_info.size()
			og_data["NewConnections"][lhs_node] = spring_diff

func get_rule_save():
	var save = GrammarRuleInfo.new()
	save.executions = executions
	save.priority = priority
	save.LHS_node_info_array = LHS_node_info_array
	save.RHS_node_info_array = RHS_node_info_array
	save.rule_name = rule_name
	return save

func add_node_to_side(node, side : String) -> void:
	var nodes = get_nodes_for_side(side)
	nodes.append(node)

func log_reader():
	Logging.log_line("\n Rule reader for " + rule_name)
	Logging.log_line("LHS Nodes = " + str(LHS_nodes.size()))
	for node in LHS_nodes:
		node.log_node()
	Logging.log_line("\nLHS SPRINGS = ")
	for spring in LHS_springs:
		spring.log_spring()
	Logging.log_line("\nRHS Nodes = "+ str(RHS_nodes.size()))
	for node in RHS_nodes:
		node.log_node()
	Logging.log_line("\nRHS Springs = ")
	for spring in RHS_springs:
		spring.log_spring()

func rebuild_spring_from_save(side : String) -> void:
	var nodes = get_nodes_for_side(side)
	for node in nodes:
		for spring_info in node.node_info.springs_info:
			var node_n_a = spring_info.c_node_number_a
			var node_a = get_node(spring_info.c_node_number_a, side)
			var node_b = get_node(spring_info.c_node_number_b, side)
			var b_conn_nums = node_b.get_connected_node_numbers()
			if node_n_a in b_conn_nums:
				continue
			else:
				var new_spring = GrammarSpring.new()
				new_spring.connect_nodes(node_a, node_b)
				_add_spring_to_side(new_spring, side)

func _add_spring_to_side(spring, side : String) -> void:
	if side == "LHS":
		LHS_springs.append(spring)
	else:
		RHS_springs.append(spring)

func add_spring_to_side(spring, side : String) -> void:
	if side == "LHS":
		if not spring in LHS_springs:
			LHS_springs.append(spring)
	if side == "RHS":
		if not spring in RHS_springs:
			RHS_springs.append(spring)

func reconnect_duplicated_springs(side) -> void:
	var nodes = get_nodes_for_side(side)
	var rule_springs = get_springs(side)
	rule_springs.clear()
	for node in nodes:
		for spring in node.springs:
			var num_a = spring.spring_info.c_node_number_a
			var num_b = spring.spring_info.c_node_number_b
			var node_a = get_node(num_a, side)
			var node_b = get_node(num_b, side)
			spring.g_node_a = node_a
			spring.g_node_b = node_b
			if not spring in rule_springs:
				rule_springs.append(spring)

func get_springs(side : String) -> Array:
	if side == "LHS":
		return LHS_springs
	return RHS_springs

func get_node(node_number : int, side : String):
	var nodes = get_nodes_for_side(side)
	for node in nodes:
		if node.node_info.node_number == node_number:
			return node
	return null

func get_nodes_for_side(side : String) -> Array:
	if side == "LHS":
		return LHS_nodes
	return RHS_nodes

func get_node_numbers_for_side(side : String) -> Array:
	var node_numbers = []
	var nodes = get_nodes_for_side(side)
	for node in nodes:
		node_numbers.append(node.node_info.node_number)
	return node_numbers

#func prep_rule_for_graph(nodes_to_rooms : bool):
#	_number_nodes_for_graph()
#	#if nodes_to_rooms:
#	#	expand_nodes("RHS")
#
#func _number_nodes_for_graph():
#	var max_lhs_n = -INF
#	for node in LHS_nodes:
#		max_lhs_n = max(max_lhs_n, node.node_info.node_number)
#	var n_changed = 1
#	for node in RHS_nodes:
#		if node.node_info.node_number > max_lhs_n:
#			node.set_node_number(-n_changed)
#			n_changed += 1

func add_collision_exceptions(nodes : Array):
	var n_nodes = nodes.size()
	for node in nodes:
		if is_instance_valid(node.collision_box):
			node.collision_box.disabled = true
		else:
			node.set_disabled = true
	for i in range(n_nodes - 1):
		var node_i = nodes[i]
		for j in range(i + 1, n_nodes):
			var node_j = nodes[j]
			node_i.add_collision_exception_with(node_j)

func remove_collision_exceptions(nodes : Array):
	for node in nodes:
		node.collision_box.disabled = false
		var collision_exceptions = node.get_collision_exceptions()
		for exception in collision_exceptions:
			node.remove_collision_exception_with(exception)

func expand_nodes(side : String):
	var center = get_center(side)
	for node in RHS_nodes:
		_move_nodes_away_from_center(node, center)

func _move_nodes_away_from_center(node, center):
	var center_to_node = node.get_global_position() - center
	center_to_node *= ProjectSettings.get_setting("global/TILE_SIZE") * expansion_mod
	node.set_global_position(center + center_to_node)

func expand_LHS_nodes_away_from(point : Vector2, shift_amout : float) -> void:
	for node in LHS_nodes:
		var point_to_node = point.direction_to(node.position)
		#var x_shift = shift_amout * sign(point_to_node.x)
		#var y_shift = shift_amout * sign(point_to_node.y)
		#node.position += Vector2(x_shift, y_shift)
		node.position = node.position + shift_amout * point_to_node

func expand_LHS_nodes(shift_amount : float) -> void:
	# Start by creating a polygon
	var poly = PackedVector2Array()
	for node in LHS_nodes:
		poly.append(node.position)
	var shifted_points = Geometry2D.offset_polygon(poly, shift_amount)
	shifted_points = shifted_points[0]
	var n_nodes = LHS_nodes.size()
	for i in range(n_nodes):
		LHS_nodes[i].position = shifted_points[i]

func compress_nodes() -> void:
	var center = get_center("LHS")
	for node in RHS_nodes:
		var node_to_center = center - node.position
		node.position += node_to_center / 1.001#1.1

func get_center(side : String):
	var nodes = get_nodes_for_side(side)
	var center = Vector2.ZERO
	for node in nodes:
		center += node.get_global_position()
	center /= nodes.size()
	return center

func get_center_data(side):
	var nodes = get_nodes_for_side(side)
	var center = Vector2.ZERO
	for node in nodes:
		center += node.position
	center /= nodes.size()
	return center

func reset_rule():
	for node in LHS_nodes:
		node.set_node_number(og_data["LHS"][node]["Number"])
		node.set_global_position(og_data["LHS"][node]["Position"])
	for node in RHS_nodes:
		node.set_node_number(og_data["RHS"][node]["Number"])
		node.set_global_position(og_data["RHS"][node]["Position"])

func reset_rule_data():
	for node in LHS_nodes:
		node.set_node_number(og_data["LHS"][node]["Number"])
		node.position = (og_data["LHS"][node]["Position"])
	for node in RHS_nodes:
		node.set_node_number(og_data["RHS"][node]["Number"])
		node.position = (og_data["RHS"][node]["Position"])

func set_lhs_to_rhs():
	# We have to free the resources that were not converted, but we cannot
	# free the springs
	for spring in LHS_springs:
		if not RHS_springs.has(spring):
			if is_instance_valid(spring):
				spring.call_deferred("queue_free")
	for node in LHS_nodes:
		if not node in RHS_nodes:
			node.call_deferred("free")
	LHS_springs = RHS_springs.duplicate(true)
	RHS_springs.clear()
	LHS_nodes = RHS_nodes.duplicate(true)
	RHS_nodes.clear()

func get_max_node_number(side = "LHS") -> int:
	var nodes = get_nodes_for_side(side)
	return nodes.size() - 1

func get_unplaced_nodes_for_node(node):
	var unplaced_nodes = []
	for connected_node in node.get_connected_nodes():
		if not connected_node in RHS_nodes:
			unplaced_nodes.append(connected_node)

func rotate_nodes(angle : float) -> void:
	var center : Vector2 = get_center("RHS")
	for node in RHS_nodes:
		var v_to_center = node.get_global_position() - center
		v_to_center = v_to_center.rotated(angle)
		node.set_global_position(center + v_to_center)

func rotate_nodes_data(angle : float) -> void:
	var center : Vector2 = get_center_data("RHS")
	for node in RHS_nodes:
		var v_to_center = node.position - center
		v_to_center = v_to_center.rotated(angle)
		node.position = (center + v_to_center)

func shift_nodes_to_new_center(new_center : Vector2) -> void:
	var old_center = get_center("RHS")
	var old_to_new = new_center - old_center
	for node in RHS_nodes:
		node.set_global_position(node.get_global_position() + old_to_new)

func shift_nodes_to_new_center_data(new_center : Vector2, side = "RHS") -> void:
	var old_center = get_center_data(side)
	var old_to_new = new_center - old_center
	var nodes = get_nodes_for_side(side)
	for node in nodes:
		node.position = node.position + old_to_new

func shift_nodes(vec : Vector2) -> void:
	for node in RHS_nodes:
		node.set_global_position(node.get_global_position() + vec)

func get_closest_LHS_node_to(node, nodes_to_check = LHS_nodes):
	var min_dist_sq = INF
	var closest_node
	nodes_to_check.erase(node)
	for other_node in nodes_to_check:
		var dist_sq = node.position.distance_squared_to(other_node.position)
		if dist_sq < min_dist_sq:
			min_dist_sq = dist_sq
			closest_node = other_node
	return closest_node

func get_lhs_nodes_of_room_type(room_type : String) -> Array:
	var nodes = []
	for node in LHS_nodes:
		if node.node_info.room_type == room_type:
			nodes.append(node)
	return nodes

func stop_node_processing():
	var nodes = LHS_nodes + RHS_nodes
	for node in nodes:
		node.call_deferred("snap_pos_to_grid_and_state_to_saved")
		#node.mode = RigidBody2D.FREEZE_MODE_STATIC
		#node.snap_pos_to_grid_and_state_to_saved()
	var springs = LHS_springs + RHS_springs
	for spring in springs:
		spring.call_deferred("deactivate")

func free_resource():
	for node in LHS_nodes + RHS_nodes:
		if is_instance_valid(node):
			node.free_node_and_springs()

func has_start_and_finish() -> bool:
	return is_instance_valid(starting_node) and is_instance_valid(ending_node)

func print_lhs_nodes_and_connections():
	for node in LHS_nodes:
		print("-------------------")
		print(node.node_info.node_number, " ", node.node_info.room_type, " dist from spawn = ", node.node_info.dist_from_closest_spawn)
		for connected_node in node.get_connected_nodes():
			print("Connected to ", connected_node.node_info.node_number, " ", connected_node.node_info.room_type)
