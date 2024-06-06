extends StaticBody2D
class_name GrammarSpring

#export var spring_info: Resource = load("res://GraphGrammar/Springs/Resources/SpringInfo.gd").new()
const MAX_FORCE = 5000

var spring_info = GrammarSpringInfo.new()
var g_node_a
var g_node_b
var door_a
var door_b
var spring_collisions
var rest_length
var max_acceptable_length
var spring_constant = 20#75
var spring_width = ProjectSettings.get_setting("global/TILE_SIZE") * 0.25
var force_direction : Vector2
var length
var allow_pull = true
var deactivated = false
var collision_end_a : Vector2
var collision_end_b : Vector2

func _ready():
	spring_collisions = CollisionPolygon2D.new()
	spring_collisions.build_mode = spring_collisions.BUILD_SOLIDS
	spring_collisions.one_way_collision_margin = 128
	add_child(spring_collisions)
	deactivated = false
	spring_collisions.disabled = true

func deactivate():
	deactivated = true

func set_allow_pull(to_allow : bool) -> void:
	allow_pull = to_allow

func _physics_process(_delta):
	pass

func _draw():
	if is_instance_valid(g_node_a) and is_instance_valid(g_node_b):
		draw_line(g_node_a.get_global_position(), g_node_b.get_global_position(), Color.BLUE)

func get_save_data() -> Resource:
	return spring_info

func load_spring_info(old_spring_info : GrammarSpringInfo) -> void:
	spring_info = old_spring_info

func duplicate_spring(old_spring : GrammarSpring) -> void:
	spring_info = old_spring.spring_info

func set_connected_node_number(node : GrammarNode) -> void:
	if g_node_a == node:
		spring_info.c_node_number_a = node.node_info.node_number
	elif g_node_b == node:
		spring_info.c_node_number_b = node.node_info.node_number

func get_force(node : GrammarNode) -> Vector2:
	#return Vector2.ZERO
	if not is_instance_valid(g_node_a) or not is_instance_valid(g_node_b):
		return Vector2.ZERO
	PhysicsFunctions.execute_func(_set_collision_points, [])
	#_set_collision_points()
	if deactivated:
		return Vector2.ZERO
	length = g_node_a.get_global_position().distance_to(g_node_b.get_global_position())
	#if not allow_pull and length > rest_length:
	#	return Vector2.ZERO
	var stretch = length - rest_length
	var force = int(spring_constant * stretch)
	if node == g_node_a:
		force_direction = g_node_a.get_global_position().direction_to(g_node_b.get_global_position())
	elif node == g_node_b:
		force_direction = g_node_b.get_global_position().direction_to(g_node_a.get_global_position())
	force = min(MAX_FORCE, force)
	return force * force_direction

func connect_nodes(nodeA : GrammarNode, nodeB : GrammarNode) -> void:
	g_node_a = nodeA
	g_node_b = nodeB
	_add_collision_exceptions()
	g_node_a.connect("g_node_queue_free",Callable(self,"_on_g_node_queued_free"))
	g_node_b.connect("g_node_queue_free",Callable(self,"_on_g_node_queued_free"))
	if not g_node_a.springs.size() >= g_node_a.MAX_CONNECTIONS and not g_node_b.springs.size() >= g_node_b.MAX_CONNECTIONS:
		spring_info.c_node_number_a = g_node_a.node_info.node_number
		spring_info.c_node_number_b = g_node_b.node_info.node_number
		if not g_node_a.has_spring_with_same_connected_nodes(self):
			g_node_a.springs.append(self)
		if not g_node_b.has_spring_with_same_connected_nodes(self):
			g_node_b.springs.append(self)
		size_spring()

func _add_collision_exceptions():
	add_collision_exception_with(g_node_a)
	add_collision_exception_with(g_node_b)

func _set_collision_points():
	if is_instance_valid(spring_collisions) and is_instance_valid(g_node_a) and is_instance_valid(g_node_b):
		var a_pos : Vector2 = g_node_a.get_global_position()
		var b_pos : Vector2 = g_node_b.get_global_position()
		var rect_a : Rect2 = g_node_a.get_node_rect()
		var a_collision_radius = min(rect_a.size.x, rect_a.size.y) / 2
		var rect_b = g_node_b.get_node_rect()
		var b_collision_radius = min(rect_b.size.x, rect_b.size.y) / 2
		var a_to_b : Vector2 = a_pos.direction_to(b_pos)
		collision_end_a = a_pos + a_to_b * (a_collision_radius) / 1.1
		collision_end_b = b_pos - a_to_b * (b_collision_radius) / 1.1
		var a_to_b_perp = a_to_b.orthogonal() * spring_width
		var points : PackedVector2Array = [
			collision_end_a + a_to_b_perp, collision_end_b + a_to_b_perp,
			collision_end_b - a_to_b_perp, collision_end_a - a_to_b_perp
		]
		spring_collisions.set_deferred("polygon", points)

func size_spring():
	rest_length = (g_node_a.side_length + g_node_b.side_length) * 1.5#1.75#1.65
	max_acceptable_length = 2 * rest_length

func size_spring_long():
	rest_length = (g_node_a.side_length + g_node_b.side_length) * 4#1.75#1.65
	max_acceptable_length = 1.5 * rest_length

func size_spring_short(division_mod = 1):
	rest_length = (g_node_a.side_length + g_node_b.side_length) / division_mod
	#max_acceptable_length = (g_node_a.side_length + g_node_b.side_length) * 1.25

func set_rest_length(new_length) -> void:
	rest_length = new_length

func is_oversized() -> bool:
	if not is_instance_valid(g_node_a) or not is_instance_valid(g_node_b):
		return false
	var vec = g_node_a.get_global_position() - g_node_b.get_global_position()
	var l_sq = vec.length_squared()
	var max_l_sq = pow(max_acceptable_length, 2)
	if l_sq > max_l_sq:
		var a = 1
	return vec.length_squared() > pow(max_acceptable_length, 2)

func log_spring():
	var a_spring
	var b_spring
	if g_node_a == null:
		a_spring = "null"
	else:
		a_spring = g_node_a.to_string()
	if g_node_b == null:
		b_spring = "null"
	else:
		b_spring = g_node_b.to_string()
	Logging.log_line(a_spring + " " + b_spring + " Spring ID = " + self.to_string())

func springs_match(other_spring) -> bool:
	#if is_oversized() or other_spring.is_oversized():
	#	return false
	var a_matches_a = g_node_a.node_match_without_springs(other_spring.g_node_a)
	var a_matches_b = g_node_a.node_match_without_springs(other_spring.g_node_b)
	var b_matches_a = g_node_b.node_match_without_springs(other_spring.g_node_a)
	var b_matches_b = g_node_b.node_match_without_springs(other_spring.g_node_b)
	if (a_matches_a and b_matches_b) or (a_matches_b and b_matches_a):
		return true
	return false

func is_connected_to_number(node_number : int) -> bool:
	if node_number == spring_info.c_node_number_a or node_number == spring_info.c_node_number_b:
		return true
	return false

func is_connected_to_node(node) -> bool:
	if node == g_node_a or node == g_node_b:
		return true
	return false

func get_node_with_number(number : int):
	if g_node_a.node_info.node_number == number:
		return g_node_a
	elif g_node_b.node_info.node_number == number:
		return g_node_b
	assert(false) #,"this spring does not have a connection to node " + str(number))

func get_other_node(calling_node):
	if g_node_a == calling_node:
		return g_node_b
	elif g_node_b == calling_node:
		return g_node_a

func remove_node_connection(node_to_disconnect : Node, with_number = false) -> void:
	node_to_disconnect.springs.erase(self)
	remove_collision_exception_with(node_to_disconnect)
	node_to_disconnect.disconnect("g_node_queue_free",Callable(self,"_on_g_node_queued_free"))
	var check = [spring_info.c_node_number_a, spring_info.c_node_number_b] if with_number else [g_node_a, g_node_b]
	if node_to_disconnect == check[0]:
		g_node_a = null
		spring_info.c_node_number_a = -1
	elif node_to_disconnect == check[1]:
		g_node_b = null
		spring_info.c_node_number_b = -1
	if is_instance_valid(spring_collisions):
		spring_collisions.polygon = []

func connect_new_node(node_to_connect) -> void:
	add_collision_exception_with(node_to_connect)
	node_to_connect.connect("g_node_queue_free",Callable(self,"_on_g_node_queued_free"))
	if g_node_a == null:
		g_node_a = node_to_connect
		spring_info.c_node_number_a = node_to_connect.node_info.node_number
	elif g_node_b == null:
		g_node_b = node_to_connect
		spring_info.c_node_number_b = node_to_connect.node_info.node_number
	else:
		assert(false) #,"There are already two connections on this node")
	node_to_connect.springs.append(self)

func intersects(other_spring : GrammarSpring) -> bool:
	var A = collision_end_a
	var B = collision_end_b
	var C = other_spring.collision_end_a
	var D = other_spring.collision_end_b
	return (counter_clockwise(A,C,D) != counter_clockwise(B,C,D) and
		counter_clockwise(A,B,C) != counter_clockwise(A,B,D))

func counter_clockwise(A : Vector2, B : Vector2, C : Vector2) -> bool:
	var order_0 = (C.y-A.y) * (B.x-A.x)
	var order_1 = (B.y-A.y) * (C.x-A.x)
	if order_0 != 0 and order_0 != order_1:
		return order_0 > order_1
	else:
		# If the points are collinear then just return false -
		# The collisions should always prevent this
		return false

func get_center():
	return (g_node_a.get_global_position() + g_node_b.get_global_position()) / 2

func _on_g_node_queued_free():
	call_deferred("queue_free")

func on_segment(p, q, r) -> bool:
	return (q.x <= max(p.x, r.x) and q.x >= min(p.x, r.x) and q.y <= max(p.y, r.y) and q.y >= min(p.y, r.y))

func between_points(p, q, r) -> bool:
	return (q.x <= max(p.x, r.x) and q.x >= min(p.x, r.x)) or (q.y <= max(p.y, r.y) and q.y >= min(p.y, r.y))

func push_nodes_away_from(point : Vector2) -> void:
	var a_to_b = g_node_b.get_global_position() - g_node_a.get_global_position()
	var a_to_b_tang = a_to_b.tangent()
	var impulse = -a_to_b.project(a_to_b_tang)
	g_node_a.set_global_position(g_node_a.get_global_position() + impulse)
	g_node_b.set_global_position(g_node_b.get_global_position() + impulse)

# Returns [a, b, c] for ax + by + c = 0
func get_spring_line(with_tiles = false):
	var pos_a : Vector2
	var pos_b : Vector2
	if not with_tiles:
		pos_a = g_node_a.get_global_position()
		pos_b = g_node_b.get_global_position()
	else:
		pos_a = g_node_a.pos_tiles
		pos_b = g_node_b.pos_tiles
	var a = pos_b.y - pos_a.y
	var b = pos_a.x - pos_b.x
	var c = pos_b.cross(pos_a)
	return [a, b, c]

func midpoint() -> Vector2:
	return (g_node_a.get_global_position() + g_node_b.get_global_position()) / 2

func get_intersection_point(other_spring):
	var a_b_c_line = get_spring_line()
	var a_b_c_line_other = other_spring.get_spring_line()
	var a0 = a_b_c_line[0]
	var b0 = a_b_c_line[1]
	var c0 = a_b_c_line[2]
	var a1 = a_b_c_line_other[0]
	var b1 = a_b_c_line_other[1]
	var c1 = a_b_c_line_other[2]
	var x = (b0 * c1 - b1 * c0) / (a0 * b1 - a1 * b0)
	var y = (c0 * a1 - c1 * a0) / ( a0 * b1 - a1 * b0)
	return Vector2(x, y)

func get_data_to_send():
	var data = {"NodeA" : {"NodeNumber" : null, "DoorNumber" : null},
				"NodeB" : {"NodeNumber" : null, "DoorNumber" : null}}
	data["NodeA"]["NodeNumber"] = g_node_a.node_info.node_number
	data["NodeA"]["DoorNumber"] = door_a.number
	data["NodeB"]["NodeNumber"] = g_node_b.node_info.node_number
	data["NodeB"]["DoorNumber"] = door_b.number
	return data

func disable_process_and_queue_free_collisions():
	if is_instance_valid(spring_collisions):
		spring_collisions.queue_free()
	set_process(false)
	set_physics_process(false)

func queue_collisions_free():
	spring_collisions.call_deferred("queue_free")

