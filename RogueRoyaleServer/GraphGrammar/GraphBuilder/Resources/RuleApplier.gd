extends Node
class_name GrammarRuleApplier
# TO DO -> protect the rng with a mutex

signal all_rules_applied()

enum {APPLYING_RULES, PULLING, RESOLVING_COLLISIONS}
const PULL_FRAMES = 10
const END_COLLISION_FRAMES = 10
const NODE_COLLISION_BOX_SCALE = 1.0

@export var physics_steps_between_grammars = 5 # (int, 2, 200)

#var loaded_node_res = load("res://GraphGrammar/GrammarNodes/Scenes/LoadedNode.tscn")
var subgraph_finder = SubGraphFinder.new()
var distance_from_spawn_setter = GrammarDistanceFromSpawnSetter.new()
var subgraph_renumberer = GrammarSubgraphRenumberer.new()
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


func _init():
	set_physics_process(false)

func _ready():
	set_physics_process(false)

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
	node_container = node_cont
	spring_container = spring_cont
	starting_rules = _starting_rules
	distance_from_spawn_setter.set_distance_from_closest_spawn(grammar_data)
	#grammar_data.expand_nodes("LHS")
	#PhysicsFunctions.execute_func(_add_child_nodes, [])
	_add_child_nodes()
	set_physics_process(true)

func _physics_process(_delta):
	if state == APPLYING_RULES:
		_on_applying_rules()
	elif state == PULLING:
		_on_pulling()
	elif state == RESOLVING_COLLISIONS:
		_on_resolving_collisions()
	physics_process_counter += 1

func _on_applying_rules():
	if physics_process_counter == physics_steps_between_grammars:
		_apply_graph_rule()
		physics_process_counter = -1

func _on_pulling():
	if physics_process_counter == 0:
		_spawn_central_gravity()
#		for spring in spring_container.get_children():
#			spring.deactivated = true
		#_set_collision_boxes_to_rectangles()
	elif physics_process_counter == PULL_FRAMES:
		#_add_room_to_large_springs()
		state = RESOLVING_COLLISIONS
		#_set_collision_boxes_to_rectangles()
		for spring in grammar_data.LHS_springs:
			spring.deactivated = true
		central_gravity_puller.queue_free()
		physics_process_counter = -1

func _on_resolving_collisions():
	if physics_process_counter == 0:
		for node in grammar_data.LHS_nodes:
			#node.collision_box.shape.custom_solver_bias = 0.5
			node.linear_damp = 0
			#node.set_node_size(node.room_scene.border_rect2.size * 1.5)
	if physics_process_counter == END_COLLISION_FRAMES:
		set_physics_process(false)
		_on_physics_process_stopped()

func _apply_graph_rule():
	var array_of_rules = starting_rules.duplicate(true)
	if array_of_rules.is_empty():
		_finished_applying_rules()
		return
	var subgraph_n_rule = _get_random_matching_subgraph_and_rule(array_of_rules)
	if subgraph_n_rule.is_empty():
		_finished_applying_rules()
		return
	var subgraph = subgraph_n_rule[0]
	var rule = subgraph_n_rule[1]
	grammar_data = apply_rule(rule, subgraph)
	_add_child_nodes()

func _finished_applying_rules():
	state = PULLING
	physics_process_counter = -1
	for spring in grammar_data.LHS_springs:
		spring.call_deferred("queue_collisions_free")

func _on_physics_process_stopped():
	grammar_data.stop_node_processing()
	#var stop_node_process_funcref = funcref(grammar_data, "stop_node_processing")
	#PhysicsFunctions.execute_func(stop_node_process_funcref, [])
	call_deferred("emit_signal", "all_rules_applied")

# This could be broken out into its own class that finds subclasses
# based on certain conditions
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

func apply_rule(rule : GRuleInfoReader, subgraph : PossibleSubgraph):
	current_rule = rule
	current_rule.compress_nodes()
	_match_rule_to_graph(subgraph)
	_decrement_rule_executions()
	_update_grammar_data()
	distance_from_spawn_setter.set_distance_from_closest_spawn(grammar_data)
	current_rule.reset_rule()
	return grammar_data

func _match_rule_to_graph(subgraph : PossibleSubgraph) -> void:
	current_rule.shift_nodes_to_new_center(subgraph.get_subgraph_center())
	var angle = subgraph.get_angle_to_rotate_rule()
	current_rule.rotate_nodes(angle)
	subgraph_renumberer.renumber_rule_nodes_for_graph(current_rule, subgraph, grammar_data)

func _update_grammar_data():
	_duplicate_rule_nodes()
	grammar_data.rebuild_spring_from_save("RHS")
	copied_rule_springs = grammar_data.RHS_springs.duplicate(true)
	#_disable_new_rule_collisions()
	#_set_new_nodes_to_static()
	_rebuild_old_springs()
	if nodes_to_rooms:
		_rebuild_old_room_types()
	_add_old_nodes()
	_add_springs_to_rhs()
	grammar_data.set_lhs_to_rhs()

func _disable_new_rule_collisions():
	grammar_data.add_collision_exceptions(copied_rule_nodes)

func _set_new_nodes_to_static():
	for node in copied_rule_nodes:
		node.mode = RigidBody2D.FREEZE_MODE_STATIC

func _shorten_new_rule_springs():
	for node in copied_rule_nodes:
		for spring in node.springs:
			spring.size_spring_short()
#			if not spring in copied_rule_springs:
#				spring.spring_constant *= 10

func _lengthen_new_rule_springs():
	for node in copied_rule_nodes:
		for spring in node.springs:
			spring.size_spring_long()
#			if not spring in copied_rule_springs:
#				spring.spring_constant /= 10

func _duplicate_rule_nodes():
	for rule_node in current_rule.RHS_nodes:
		#var new_node = loaded_node_res.instantiate()
		var new_node = LoadedNode.new()
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

func _rebuild_old_room_types():
	var max_lhs_number = grammar_data.get_max_node_number()
	for node in grammar_data.RHS_nodes:
		if not node.node_info.node_number > max_lhs_number:
			var old_node = grammar_data.get_node(node.node_info.node_number, "LHS")
			node.set_room_scene_with_scene(old_node.room_scene)

func _add_old_nodes():
	var rhs_node_numbers = grammar_data.get_node_numbers_for_side("RHS")
	for node in grammar_data.LHS_nodes:
		if not node.node_info.node_number in rhs_node_numbers:
			grammar_data.add_node_to_side(node, "RHS")
			rhs_node_numbers.append(node.node_info.node_number)

func _add_springs_to_rhs():
	for node in grammar_data.RHS_nodes:
		for spring in node.springs:
			grammar_data.add_spring_to_side(spring, "RHS")

func _decrement_rule_executions() -> void:
	current_rule.executions -= 1
	if current_rule.executions <= 0:
		current_rule.free_resource()
		starting_rules.erase(current_rule)

func _add_child_nodes():
	var old_springs = spring_container.get_children()
	var old_nodes = node_container.get_children()
	_remove_unused_nodes_and_springs(old_nodes, old_springs)
	_add_new_nodes_and_springs(old_nodes, old_springs)

func _remove_unused_nodes_and_springs(old_nodes, old_springs):
	for old_node in old_nodes:
		if not old_node in grammar_data.LHS_nodes:
			if is_instance_valid(old_node.room_scene):
				old_node.room_scene.queue_free()
			old_node.queue_free()
	for old_spring in old_springs:
		if not old_spring in grammar_data.LHS_springs:
			old_spring.queue_free()

func _add_new_nodes_and_springs(old_nodes, old_springs):
	for spring in grammar_data.LHS_springs:
		if not spring in old_springs:
			spring_container.add_child(spring)
	for node in grammar_data.LHS_nodes:
		node.state = node.LOADED
		if not node in old_nodes:
			if nodes_to_rooms:
				room_path_locations.assign_room_to_node(node)
				node.set_node_size(node.room_scene.border_rect2.size * NODE_COLLISION_BOX_SCALE)
			node_container.add_child(node)

func _push_nodes_apart(resize_factor : float = 1.5): # 2.5
	if not nodes_to_rooms:
		return
	for node in grammar_data.LHS_nodes:
		#if is_instance_valid(node):
		node.set_node_size(resize_factor * node.size)

func resize_nodes_to_room():
	for node in grammar_data.LHS_nodes:
		if not node.room_scene == null:
			node.resize_node_to_room()

func _place_crossed_node_on_overlaps() -> bool:
	var replaced = false
	var n_springs = grammar_data.LHS_springs.size()
	for i in range(n_springs - 1):
		var spring_i = grammar_data.LHS_springs[i]
		for j in range(i + 1, n_springs):
			var spring_j = grammar_data.LHS_springs[j]
			if spring_i.intersects(spring_j):
				var crossed_node = CrossedNode.new()
				#var crossed_node = LoadedNode.new()
				crossed_node.state = crossed_node.LOADED
				crossed_node.node_info.room_type = "NormalRooms"
				crossed_node.position = spring_i.get_intersection_point(spring_j)
				room_path_locations.assign_room_to_node(crossed_node)
				#crossed_node.set_crossed_paths(spring_i, spring_j)
				_connect_node_between_spring(crossed_node, spring_i)
				_connect_node_between_spring(crossed_node, spring_j)
				grammar_data.LHS_nodes.append(crossed_node)
				node_container.add_child(crossed_node)
				replaced = true
	return replaced

func _connect_node_between_spring(node, spring) -> void:
	var g_node_b = spring.g_node_b
	spring.remove_node_connection(g_node_b)
	spring.connect_new_node(node)
	var new_spring = GrammarSpring.new()
	#var new_spring = GrammarSpringRigidBody.new()
	new_spring.connect_nodes(node, g_node_b)
	spring_container.add_child(new_spring)
	grammar_data.LHS_springs.append(new_spring)

func _get_com(nodes : Array) -> Vector2:
	var com = Vector2.ZERO
	for node in nodes:
		com += node.get_global_position()
	return com / nodes.size()

func _add_room_to_large_springs():
	#var added = false
	var oversized_springs = _get_oversized_springs()
	for spring in oversized_springs:
		# TO DO -> create rules for this specific case
		var midpoint = spring.midpoint()
		var new_node = LoadedNode.new()
		#var new_node = loaded_node_res.instantiate()
		new_node.node_info.room_type = "NormalRooms"
		new_node.position = midpoint
		room_path_locations.assign_room_to_node(new_node)
		new_node.state = new_node.LOADED
		new_node.node_info.replaceable = false
		node_container.add_child(new_node)
		grammar_data.LHS_nodes.append(new_node)
		var g_node_b = spring.g_node_b
		spring.remove_node_connection(g_node_b)
		spring.connect_new_node(new_node)
		#spring.size_spring_short()
		spring.size_spring()
		if spring.is_oversized():
			oversized_springs.append(spring)
		var new_spring = GrammarSpring.new()
		#var new_spring = GrammarSpringRigidBody.new()
		new_spring.connect_nodes(new_node, g_node_b)
		spring_container.add_child(new_spring)
		if new_spring.is_oversized():
			oversized_springs.append(new_spring)
		grammar_data.LHS_springs.append(new_spring)
		#added = true
	#return added

func _get_oversized_springs() -> Array:
	var oversized_springs = []
	for spring in grammar_data.LHS_springs:
		if is_instance_valid(spring):
			if spring.is_oversized():
				oversized_springs.append(spring)
	return oversized_springs

func _set_collision_boxes_to_rectangles():
	for node in grammar_data.LHS_nodes:
		node.set_collision_box_to_rect()

func _spawn_central_gravity():
	var aabb = Rect2(Vector2.ZERO, Vector2.ZERO)
	for node in grammar_data.LHS_nodes:
		node.linear_damp = 15
		var node_rect = Rect2(node.global_position - node.size / 2, node.size)
		aabb = aabb.merge(node_rect)
	central_gravity_puller = Area2D.new()
	var area_collision = CollisionShape2D.new()
	var area_rect = RectangleShape2D.new()
	area_collision.shape = area_rect
	area_rect.size = aabb.size
	central_gravity_puller.position = (aabb.position + aabb.end) / 2
	central_gravity_puller.gravity_point = true
	central_gravity_puller.gravity = 1024
	#central_gravity_puller.space_override = Area2D.SPACE_OVERRIDE_COMBINE
	central_gravity_puller.add_child(area_collision)
	add_child(central_gravity_puller)

func _exit_tree():
#	print("RULE APPLIER EXITED TREE")
#	for node in grammar_data.LHS_nodes + grammar_data.RHS_nodes:
#		if is_instance_valid(node):
#			node.free_node_and_springs()
	for rule in starting_rules:
		rule.free_resource()
