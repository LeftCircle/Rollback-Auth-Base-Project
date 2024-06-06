extends GrammarSpring
class_name GrammarSpringRigidBody

const PI_OVER_2 = PI / 2
const FORCE_MOD = 750

var rigid_body = RigidBody2D.new()
var collision_shape = CollisionShape2D.new()

#onready var rigid_body = $RigidBody2D
#onready var collision_shape = $RigidBody2D/CollisionShape2D

func _ready():
	g_node_a.add_collision_exception_with(rigid_body)
	g_node_b.add_collision_exception_with(rigid_body)
	rigid_body.global_position = (g_node_a.get_global_position() + g_node_b.get_global_position()) / 2

func _physics_process(_delta):
	size_spring()
	var half_vec = Vector2(collision_shape.shape.size.x, 0)
	half_vec = half_vec.rotated(rigid_body.global_rotation + PI)
	collision_end_a = rigid_body.global_position + half_vec
	collision_end_b = rigid_body.global_position - half_vec
	var neg_to_a = g_node_a.global_position - collision_end_a
	var pos_to_b = g_node_b.global_position - collision_end_b
	rigid_body.apply_central_force(-rigid_body.applied_force)
	rigid_body.apply_torque(-rigid_body.applied_torque)
	rigid_body.apply_force(pos_to_b * FORCE_MOD, half_vec)
	rigid_body.apply_force(neg_to_a * FORCE_MOD, -half_vec)
	#if not deactivated:
	g_node_a.apply_central_force(-neg_to_a * FORCE_MOD * 4)#2.5)
	g_node_a.apply_central_force(-pos_to_b * FORCE_MOD * 4)#2.5)

func size_spring():
	rest_length = (g_node_a.side_length + g_node_b.side_length) * 1.5#1.75#1.65
	max_acceptable_length = 1.5 * rest_length
	if is_instance_valid(collision_shape):
		collision_shape.shape.size.x = (g_node_a.get_global_position().distance_to(
											g_node_b.get_global_position()) / 2)

func connect_nodes(nodeA : GrammarNode, nodeB : GrammarNode) -> void:
	if not nodeA.springs.size() >= nodeA.MAX_CONNECTIONS and not nodeB.springs.size() >= nodeB.MAX_CONNECTIONS:
		g_node_a = nodeA
		g_node_b = nodeB
		_add_collision_exceptions()
		g_node_a.connect("g_node_queue_free",Callable(self,"_on_g_node_queued_free"))
		g_node_b.connect("g_node_queue_free",Callable(self,"_on_g_node_queued_free"))
		spring_info.c_node_number_a = g_node_a.node_info.node_number
		spring_info.c_node_number_b = g_node_b.node_info.node_number
		if not g_node_a.has_spring_with_same_connected_nodes(self):
			g_node_a.springs.append(self)
		if not g_node_b.has_spring_with_same_connected_nodes(self):
			g_node_b.springs.append(self)
		_add_rigid_body()
		size_spring()

func _add_rigid_body():
	rigid_body.position = (g_node_a.get_global_position() + g_node_b.get_global_position()) / 2
	rigid_body.linear_damp = 100
	rigid_body.angular_damp = 100
	var rad = g_node_a.get_global_position().angle_to_point(g_node_b.get_global_position())
	rigid_body.add_collision_exception_with(g_node_a)
	rigid_body.add_collision_exception_with(g_node_b)
	rigid_body.rotation_degrees = rad_to_deg(rad)
	rigid_body.collision_layer = pow(2, 19)
	rigid_body.collision_mask = pow(2, 18)
	rigid_body.continuous_cd = rigid_body.CCD_MODE_CAST_SHAPE
	rigid_body.contact_monitor = true
	rigid_body.max_contacts_reported = 50
	var phys = PhysicsMaterial.new()
	phys.friction = 0
	rigid_body.physics_material_override = phys
	add_child(rigid_body)
	collision_shape.shape = RectangleShape2D.new()
	collision_shape.shape.size.y = 8
	rigid_body.add_child(collision_shape)

func remove_node_connection(node_to_disconnect : Node, with_number = false) -> void:
	node_to_disconnect.springs.erase(self)
	rigid_body.remove_collision_exception_with(node_to_disconnect)
	node_to_disconnect.disconnect("g_node_queue_free",Callable(self,"_on_g_node_queued_free"))
	var check = [spring_info.c_node_number_a, spring_info.c_node_number_b] if with_number else [g_node_a, g_node_b]
	if node_to_disconnect == check[0]:
		g_node_a = null
		spring_info.c_node_number_a = null
	elif node_to_disconnect == check[1]:
		g_node_b = null
		spring_info.c_node_number_b = null
	if is_instance_valid(spring_collisions):
		spring_collisions.polygon = []

func connect_new_node(node_to_connect) -> void:
	rigid_body.add_collision_exception_with(node_to_connect)
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
