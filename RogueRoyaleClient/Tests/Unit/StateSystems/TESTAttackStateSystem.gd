extends GutTestRogue


func test_attack_primary_state_starts_primary_weapon_execution():
	randomize()
	var rand_frame = randi() % CommandFrame.MAX_FRAME_NUMBER
	var character = TestFunctions.init_player_character()
	await get_tree().process_frame
	_enter_character_into_attack_primary_state(character, rand_frame)
	SystemController.entity_frame_updates(CommandFrame.get_next_frame(rand_frame), [character])
	var state_component = character.get_component("StateSystem")
	assert_eq(state_component.data_container.state, SystemController.STATES.ATTACK_PRIMARY)
	assert_true(character.primary_weapon.weapon_data.is_executing)
	character.queue_free()
	await get_tree().process_frame

func test_attack_system_queues_move_on_weapon_end():
	randomize()
	var rand_frame = randi() % CommandFrame.MAX_FRAME_NUMBER
	var character = TestFunctions.init_player_character()
	await get_tree().process_frame
	_enter_character_into_attack_primary_state(character, rand_frame)
	var frame = CommandFrame.get_next_frame(rand_frame)
	SystemController.entity_frame_updates(CommandFrame.get_next_frame(frame), [character])
	var empty_input = ActionFromClient.new()
	while character.primary_weapon.weapon_data.is_executing:
		frame = CommandFrame.get_next_frame(frame)
		InputProcessing.receive_action_for_player(frame, character.player_id, empty_input)
		SystemController.entity_frame_updates(frame, [character])
	assert_true(MoveStateSystem.is_entity_queued(character))
	character.queue_free()
	await get_tree().process_frame

func test_combos_can_occur():
	randomize()
	await next_physics_step()
	var rand_frame = randi() % CommandFrame.MAX_FRAME_NUMBER
	var character = TestFunctions.init_player_character()
	character.player_id = randi() % 1000000
	await next_physics_step()
	rand_frame = _enter_character_into_attack_primary_state(character, rand_frame)
	rand_frame = TestFunctions.execute_frame_for_entity(rand_frame, character)

	rand_frame = TestFunctions.register_input_and_execute_frame(rand_frame, character, InputActions.new())

	var attack_secondary = TestFunctions.create_attack_secondary_pressed_action(true)
	rand_frame = TestFunctions.register_input_and_execute_frame(rand_frame, character, attack_secondary)

	var empty_input = InputActions.new()
	while character.primary_weapon.weapon_data.is_executing:
		rand_frame = TestFunctions.register_input_and_execute_frame(rand_frame, character, empty_input)

	assert_true(AttackPrimaryStateSystem.is_entity_registered(character))
	assert_true(character.secondary_weapon.weapon_data.is_executing)
	var state_component = character.get_component("StateSystem")
	assert_eq(state_component.data_container.queued_state, SystemController.STATES.ATTACK_SECONDARY)
	assert_eq(state_component.data_container.state, SystemController.STATES.ATTACK_PRIMARY)
	assert_eq(state_component.data_container.queued_unregister, SystemController.STATES.ATTACK_PRIMARY)
	rand_frame = TestFunctions.register_input_and_execute_frame(rand_frame, character, empty_input)
	assert_eq(state_component.data_container.state, SystemController.STATES.ATTACK_SECONDARY)
	assert_true(character.secondary_weapon.weapon_data.is_executing)
	character.queue_free()
	await get_tree().process_frame

func test_attack_input_on_exit_frame():
	var frame = TestFunctions.random_frame()
	var character = TestFunctions.init_player_character()
	await get_tree().process_frame
	frame = _finish_primary_attack_1(character, frame)
	assert_true(AttackPrimaryStateSystem.is_entity_registered(character))
	assert_true(MoveStateSystem.is_entity_queued(character))
	assert_true(AttackPrimaryStateSystem.is_entity_queued_to_unregister(character))
	# InputActions should also be empty?

	var attack_input = TestFunctions.create_attack_pressed_action(true)
	frame = TestFunctions.register_input_and_execute_frame(frame, character, attack_input)
	assert_true(MoveStateSystem.is_entity_registered(character))
	assert_true(AttackPrimaryStateSystem.is_entity_queued(character))
	assert_true(MoveStateSystem.is_entity_queued_to_unregister(character))
	character.queue_free()
	await get_tree().physics_frame
	assert_false(is_instance_valid(character))
	assert_false(MoveStateSystem.has_registered_entities())
	assert_false(AttackPrimaryStateSystem.has_registered_entities())
	assert_false(AttackPrimaryStateSystem.has_queued_entities())
	SystemController._execute_states(frame)

func test_weapon_switching_can_occur():
	pass

func test_charge_attacks_can_occur_on_weapon_switch():
	pass

func test_charge_attack_occurs_on_combo():
	pass

func test_input_queue_is_cleared_on_attack_state_exit():
	pass

func _finish_primary_attack_1(character, frame : int) -> int:
	frame = _enter_character_into_attack_primary_state(character, frame)
	var empty_action = InputActions.new()
	frame = TestFunctions.register_input_and_execute_frame(frame, character, empty_action)
	while character.primary_weapon.weapon_data.is_executing:
		frame = TestFunctions.register_input_and_execute_frame(frame, character, empty_action)
	return frame

func _enter_character_into_attack_primary_state(character, rand_frame):
	var attack_input = TestFunctions.create_attack_pressed_action(true)
	rand_frame = TestFunctions.register_input_and_execute_frame(rand_frame, character, attack_input)
	assert_true(AttackPrimaryStateSystem.is_entity_queued(character))
	assert_true(MoveStateSystem.is_entity_queued_to_unregister(character))
	return rand_frame

func queue_attack_action_for_frame(character, frame) -> void:
	var attack_action = ActionFromClient.new()
	attack_action.action_data.attack_primary = true
	InputProcessing.receive_action_for_player(frame, character.player_id, attack_action)

func queue_attack_secondary_action_for_frame(character, frame) -> void:
	var attack_action = ActionFromClient.new()
	attack_action.action_data.attack_secondary = true
	InputProcessing.receive_action_for_player(frame, character.player_id, attack_action)
