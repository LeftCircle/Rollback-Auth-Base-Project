extends Node2D
class_name GrammarRuleApplierData

enum {APPLYING_RULES, PULLING, RESOLVING_COLLISIONS}
const PULL_FRAMES = 30
const END_COLLISION_FRAMES = 30

@export var physics_steps_between_grammars = 1#5 # (int, 2, 200)

var loaded_node_res = load("res://GraphGrammar/GrammarNodes/Scenes/LoadedNode.tscn")
var subgraph_finder = SubGraphFinder.new()
var grammar_data : GRuleInfoReader
var current_rule : GRuleInfoReader
var old_nodes_in_new_rule = []
var node_container : Node2D
var spring_container : Node2D
var nodes_to_rooms = false
var room_path_locations : RoomPathLocations
var starting_rules : Array
var physics_process_counter = 0
var copied_rule_nodes : Array
var copied_rule_springs : Array
var n_times_springs_crossed = 0
var adding_to_large_springs = false
var pulling = false
var state = APPLYING_RULES
var central_gravity_puller : Area2D
var subgraph_center : Vector2
var subgraph_rect2
var physics_frames = 0
var triangles_to_draw = 0
var subgraph
var triangle_for_subgraph

var to_draw = false
var region_triangles = RegionTriangleBuilder.new()
#var region_triangles_2 = RegionTriangleBuilder.new()
var subgraph_triangles = RegionTriangleBuilder.new()
var first = true
signal all_rules_applied


func _draw():
	if to_draw:
		#for i in range(triangles_to_draw):
#		var triangle = region_triangles.region_triangles[triangles_to_draw]
#		var colors = PackedColorArray([
#			Color(randf(), randf(), randf(), 0.25)
#		])
#		draw_polygon(triangle.get_polygon(), colors)
		pass
		for triangle in region_triangles.region_triangles:
			var colors = PackedColorArray([
				Color(randf(), randf(), randf(), 0.1)
			])
			draw_polygon(triangle.get_polygon(), colors)


func _physics_process(_delta):
	if first:
		update()
		first = false
#	if physics_frames == 120 and first:
#		update()
#		if triangles_to_draw == region_triangles.region_triangles.size() - 1:
#			first = false
#			#triangles_to_draw = 0
#		else:
#			triangles_to_draw += 1
#		physics_frames = -1
#	physics_frames += 1

func set_room_paths(room_paths : RoomPathLocations):
	room_path_locations = room_paths
	room_path_locations.build_room_path_dict()
	nodes_to_rooms = true

func apply_rules_from_array(node_cont, spring_cont, g_data : GRuleInfoReader, rules : Array):
	var rule_readers = []
	for rule in rules:
		var new_reader = GRuleInfoReader.new()
		new_reader.connect_reader_to_rule(rule)
		rule_readers.append(new_reader)
	apply_rules(node_cont, spring_cont, g_data, rule_readers)

func apply_rules(node_cont, spring_cont, starting_cond : GRuleInfoReader, _starting_rules : Array):
	grammar_data = starting_cond
	for node in grammar_data.LHS_nodes + grammar_data.RHS_nodes:
		assert(node.is_inside_tree() == false)
	node_container = node_cont
	spring_container = spring_cont
	starting_rules = _starting_rules
	# Start by assigning nodes a room, then expaning by the max node size
	_assign_rooms_to_nodes(grammar_data.LHS_nodes)
	var new_center = get_new_node_center(grammar_data.LHS_nodes)
	var largest_node = _get_largest_new_node(grammar_data.LHS_nodes)
	var shift = largest_node.size.x + largest_node.size.y
	expand_connections(largest_node.size.x + largest_node.size.y)
	#grammar_data.expand_LHS_nodes_away_from(new_center, shift)
	#_add_child_nodes()
	#expand_nodes_by_largest_node(grammar_data.LHS_nodes, largest_node, new_center)
	_apply_graph_rules()

func _apply_graph_rules():
	var applied = 0
	while not starting_rules.is_empty():
		if applied == 5:
			break
		applied += 1
		var array_of_rules = starting_rules.duplicate(true)
		var subgraph_n_rule = _get_random_matching_subgraph_and_rule(array_of_rules)
		if subgraph_n_rule.is_empty():
			break
		subgraph = subgraph_n_rule[0]
		var rule = subgraph_n_rule[1]
		grammar_data = apply_rule(rule)
	region_triangles.init(grammar_data.LHS_nodes)
	#region_triangles.build_triangles()
	region_triangles.build_triangles_from_graph(grammar_data.LHS_nodes, grammar_data.LHS_springs)
	to_draw = true
	update()
	_add_child_nodes()

func _get_random_matching_subgraph_and_rule(current_array_of_rules : Array):
	if current_array_of_rules.is_empty():
		return []
	var n_rules = current_array_of_rules.size()
	var random_rule = current_array_of_rules[Map.map_rng.randi() % n_rules]
	var subgraphs = subgraph_finder.find_subgraphs(grammar_data, random_rule)
	if subgraphs.is_empty():
		current_array_of_rules.erase(random_rule)
		return _get_random_matching_subgraph_and_rule(current_array_of_rules)
	return [subgraphs[Map.map_rng.randi() % subgraphs.size()], random_rule]

func apply_rule(rule : GRuleInfoReader):
	if grammar_data.LHS_nodes.size() > 2:
		region_triangles.init(grammar_data.LHS_nodes)
		#region_triangles.build_triangles()
		region_triangles.build_triangles_from_graph(grammar_data.LHS_nodes, grammar_data.LHS_springs)
	current_rule = rule
	current_rule.prep_rule_for_graph(nodes_to_rooms)
	_match_rule_to_graph()
	_decrement_rule_executions()
	_number_new_nodes()
	_update_grammar_data()
	current_rule.reset_rule()
	return grammar_data

func _match_rule_to_graph() -> void:
	#_assign_rooms_to_nodes_and_resize(current_rule.RHS_nodes)
	_expand_new_rule_nodes(current_rule.RHS_nodes)
	var angle = subgraph.get_angle_to_rotate_rule_data()
	current_rule.rotate_nodes_data(angle)
	if grammar_data.LHS_nodes.size() > 2:
		_grow_region_to_fit_subgraph()
		# var subgraph_rect = _get_bounding_box_of_nodes(current_rule.RHS_nodes)
		# var shift = subgraph_rect.size.x + subgraph_rect.size.y
		# subgraph_center = subgraph.get_subgraph_center()
		# _shift_nodes_away_from_point(grammar_data.LHS_nodes, subgraph_center, shift)
		# subgraph_center = subgraph.get_subgraph_center()
		# #var new_angle = subgraph.get_angle_to_rotate_rule_data()
		# #current_rule.rotate_nodes_data(new_angle)
		# current_rule.shift_nodes_to_new_center_data(subgraph_center)
		# #subgraph_center = subgraph.get_subgraph_center_data()

	#triangle_for_subgraph = region_triangles.get_triangle_that_contains_point(subgraph_center)
	#current_rule.shift_nodes_to_new_center_data(subgraph_center)
	_renumber_rule_nodes_for_graph()

func _grow_region_to_fit_subgraph():
	#var springs_in_subgraph = subgraph.get_springs_connecting_graph_nodes()
	#var triangles_for_subgraph = []
	#for spring in springs_in_subgraph:
	#	var spring_triangles = region_triangles.get_triangles_with_edge(spring.g_node_a, spring.g_node_b)
	#	triangles_for_subgraph.append_array(spring_triangles)
	#var center = _get_center_of_triangles(triangles_for_subgraph)
	var subgraph_rect = _get_bounding_box_of_nodes(current_rule.RHS_nodes)
	var min_dist = subgraph_rect.size.x + subgraph_rect.size.y
	region_triangles.grow_triangles(min_dist)
	var center = subgraph.get_subgraph_center_data()
	current_rule.shift_nodes_to_new_center_data(center)

	# var all_subgraph_points_inside = false
	# while not all_subgraph_points_inside:
	# 	var subgraph_rect = _get_bounding_box_of_nodes(current_rule.RHS_nodes)
	# 	all_subgraph_points_inside = _check_if_rect_is_within_triangles(subgraph_rect, triangles_for_subgraph)
	# 	if not all_subgraph_points_inside:
	# 		#region_triangles.grow_triangles_by_percent(1.025)
	# 		region_triangles_2.grow_triangles_by_percent(1.01)
	# 		center = _get_center_of_triangles(triangles_for_subgraph)
	# 		#center = subgraph.get_subgraph_center_data()
	# 		current_rule.shift_nodes_to_new_center_data(center)

func _get_center_of_triangles(triangles : Array) -> Vector2:
	var center = Vector2.ZERO
	for triangle in triangles:
		center += triangle.get_center()
	return center / triangles.size()

func _check_if_rect_is_within_triangles(rect, triangles):
	var points = [rect.position, rect.end, rect.position + Vector2(rect.size.x, 0), rect.position + Vector2(0, rect.size.y)]
	for point in points:
		var point_inside = false
		for triangle in triangles:
			if triangle.contains_point(point):
				point_inside = true
				break
		if not point_inside:
			return false
	return true

func _renumber_rule_nodes_for_graph() -> void:
	for graph_rule_match in subgraph.subgraph_array:
		var graph_node = graph_rule_match["GraphNode"]
		var rule_node = graph_rule_match["RuleNode"]
		var rhs_rule_node = current_rule.get_node(rule_node.node_info.node_number, "RHS")
		rhs_rule_node.set_node_number(graph_node.node_info.node_number)
		#rhs_rule_node.position = graph_node.position
		old_nodes_in_new_rule.append(rhs_rule_node)

func _decrement_rule_executions() -> void:
	current_rule.executions -= 1
	if current_rule.executions <= 0:
		starting_rules.erase(current_rule)

func _number_new_nodes():
	var max_node_number = grammar_data.get_max_node_number()
	for node in current_rule.RHS_nodes:
		if node.node_info.node_number < 0:
			node.set_node_number(max_node_number + 1)
			max_node_number += 1

func _update_grammar_data():
	_duplicate_rule_nodes()
	grammar_data.rebuild_spring_from_save("RHS")
	copied_rule_springs = grammar_data.RHS_springs.duplicate(true)
	_rebuild_old_springs()
	_add_old_nodes_and_remove_unused()
	_add_springs_to_rhs()
	_remove_unused_springs()
	#_assign_rooms_to_nodes_and_resize(copied_rule_nodes)
	grammar_data.set_lhs_to_rhs()

func _duplicate_rule_nodes():
	for rule_node in current_rule.RHS_nodes:
		var new_node = loaded_node_res.instantiate()
		new_node.duplicate_node(rule_node)
		grammar_data.add_node_to_side(new_node, "RHS")
	copied_rule_nodes = grammar_data.RHS_nodes.duplicate(true)

func _rebuild_old_springs():
	var nodes_to_not_reattatch_to = grammar_data.get_node_numbers_for_side("RHS")
	var max_lhs_number = grammar_data.get_max_node_number()
	for node in grammar_data.RHS_nodes:
		if not node.node_info.node_number > max_lhs_number:
			var old_node = grammar_data.get_node(node.node_info.node_number, "LHS")
			var old_springs = node.add_springs_from_old_node(old_node, nodes_to_not_reattatch_to)
			grammar_data.RHS_springs += old_springs

func _add_old_nodes_and_remove_unused():
	var rhs_node_numbers = grammar_data.get_node_numbers_for_side("RHS")
	for node in grammar_data.LHS_nodes:
		if not node.node_info.node_number in rhs_node_numbers:
			grammar_data.add_node_to_side(node, "RHS")
			rhs_node_numbers.append(node.node_info.node_number)
		else:
			node.queue_free()

func _add_springs_to_rhs():
	for node in grammar_data.RHS_nodes:
		for spring in node.springs:
			grammar_data.add_spring_to_side(spring, "RHS")

func _remove_unused_springs():
	for spring in grammar_data.LHS_springs:
		if not spring in grammar_data.RHS_springs:
			spring.queue_free()

func _assign_rooms_to_nodes(nodes : Array) -> void:
	for node in nodes:
		room_path_locations.assign_room_to_node(node)

func _expand_new_rule_nodes(new_rule_nodes):
	var largest_node = _get_largest_new_node(new_rule_nodes)
	var min_dist = sqrt(pow(largest_node.size.x, 2) + pow(largest_node.size.y, 2))
	subgraph_triangles.init(new_rule_nodes)
	subgraph_triangles.build_triangles()
	subgraph_triangles.grow_triangles(min_dist)
	var subgraph_rect = _get_bounding_box_of_nodes(new_rule_nodes)

func _get_largest_new_node(new_nodes : Array):
	var largest_node
	var max_area = 0
	for node in new_nodes:
		var node_area = node.size.x * node.size.y
		if node_area > max_area:
			largest_node = node
			max_area = node_area
	return largest_node

func get_new_node_center(new_nodes : Array) -> Vector2:
	var center = Vector2.ZERO
	for node in new_nodes:
		center += node.position
	return center / new_nodes.size()

func _shift_all_nodes_by_largest_and_center(largest_node, new_center):
	var center_to_largest = new_center.distance_to(largest_node.position)
	var size_shift = sqrt(pow(largest_node.size.x, 2) +	pow(largest_node.size.y, 2))
	var shift_amount = (center_to_largest + size_shift)
	grammar_data.expand_LHS_nodes_away_from(new_center, shift_amount)

func _shift_nodes_away_from_point(nodes, point, shift) -> void:
	for node in nodes:
		var point_to_node = point.direction_to(node.position)
		#node.position = node.position + shift * point_to_node
		node.position.x += node.position.x + shift * sign(point_to_node.x)
		node.position.y += node.position.y + shift * sign(point_to_node.y)

func get_bounding_rect2(nodes):
	var rect2 = Rect2(nodes[0].position, Vector2.ZERO)
	var largest_node = _get_largest_new_node(nodes)
	for node in nodes:
		rect2 = rect2.expand(node.position)
	var max_size = largest_node.size
	rect2.grow_individual(max_size.x / 2, max_size.y / 2, max_size.x / 2, max_size.y / 2)
	return rect2

func expand_nodes_by_largest_node(nodes, largest_node, point):
	var size_shift = largest_node.size.x + largest_node.size.y
	for node in nodes:
		var point_to_node = point.direction_to(node.position)
		node.position = node.position + size_shift * point_to_node

func expand_connections(expansion_amount : float) -> void:
	# Find the center of mass, pick a static starting node, then update the
	# position of each node based on the new conenction size.
	var com = grammar_data.get_center_data("LHS")
	var static_nodes = [grammar_data.LHS_nodes[0]]
	var nodes_to_move = [grammar_data.LHS_nodes[0]]
	while not static_nodes.size() == grammar_data.LHS_nodes.size():
		var next_node = nodes_to_move.pop_back()
		nodes_to_move.append_array(_set_new_positions(next_node, static_nodes, expansion_amount))
	grammar_data.shift_nodes_to_new_center_data(com, "LHS")

func _set_new_positions(current_node, static_nodes : Array, shift : float):
	var nodes_to_move = []
	for spring in current_node.springs:
		var other_node = spring.get_other_node(current_node)
		if not other_node in static_nodes:
			var current_to_other = current_node.position.direction_to(other_node.position)
			var addition = current_to_other * shift
			other_node.position += addition
			nodes_to_move.append(other_node)
	static_nodes.append(current_node)
	return nodes_to_move

func _add_child_nodes():
	for spring in grammar_data.LHS_springs:
		spring_container.add_child(spring)
	for node in grammar_data.LHS_nodes:
		node.state = node.LOADED
		node_container.add_child(node)

func _get_bounding_box_of_nodes(nodes) -> Rect2:
	var rect = Rect2(nodes[0].position, Vector2.ZERO)
	for node in nodes:
		rect = rect.merge(node.get_node_rect())
	return rect
