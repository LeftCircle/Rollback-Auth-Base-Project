extends GrammarNode
class_name LoadedNode

#const TIME_AS_STATIC = 0.2

var room_scene : RoomOutline
var pos_tiles : Vector2
var room_scene_path

func _ready():
	_reset_collision_box()
	_on_loaded()
	collision_box.disabled = true
	collision_box.shape.custom_solver_bias = 1.0
	add_to_group("LoadedNode")

func load_node(old_node_info : Resource):
	_load_node_info(old_node_info)
	state = LOADED

func _load_node_info(old_node_info : Resource) -> void:
	node_info.node_number = old_node_info.node_number
	node_info.position = old_node_info.position
	position = node_info.position
	node_info.room_type = old_node_info.room_type
	node_info.replaceable = old_node_info.replaceable
	node_info.springs_info = old_node_info.springs_info
	node_info.is_starting_node = old_node_info.is_starting_node
	node_info.is_ending_node = old_node_info.is_ending_node
	node_info.dist_from_closest_spawn = old_node_info.dist_from_closest_spawn
	node_info.closest_spawn_nodes = old_node_info.closest_spawn_nodes

func duplicate_node(node_to_dup : LoadedNode) -> void:
	var save_data = node_to_dup.get_save_data()
	room_scene = node_to_dup.room_scene
	size = node_to_dup.size
	load_node(save_data)

func get_save_data():
	_save_position()
	node_info.springs_info.clear()
	for spring in springs:
		node_info.springs_info.append(spring.get_save_data())
	return node_info

func set_node_number(new_number : int) -> void:
	node_info.node_number = new_number
	for spring in springs:
		spring.set_connected_node_number(self)

func set_node_size(new_size : Vector2) -> void:
	side_length = max(new_size.x, new_size.y) / 2
	size = new_size
	_reset_collision_box()
	for spring in springs:
		if is_instance_valid(spring):
			spring.size_spring()

#func get_global_position():
#	if is_inside_tree():
#		return global_position
#	return position
#
#func set_global_position(new_pos : Vector2) -> void:
#	if is_inside_tree():
#		global_position = new_pos
#	else:
#		position = new_pos

func log_springs():
	for spring in springs:
		spring.log_spring()

func log_node():
	Logging.log_line("Node " + str(node_info.node_number) + " " + self.to_string())
	Logging.log_line("Node info = ")
	Logging.log_line("Number      = " + str(node_info.node_number))
	Logging.log_line("Type        = " + str(node_info.room_type))
	Logging.log_line("position    = " + str(node_info.position))
	Logging.log_line("Replaceable = " + str(node_info.replaceable))
	log_springs()
	Logging.log_line("\n")

func node_matches_node_for_rule(loaded_rule_node : LoadedNode, rule) -> bool:
	var matches_without_springs = node_match_without_springs(loaded_rule_node)
	if not matches_without_springs:
		return false
	var n_new_conn = rule.og_data["NewConnections"][loaded_rule_node]
	# TO DO -> this might not be true because we are not accounting for connections
	# to nodes that might already exist in the rule?
	if n_new_conn + springs.size() > MAX_CONNECTIONS:
		return false
	return _confirm_springs_match_for_rule_node(loaded_rule_node)

func node_match_without_springs(other_node : LoadedNode) -> bool:
	if node_info.replaceable != other_node.node_info.replaceable:
		return false
	if node_info.room_type != other_node.node_info.room_type:
		return false
	return true

func _confirm_springs_match_for_rule_node(loaded_rule_node : LoadedNode) -> bool:
	var checked_springs = []
	for rule_spring in loaded_rule_node.springs:
		for spring in springs:
			if not spring in checked_springs:
				if is_instance_valid(spring):
					if rule_spring.springs_match(spring):
						checked_springs.append(spring)
						break
	if checked_springs.size() == loaded_rule_node.springs.size():
		return true
	return false

func get_matching_nodes_in_rule(rule) -> Array:
	var matching_nodes = []
	for rule_node in rule.LHS_nodes:
		if node_matches_node_for_rule(rule_node, rule):
			matching_nodes.append(rule_node)
	return matching_nodes

func possibly_matching_springs_to_rule(loaded_rule_node : LoadedNode) -> Array:
	var possible_springs = []
	for rule_spring in loaded_rule_node.springs:
		for spring in springs:
			if not spring in possible_springs:
				if rule_spring.springs_match(spring):
					possible_springs.append(spring)
					break
	return possible_springs

func get_node_on_spring(spring):
	return spring.get_other_node(self)

func get_connected_node_numbers() -> Array:
	var connected_numbers = []
	for spring in springs:
		var other_node = spring.get_other_node(self)
		if not other_node == null:
			connected_numbers.append(other_node.node_info.node_number)
	return connected_numbers

func get_connected_nodes() -> Array:
	var conn_nodes = []
	for spring in springs:
		if is_instance_valid(spring):
			conn_nodes.append(spring.get_other_node(self))
	return conn_nodes

func add_springs_from_old_node(old_node : LoadedNode, node_numbers_to_not_attach : Array = []) -> Array:
	var old_springs = []
	var conn_node_ns = get_connected_node_numbers()
	for i in range(old_node.springs.size() - 1, -1, -1):
		var old_spring = old_node.springs[i]
		var old_conn_node = old_spring.get_other_node(old_node)
		if not old_conn_node.node_info.node_number in conn_node_ns:
			if not old_conn_node.node_info.node_number in node_numbers_to_not_attach:
				conn_node_ns.append(old_conn_node.node_info.node_number)
				old_spring.remove_node_connection(old_node)
				old_spring.connect_new_node(self)
				old_springs.append(old_spring)
	return old_springs

func free_node_and_springs():
	for spring in springs:
		if is_instance_valid(spring):
			spring.queue_free()
	if is_instance_valid(room_scene):
		room_scene.queue_free()
	queue_grammar_node_objects_free()
	queue_free()

func set_room_scene_with_scene(scene : RoomOutline) -> void:
	room_scene = scene

func set_room_scene_from_path(new_room_scene_path : String) -> void:
	room_scene_path = new_room_scene_path
	room_scene = load(room_scene_path).instantiate()

func resize_node_to_room():
	set_node_size(room_scene.border_rect2.size)

func set_collision_box_to_rect():
	var rect = RectangleShape2D.new()
	rect.size = room_scene.border_rect2.size / 1.75
	collision_box.set_deferred("shape", rect)

func snap_pos_to_grid_and_state_to_saved():
	set_deferred("mode", FREEZE_MODE_STATIC)
	collision_box.set_deferred("disabled", true)
	queue_collision_box_free()
	var snapped_pos = global_position.snapped(ProjectSettings.get_setting("global/TILE_VEC"))
	global_position = snapped_pos
	pos_tiles = global_position / ProjectSettings.get_setting("global/TILE_SIZE")
	#call_deferred("set_physics_process", false)

func get_data_to_send():
	var data = {"Doors" : []}
	var pos = room_scene.room_rect2.position
	data["Position"] = pos
	data["RoomPath"] = room_scene_path
	for door in room_scene.get_doors():
		data["Doors"].append(door.get_data_to_send())
	Logging.log_line("ROOM POSITION FOR NODE " + str(node_info.node_number) + " " + str(pos))
	return data

func deactivate():
	for spring in springs:
		spring.disable_process_and_queue_free_collisions()
	collision_box.queue_free()
	set_physics_process(false)
	set_process(false)
	set_process_unhandled_input(false)

func _exit_tree():
	free_node_and_springs()
	if is_instance_valid(room_scene):
		room_scene.queue_free()
