extends GutTest


func test_attack_primary_state_starts_primary_weapon_execution():
	randomize()
	var rand_frame = randi() % CommandFrame.MAX_FRAME_NUMBER
	var character = TestFunctions.init_player_character()
	await get_tree().process_frame
	_enter_character_into_attack_primary_state(character, rand_frame)
	SystemController.execute(CommandFrame.get_next_frame(rand_frame))
	var state_component = character.get_component("StateSystem")
	assert_eq(state_component.data_container.state, SystemController.STATES.ATTACK_PRIMARY)
	assert_true(character.primary_weapon.weapon_data.is_executing)
	character.queue_free()

func test_attack_system_queues_move_on_weapon_end():
	randomize()
	var rand_frame = randi() % CommandFrame.MAX_FRAME_NUMBER
	var character = TestFunctions.init_player_character()
	await get_tree().process_frame
	_enter_character_into_attack_primary_state(character, rand_frame)
	var frame := CommandFrame.get_next_frame(rand_frame)
	SystemController.execute(frame)
	var empty_input := ActionFromClient.new()
	while character.primary_weapon.weapon_data.is_executing:
		frame = CommandFrame.get_next_frame(frame)
		InputProcessing.receive_action_for_player(frame, character.player_id, empty_input)
		SystemController.execute(frame)
	assert_true(MoveStateSystem.is_entity_queued(character))
	character.queue_free()

func test_combos_can_occur():
	randomize()
	var rand_frame = randi() % CommandFrame.MAX_FRAME_NUMBER
	var character = TestFunctions.init_player_character()
	character.player_id = randi() % 1000000
	await get_tree().process_frame
	_enter_character_into_attack_primary_state(character, rand_frame)
	var frame = CommandFrame.get_next_frame(rand_frame)
	SystemController.execute(frame)

	frame = CommandFrame.get_next_frame(frame)
	InputProcessing.receive_action_for_player(frame, character.player_id, ActionFromClient.new())
	SystemController.execute(frame)

	frame = CommandFrame.get_next_frame(frame)
	queue_attack_secondary_action_for_frame(character, frame)
	SystemController.execute(frame)

	var empty_input = ActionFromClient.new()
	while character.primary_weapon.weapon_data.is_executing:
		frame = CommandFrame.get_next_frame(frame)
		InputProcessing.receive_action_for_player(frame, character.player_id, empty_input)
		SystemController.execute(CommandFrame.frame)

	assert_true(AttackPrimaryStateSystem.is_entity_registered(character))
	SystemController.execute(CommandFrame.get_next_frame(frame))
	assert_true(character.secondary_weapon.weapon_data.is_executing)
	var state_component = character.get_component("StateSystem")
	assert_eq(state_component.data_container.state, SystemController.STATES.ATTACK_SECONDARY)
	character.queue_free()

#func test_weapon_is_disabled_on_system_exit() -> void:
#	var character = TestFunctions.init_player_character()
#	await get_tree().process_frame
#	var frame = _enter_character_into_attack_primary_state(character, TestFunctions.random_frame())
#	frame = TestFunctions.register_input_and_execute_frame(frame, character, InputActions.new())
#	var primary_weapon = character.get_primary_weapon()
#	# reset the character to the move state, and confirm that the weapon has been deactivated
#	var server_data = StateSystemData.new()
#	server_data.state = SystemController.STATES.MOVE
#	server_data.next_state = SystemController.STATES.ATTACK_PRIMARY
#
#	var state_system_comp = character.get_component("StateSystem")
#	state_system_comp.history.add_data(frame, server_data)
#	state_system_comp.reset_to_frame(frame)
#
#	assert_eq(primary_weapon.end_execution_frame, frame)
#	character.queue_free()

func test_weapon_switching_can_occur():
	pass

func test_charge_attacks_can_occur_on_weapon_switch():
	pass

func test_charge_attack_occurs_on_combo():
	pass

func test_input_queue_is_cleared_on_attack_state_exit():
	pass

func _enter_character_into_attack_primary_state(character, rand_frame):
	# Queue an attack input to be processed by the SystemController
	var attack_action = ActionFromClient.new()
	attack_action.action_data.attack_primary = true
	var attack_input = TestFunctions.create_attack_pressed_action(true)
#	Then execute the system and confirm that the entity is queued for the attack state
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
