extends BaseStamina
class_name S_Stamina

func execute(frame : int, n_stamina : int, to_reset_timers = true) -> bool:
	var has_stamina = super.execute(frame, n_stamina, to_reset_timers)
	_queue_data_to_send()
	return has_stamina

func refill_x_stamina(frame : int, n_stamina_to_refill : int) -> void:
	super.refill_x_stamina(frame, n_stamina_to_refill)
	_queue_data_to_send()

func physics_process(frame : int) -> void:
	super.physics_process(frame)
	netcode.set_state_data(self)

func reset_timers(frame : int) -> void:
	super.reset_timers(frame)
	_queue_data_to_send()

func reset_and_stop_timers(frame : int) -> void:
	super.reset_and_stop_timers(frame)
	_queue_data_to_send()

func reset_stamina_to_x_active_nodes(n_nodes : int) -> void:
	for i in range(stamina_nodes.size()):
		var node = stamina_nodes[i] as BaseStaminaNode
		if i < n_nodes:
			node.refill()
		else:
			node.use_stamina()
	current_stamina = n_nodes
	_queue_data_to_send()

func _queue_data_to_send():
	#netcode.set_state_data(self)
	netcode.send_to_clients()
