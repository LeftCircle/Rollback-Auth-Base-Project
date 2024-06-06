extends C_BaseStateSystem
# Move State System

func _init_state_system_int():
	state_system_int = SystemController.STATES.MOVE

func _init_required_component_groups():
	required_component_groups = ["Move", "StateSystem", "InputQueue"]

func execute(frame : int) -> void:
	super.execute(frame)
	# Perform the move logic first, then check for exit
	for entity in registered_entities:
		var move_component : C_Move = entity.get_component("Move")
		move_component.execute(frame, entity, entity.input_actions.get_input_vector())
		animate(entity.animation_tree, move_component.velocity)
		check_for_exit(frame, entity)

func animate(animation_tree : LocalRollbackAnimationTree, velocity : Vector2) -> void:
	if velocity.length_squared() > 0:
		animation_tree.start_playing_node("Run", velocity.normalized())
	else:
		animation_tree.start_playing_node("Idle", velocity.normalized())
	animation_tree.execute(0)

func _send_netcode_data(entity) -> void:
	var move_component = entity.get_component("Move")
	move_component.netcode.send_to_clients()

func check_for_exit(frame : int, entity) -> void:
	var input_queue : InputQueueComponent = entity.get_component("InputQueue")
	if entity.input_actions.is_action_just_pressed("dodge") or input_queue.queued_input_is("dodge"):
		switch_state_system(frame, entity, DodgeStateSystem)
	elif entity.input_actions.is_action_just_pressed("attack_primary") or input_queue.queued_input_is("attack_primary"):
		switch_state_system(frame, entity, AttackPrimaryStateSystem)
	elif entity.input_actions.is_action_just_pressed("attack_secondary") or input_queue.queued_input_is("attack_secondary"):
		switch_state_system(frame, entity, AttackSecondaryStateSystem)
	elif entity.input_actions.is_action_just_pressed("dash") or input_queue.queued_input_is("dash"):
		pass
	elif entity.input_actions.is_action_just_pressed("draw_ranged_weapon") or input_queue.queued_input_is("draw_ranged_weapon"):
		pass
	elif entity.input_actions.is_action_just_pressed("health_flask") or input_queue.queued_input_is("health_flask"):
		pass

static func move_entity(frame : int, entity, speed_mod = 1.0, acc_mod = 1.0, delta : float = CommandFrame.frame_length_sec) -> void:
	var move_component : Move = entity.get_component("Move")
	var move_data : MoveData = move_component.data_container
	var input_vector = entity.input_actions.get_input_vector()
	if input_vector == Vector2.ZERO:
		move_data.velocity = move_data.velocity.move_toward(Vector2.ZERO, move_data.friction * delta)
	else:
		move_data.velocity = move_data.velocity.move_toward(input_vector * move_data.max_speed * speed_mod, move_data.acceleration * acc_mod * delta)
		if move_data.velocity.length_squared() > pow(move_data.max_speed * speed_mod, 2):
			move_data.velocity = move_data.velocity.normalized() * move_data.max_speed * speed_mod
	entity.set_velocity(move_data.velocity)
	entity.move_and_slide()
	move_data.velocity = entity.velocity
