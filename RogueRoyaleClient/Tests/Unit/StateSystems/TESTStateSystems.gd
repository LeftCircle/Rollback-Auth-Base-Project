extends GutTestRogue


# This tests the transitions between the MoveState and AttackState

func test_move_state_system_and_attack_state_system_are_valid():
	assert_true(is_instance_valid(MoveStateSystem))
	assert_true(is_instance_valid(AttackPrimaryStateSystem))
	assert_true(is_instance_valid(SystemController))
	assert_true(SystemController.has_state_system(MoveStateSystem))
	assert_true(SystemController.has_state_system(AttackPrimaryStateSystem))

func test_entities_enter_queue_on_register_and_entity_list_on_system_execute() -> void:
	var character = init_character_with_move_component()
	await get_tree().process_frame
	#MoveStateSystem.queue_entity(0, character)
	assert_true(MoveStateSystem.is_entity_queued_or_registered(character))
	MoveStateSystem.execute(1)
	assert_true(MoveStateSystem.is_entity_registered(character))
	assert_false(MoveStateSystem.is_entity_queued(character))
	character.queue_free()
	# This prevents the entity from being unregistered in the middle of execution
	assert_true(MoveStateSystem.is_entity_registered(character))
	await get_tree().process_frame
	assert_false(MoveStateSystem.is_entity_registered(character))

func test_entities_can_be_immediately_registered() -> void:
	var character = init_character_with_move_component()
	await get_tree().process_frame
	MoveStateSystem.register_immediately(0, character)
	assert_true(MoveStateSystem.is_entity_registered(character))
	character.queue_free()
	await get_tree().process_frame

func test_entities_can_be_unregistered_from_system_queue_and_register() -> void:
	var character = init_character_with_move_component()
	await get_tree().process_frame
	MoveStateSystem.queue_entity(0, character)
	assert_true(MoveStateSystem.is_entity_queued(character))
	MoveStateSystem.unregister_entity(CommandFrame.frame, character)
	assert_true(MoveStateSystem.is_entity_queued(character))
	assert_true(MoveStateSystem.is_entity_queued_to_unregister(character))
	MoveStateSystem.execute(CommandFrame.get_next_frame())
	await get_tree().process_frame
	assert_false(MoveStateSystem.is_entity_queued(character))
	assert_false(MoveStateSystem.is_entity_queued_to_unregister(character))
	assert_true(MoveStateSystem.is_entity_registered(character))
	assert_true(MoveStateSystem.are_entity_signals_connected(character))
	character.queue_free()
	await get_tree().physics_frame
	assert_false(MoveStateSystem.has_registered_entities())

func test_move_system_has_required_components() -> void:
	assert_eq(MoveStateSystem.required_component_groups.size(), 3)
	assert_true("Move" in MoveStateSystem.required_component_groups)

func test_system_controller_has_all_entities() -> void:
	var character = TestFunctions.init_player_character()
	await get_tree().process_frame
	assert_true(SystemController.has_entity(character))
	character.queue_free()
	await get_tree().process_frame

func test_entities_are_only_added_if_they_have_required_component_groups() -> void:
	var character = init_character_with_move_component()
	await get_tree().physics_frame
	character.remove_component(character.get_component("Move"))
	#assert_false(is_instance_valid(character.move))
	MoveStateSystem.queue_entity(0, character)
	assert_true(MoveStateSystem.is_entity_queued(character))
	MoveStateSystem.execute(1)
	assert_false(MoveStateSystem.is_entity_queued(character))
	assert_false(MoveStateSystem.is_entity_registered(character))
	character.queue_free()
	await get_tree().process_frame

func test_entities_exit_system_if_required_components_are_lost() -> void:
	var character = init_character_with_move_component()
	await get_tree().process_frame
	MoveStateSystem.queue_entity(0, character)
	assert_true(MoveStateSystem.is_entity_queued(character))
	MoveStateSystem.execute(1)
	assert_true(MoveStateSystem.is_entity_registered(character))
	character.remove_component(character.get_component("Move"))
	assert_false(MoveStateSystem.is_entity_registered(character))
	character.queue_free()
	await get_tree().process_frame

func test_characters_add_themselves_to_MoveStateSystem_on_ready() -> void:
	var character = TestFunctions.init_player_character()
	await get_tree().process_frame
	MoveStateSystem.execute(CommandFrame.get_next_frame())
	assert_true(MoveStateSystem.is_entity_registered(character))
	character.queue_free()
	await get_tree().process_frame

func test_entity_enters_attack_state_from_move_if_attack_primary_input_pressed() -> void:
	var character = TestFunctions.init_player_character()
	randomize()
	var rand_frame = randi() % CommandFrame.MAX_FRAME_NUMBER
	await get_tree().process_frame
	var attack_inputs = TestFunctions.create_attack_pressed_action(true)
	rand_frame = TestFunctions.register_input_and_execute_frame(rand_frame, character, attack_inputs)
	assert_true(AttackPrimaryStateSystem.is_entity_queued(character))
	assert_true(MoveStateSystem.is_entity_queued_to_unregister(character))
	character.queue_free()
	await get_tree().process_frame

func test_move_system_actually_moves_entity() -> void:
	var character = TestFunctions.init_player_character()
	randomize()
	var rand_frame = randi() % CommandFrame.MAX_FRAME_NUMBER
	await get_tree().process_frame
	character.remove_from_group("LocalPlayer")
	var input = ActionFromClient.new()
	input.action_data.input_vector = Vector2(1, 0)
	InputProcessing.receive_action_for_player(CommandFrame.get_previous_frame(rand_frame), character.player_id, input)
	InputProcessing.receive_action_for_player(rand_frame, character.player_id, input)
	SystemController.execute(rand_frame)
	assert_true(character.position.x > 0)
	character.queue_free()
	await get_tree().process_frame

func init_character_with_move_component():
	var character = TestFunctions.init_player_character()
	return character
