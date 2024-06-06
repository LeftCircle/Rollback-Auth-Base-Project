extends GutTestRogue


func test_reset_to_server_data():
	var character = TestFunctions.init_player_character()
	await get_tree().process_frame
	var dagger = character.get_primary_weapon()
	var server_data = _create_finisher_server_data(dagger.weapon_data)
	dagger.reset_to(server_data)
	assert_true(_animation_finisher_match(dagger, server_data))

	# Place the character in the AttackStateSystem
	var frame = TestFunctions.random_frame()
	var server_system = StateSystemData.new()
	server_system.state = SystemController.STATES.ATTACK_PRIMARY
	var state_system : C_StateSystemState = character.get_component("StateSystem")
	state_system.data_container.set_data_with_obj(server_system)
	state_system.save_history(frame)
	state_system.reset_to_frame(frame)
	assert_true(AttackPrimaryStateSystem.is_entity_registered(character))
	assert_false(MoveStateSystem.is_entity_queued(character))
	assert_eq(state_system.data_container.state, SystemController.STATES.ATTACK_PRIMARY)
	#frame = CommandFrame.get_next_frame(frame)

	TestFunctions.register_input_and_execute_frame(frame, character, InputActions.new())
	assert_eq(dagger.weapon_data.animation_frame, server_data.animation_frame + 1)
	character.queue_free()
	await get_tree().process_frame

func test_combo_does_not_occur_with_finisher():
	var character = TestFunctions.init_player_character()
	await get_tree().process_frame
	var dagger = character.get_primary_weapon()
	var server_data = _create_finisher_server_data(dagger.weapon_data)
	server_data.animation_frame = 31
	dagger.reset_to(server_data)
	assert_true(dagger.weapon_data.main_animation_ended)
	execute_attack_secondary(dagger)
	assert_true(dagger.weapon_data.attack_end == WeaponData.ATTACK_END.SECONDARY)
	character.queue_free()
	await get_tree().process_frame

func _animation_finisher_match(dagger, server_data) -> bool:
	var expected_animation_pos = server_data.animation_frame * CommandFrame.frame_length_sec
	var actual = dagger.animation_tree.state_machine_playback.get_current_play_position()
	if not is_equal_approx(actual, expected_animation_pos):
		return false
	if not dagger.animation_tree.state_machine_playback.get_current_node() == "Finisher":
		return false
	return true

func _create_finisher_server_data(weapon_data : WeaponData) -> MeleeWeaponData:
	var server_data = MeleeWeaponData.new()
	server_data.attack_sequence = weapon_data.max_sequence
	server_data.animation_frame = 3
	server_data.attack_direction = Vector2(1, 0)
	server_data.is_in_parry = true
	server_data.is_executing = true
	return server_data

func execute_attack_secondary(dagger) -> void:
	var attack_secondary = TestFunctions.create_attack_secondary_pressed_action(true)
	var attack_end : int = dagger.execute(0, attack_secondary)
