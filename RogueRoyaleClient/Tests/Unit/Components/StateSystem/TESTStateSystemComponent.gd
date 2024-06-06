extends GutTestRogue



func test_resetting_to_attack_queue_frame_queues_entity_to_attack_system():
	# Setting up the frame and character
	var frame = TestFunctions.random_frame()
	var frame_entity_is_queued = frame
	var test_id = randi_range(0, 1000)
	var entity = TestFunctions.init_player_character(test_id)
	await get_tree().process_frame

	# Isolating state component and starting attack
	var state_system_component : C_StateSystemState = entity.get_component("StateSystem")
	
	# Get the character to attack for a frame
	var attack_input = TestFunctions.create_attack_pressed_action(true)
	frame = TestFunctions.register_input_and_execute_frame(frame, entity, attack_input)

	assert_true(AttackPrimaryStateSystem.is_entity_queued(entity))
	assert_eq(state_system_component.data_container.state, SystemController.STATES.MOVE)
	assert_eq(state_system_component.data_container.queued_state, SystemController.STATES.ATTACK_PRIMARY)
	
	# Performing an empty action to advance the attack and register the player to the AttackPrimaryStateSystem
	var empty_action = InputActions.new()
	frame = TestFunctions.register_input_and_execute_frame(frame, entity, empty_action)
	assert_true(AttackPrimaryStateSystem.is_entity_registered(entity))

	# Now reset to the frame the entity is queued into the attack system
	_trigger_rollback(frame_entity_is_queued)
	
	assert_true(AttackPrimaryStateSystem.is_entity_queued(entity))
	assert_false(AttackPrimaryStateSystem.is_entity_registered(entity))
	assert_true(MoveStateSystem.is_entity_registered(entity))
	assert_true(MoveStateSystem.is_entity_queued_to_unregister(entity))
	entity.queue_free()
	await get_tree().process_frame

func _trigger_rollback(frame_entity_is_queued : int):
	MissPredictFrameTracker.frame_init(0)
	MissPredictFrameTracker.add_reset_frame(frame_entity_is_queued)
	var entities = get_tree().get_nodes_in_group("Entities")
	var reset_frame = MissPredictFrameTracker.frame_to_reset_to
	SystemController.prep_systems_for_rollback(reset_frame)
	RollbackSystem._reset_entities_to_frame(reset_frame, entities)
