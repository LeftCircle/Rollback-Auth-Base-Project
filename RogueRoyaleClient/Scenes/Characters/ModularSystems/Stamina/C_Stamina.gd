#tool
extends BaseStamina
class_name ClientStamina

@export var radius = 10 # (float, 0, 1000)
@export var stamina_spread_degrees = 180 # (float, 60, 270)

func _init_history():
	history = StaminaHistory.new()

func reset_to_frame(frame : int) -> void:
	var hist = history.retrieve_data(frame)
	if not hist == BaseModularHistory.NO_DATA_FOR_FRAME:
		hist.set_obj_with_data(self)
		reset_stamina_to_x_active_nodes(current_stamina)

func execute(frame : int, n_stamina : int, to_reset_timers = true) -> bool:
	var has_stamina = super.execute(frame, n_stamina, to_reset_timers)
	netcode.on_client_update(frame)
	return has_stamina

func refill_x_stamina(frame : int, n_stamina_to_refill : int) -> void:
	super.refill_x_stamina(frame, n_stamina_to_refill)
	netcode.on_client_update(frame)

func reset_timers(frame : int):
	super.reset_timers(frame)
	netcode.on_client_update(frame)

func reset_and_stop_timers(frame : int):
	super.reset_and_stop_timers(frame)
	netcode.on_client_update(frame)

func reset_stamina_to_x_active_nodes(n_nodes : int) -> void:
	for i in range(stamina_nodes.size()):
		var node = stamina_nodes[i] as BaseStaminaNode
		if i < n_nodes:
			node.refill()
		else:
			node.use_stamina()
	current_stamina = n_nodes

func _spawn_stamina_nodes():
	var distance_between = stamina_spread_degrees / stamina
	if stamina % 2 == 0:
		var total_dist = distance_between * stamina
		var first_node_degrees = 90 - total_dist / 2.0 + distance_between / 2
		_spawn_nodes_from_starting_angle(stamina, first_node_degrees, distance_between)
	else:
		var first_node_degrees = 90 - distance_between * (stamina - 1) / 2
		_spawn_nodes_from_starting_angle(stamina, first_node_degrees, distance_between)

func _spawn_nodes_from_starting_angle(n_nodes : int, starting_degrees : float, distance_between : float):
	for i in range(n_nodes):
		var new_degrees = starting_degrees + distance_between * i
		var new_node = stamina_node.instantiate()
		var radians = deg_to_rad(new_degrees)
		new_node.position = Vector2(radius * cos(radians), radius * sin(radians))
		new_node.name = "StaminaNode_" + str(i)
		add_child(new_node)
		stamina_nodes.push_front(new_node)

func log_timers():
	Logging.log_line("Refill delay timer = ")
	stamina_refill_delay_timer.log_timer()
	Logging.log_line("Refill speed timer = ")
	stamina_refill_speed_timer.log_timer()
