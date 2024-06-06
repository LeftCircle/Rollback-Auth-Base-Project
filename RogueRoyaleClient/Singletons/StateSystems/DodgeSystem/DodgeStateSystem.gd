extends C_BaseStateSystem


func _init_required_component_groups() -> void:
	required_component_groups = ["Move", "StateSystem", "InputQueue", 'Stamina', 'Dodge']

func _init_state_system_int() -> void:
	state_system_int = SystemController.STATES.DODGE

func queue_entity(frame : int, entity) -> void:
	# Check if the entity has enough stamina to dodge
	var stamina : ClientStamina = entity.get_component('Stamina')
	if stamina.current_stamina >= 1:
		super.queue_entity(frame, entity)
		stamina.execute(frame, 1)
	else:
		switch_without_unregister(frame, entity, MoveStateSystem)

func _on_entity_registered(frame : int, entity) -> void:
	super._on_entity_registered(frame, entity)
	var dodge_component : AnimationDrivenDodge = entity.get_component("Dodge")
	dodge_component.data_container.animation_frame = 0
	var animation_tree : LocalRollbackAnimationTree = entity.animation_tree
	animation_tree.start_playing_node_at_position("Dodge", entity.input_vector)
	var input_queue : C_InputQueue = entity.get_component("InputQueue")
	input_queue.reset(frame)
	Logging.log_line("Player entered dodge state")

func execute(frame : int) -> void:
	super.execute(frame)
	# Perform the move logic first, then check for exit
	for entity in registered_entities:
		var move_component = entity.get_component("Move")
		var dodge_component : AnimationDrivenDodge = entity.get_component("Dodge")
		var input_queue : C_InputQueue = entity.get_component("InputQueue")
		var animation_tree : LocalRollbackAnimationTree = entity.animation_tree
		animation_tree.execute(frame)
		input_queue.execute(frame, entity.input_actions)
		move_component.execute(frame, entity, entity.input_actions.get_input_vector())
		dodge_component.data_container.animation_frame += 1
		if animation_tree.is_node_finished():
			_exit_dodge_system(frame, input_queue, entity)
		ComponentUpdateTracker.track_client_update(frame, dodge_component)

func _exit_dodge_system(frame : int, input_queue : InputQueueComponent, entity) -> void:
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
	else:
		print("Leaving dodge system to move")
		switch_state_system(frame, entity, MoveStateSystem)
