extends GutTestRogue


func test_character_can_be_reset_to_proper_attack_state() -> void:
	var desired_state = SystemController.STATES.ATTACK_SECONDARY
	var character = TestFunctions.init_player_character()
	await get_tree().process_frame
	var frame = TestFunctions.random_frame()
	var server_data = StateSystemData.new()
	server_data.state = desired_state

	var state_system_comp : C_StateSystemState = character.get_component("StateSystem")
	state_system_comp.history.add_data(frame, server_data)
	state_system_comp.reset_to_frame(frame)
	assert_true(AttackSecondaryStateSystem.is_entity_registered(character))
	character.queue_free()

func test_weapon_is_disabled_on_system_exit() -> void:
	var character = TestFunctions.init_player_character()
	await get_tree().process_frame
	var frame = _enter_character_into_attack_primary_state(character, TestFunctions.random_frame())
	frame = TestFunctions.register_input_and_execute_frame(frame, character, InputActions.new())
	var primary_weapon = character.get_primary_weapon()
	# reset the character to the move state, and confirm that the weapon has been deactivated
	var server_data = StateSystemData.new()
	server_data.state = SystemController.STATES.ATTACK_PRIMARY

	var state_system_comp : C_StateSystemState = character.get_component("StateSystem")
	state_system_comp.history.add_data(frame, server_data)
	state_system_comp.reset_to_frame(frame)
	AttackPrimaryStateSystem.unregister_immediately(frame, character)
	assert_eq(primary_weapon.end_execution_frame, frame)
	character.queue_free()

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
