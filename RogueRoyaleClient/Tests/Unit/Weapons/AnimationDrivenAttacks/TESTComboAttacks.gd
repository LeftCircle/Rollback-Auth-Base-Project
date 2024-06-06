extends GutTestRogue

signal character_created()

var test_char

func test_shield_combo() -> void:
	# Instance character, dagger, and shield
	var character = TestFunctions.init_player_character()
	await get_tree().process_frame
	_add_dagger_and_shield_to_character(character)
	var dagger = character.primary_weapon
	var shield = character.secondary_weapon
	var frame = TestFunctions.random_frame()
	frame = _set_up_combo(frame, character)
	#_assert_combo_occurs(character, character.primary_weapon, character.secondary_weapon)
	assert_eq(dagger.weapon_data.attack_end, WeaponData.ATTACK_END.COMBO_SECONDARY)
	assert_eq(shield.weapon_data.attack_sequence, shield.get_combo_sequence())
	
	# The secondary weapon execution begins during the end of the ATTACK PRIMARY state
	assert_eq(_get_player_state(character), SystemController.STATES.ATTACK_PRIMARY)
	assert_eq(shield.weapon_data.attack_end, WeaponData.ATTACK_END.NONE)
	assert_eq(shield.get_current_animation_tree_node(), "Combo")
	assert_eq(shield.weapon_data.animation_frame, 1)

	frame = _play_weapon_animation_to_end(frame, character, shield)
	frame = TestFunctions.register_input_and_execute_frame(frame, character, InputActions.new())

	#_assert_combo_ends(character, character.primary_weapon, character.secondary_weapon)
	assert_eq(_get_player_state(character), SystemController.STATES.MOVE)
	assert_eq(shield.weapon_data.is_executing, false)
	assert_eq(dagger.weapon_data.is_executing, false)
	TestFunctions.queue_scenes_free([character, dagger, shield])
	await get_tree().process_frame

func test_dagger_combo() -> void:
	var character = TestFunctions.init_player_character()
	await get_tree().process_frame
	_add_dagger_and_shield_to_character(character)
	var dagger = character.primary_weapon
	var shield = character.secondary_weapon
	var frame = TestFunctions.random_frame()
	frame = _set_up_combo(frame, character, true)

	#_assert_primary_combo_occurs(character, dagger, shield)
	assert_eq(shield.weapon_data.attack_end, WeaponData.ATTACK_END.COMBO_PRIMARY)
	assert_eq(dagger.weapon_data.attack_sequence, dagger.get_combo_sequence())
	
	# The primary weapon begins execution at the end of the secondary weapon execution while still 
	# in the secondary attack state
	assert_eq(_get_player_state(character), SystemController.STATES.ATTACK_SECONDARY)
	assert_eq(dagger.weapon_data.attack_end, WeaponData.ATTACK_END.NONE)
	assert_eq(dagger.get_current_animation_tree_node(), "Combo")

	frame = _play_weapon_animation_to_end(frame, character, dagger)

	#_assert_combo_ends(character, dagger, shield)
	frame = TestFunctions.register_input_and_execute_frame(frame, character, InputActions.new())
	assert_eq(_get_player_state(character), SystemController.STATES.MOVE)
	assert_eq(shield.weapon_data.is_executing, false)
	assert_eq(dagger.weapon_data.is_executing, false)

	frame = TestFunctions.register_input_and_execute_frame(frame, character, InputActions.new())

	assert_eq(_get_player_state(character), SystemController.STATES.MOVE)
	TestFunctions.queue_scenes_free([character, dagger, shield])
	await get_tree().process_frame

func test_shield_and_dagger_have_the_same_input_queue():
	var character = TestFunctions.init_player_character()
	await get_tree().process_frame
	_add_dagger_and_shield_to_character(character)
	var dagger = character.primary_weapon
	var shield = character.secondary_weapon
	assert_eq(dagger.animation_tree.input_queue, shield.animation_tree.input_queue)
	TestFunctions.queue_scenes_free([character, dagger, shield])
	await get_tree().process_frame

func test_combo_attack_does_not_perform_until_input_is_released() -> void:
	var character = TestFunctions.init_player_character()
	await get_tree().process_frame
	_add_dagger_and_shield_to_character(character)
	var dagger = character.primary_weapon
	var shield = character.secondary_weapon
	var frame = TestFunctions.random_frame()

	# Start secondary combo with input_queue held frames of 1 and input held
	frame = character_attack_primary_attack_release_attack_secondary(frame, character)
#	var attack_primary_input = TestFunctions.create_attack_pressed_action(true)
#	var attack_released = TestFunctions.create_attack_pressed_action(false)
	var attack_secondary_input = TestFunctions.create_attack_secondary_pressed_action(true)
#	frame = TestFunctions.register_input_and_execute_frame(frame, character, attack_primary_input)
#	frame = TestFunctions.register_input_and_execute_frame(frame, character, attack_released)
#	frame = TestFunctions.register_input_and_execute_frame(frame, character, attack_secondary_input)

	# Finish the animation but reset the input queue so that held frames is one
	#var attack_secondary_input = TestFunctions.create_attack_secondary_pressed_action(false)
	frame = _play_animation_to_end_and_set_input_queue_held_frames_to_one(frame, character, dagger, attack_secondary_input)

	# Assert the weapon is in anticipation and a combo is to occur
	assert_eq(shield.get_current_animation_tree_node(), "Anticipation")
	frame = TestFunctions.register_input_and_execute_frame(frame, character, attack_secondary_input)
	assert_eq(shield.get_current_animation_tree_node(), "Anticipation")
	assert_true(shield.weapon_data.combo_to_occur)

	# Assert a combo occurs once the input is released
	frame = TestFunctions.register_input_and_execute_frame(frame, character, InputActions.new())
	assert_eq(shield.get_current_animation_tree_node(), "Combo")
	assert_eq(shield.weapon_data.animation_frame, 1)

	TestFunctions.queue_scenes_free([character, dagger, shield])
	await get_tree().process_frame


func test_charge_attack_occurs_if_input_is_held() -> void:
	var character = TestFunctions.init_player_character()
	await get_tree().process_frame
	_add_dagger_and_shield_to_character(character)
	var dagger = character.primary_weapon
	var shield = character.secondary_weapon
	var frame = TestFunctions.random_frame()

	# Combo with the shield with attack secondary input held
	var attack_secondary_input = TestFunctions.create_attack_secondary_pressed_action(true)
	frame = _set_up_combo(frame, character, false, attack_secondary_input)

	# confirm that the charging animation is being played
	assert_eq(shield.get_current_animation_tree_node(), "Charging")
	assert_false(shield.weapon_data.combo_to_occur)
	TestFunctions.queue_scenes_free([character, dagger, shield])
	await get_tree().process_frame

func test_attack_1_occurs_after_combo_with_input() -> void:
	_create_character_with_dagger_and_shield()
	await character_created
	var character = test_char
	
	var frame = TestFunctions.random_frame()
	frame = _set_up_combo(frame, character, true)
	assert_true(character.primary_weapon.weapon_data.is_executing)

	# queue an attack input
	frame = _start_attack_primary_after_combo(frame, character)
	frame = _play_weapon_animation_to_end(frame, character, character.primary_weapon, InputActions.new(), 1)
	
	_assert_attack_1_is_occuring(character)
	character.queue_free()
	await get_tree().process_frame

func _create_character_with_dagger_and_shield():
	test_char = TestFunctions.init_player_character()
	await get_tree().process_frame
	_add_dagger_and_shield_to_character(test_char)
	emit_signal("character_created")

func _start_attack_primary_after_combo(frame : int, character) -> int:
	var attack_pressed = TestFunctions.create_attack_pressed_action(true)
	var attack_released = TestFunctions.create_attack_pressed_action(false)
	frame = TestFunctions.register_input_and_execute_frame(frame, character, InputActions.new())
	frame = TestFunctions.register_input_and_execute_frame(frame, character, attack_pressed)
	frame = TestFunctions.register_input_and_execute_frame(frame, character, attack_released)
	return frame

func _assert_attack_1_is_occuring(character) -> void:
	var shield = character.secondary_weapon
	var dagger = character.primary_weapon
	assert_false(dagger.animation_tree.input_queue.is_input_queued(), "No inputs should be queued at the start of the attack")
	assert_eq(_get_player_state(character), SystemController.STATES.ATTACK_PRIMARY)
	assert_eq(shield.weapon_data.is_executing, false, "Shield shouldn't be executing")
	assert_eq(dagger.weapon_data.is_executing, true, "Dagger should be executing")
	assert_eq(dagger.get_current_animation_tree_node(), "Attack_1", "Attack_1 should occur after combo")

func test_regular_attack_occurs_without_stamina():
	var character = TestFunctions.init_player_character()
	await get_tree().process_frame

	# Drain the player of stamina
	#character.stamina.reset_stamina_to_x_active_nodes(character.stamina.data_container, 0)
	var stamina = character.get_component("Stamina")
	stamina.reset_stamina_to_x_active_nodes(0)
	#_add_dagger_and_shield_to_character(character)
#	var dagger = character.primary_weapon
#	var shield = character.secondary_weapon
	var dagger = character.get_primary_weapon()
	var shield = character.get_secondary_weapon()
	var frame = TestFunctions.random_frame()
	# Start the combo

	frame = _set_up_combo(frame, character)

	# Assert the combo fails and secondary attack begins
	assert_eq(_get_player_state(character), SystemController.STATES.ATTACK_PRIMARY)
	assert_eq(shield.weapon_data.is_executing, true)
	assert_eq(dagger.weapon_data.is_executing, false)
	assert_eq(shield.weapon_data.attack_sequence, 1)
	assert_eq(shield.get_current_animation_tree_node(), "Attack_1")
	assert_false(shield.weapon_data.combo_to_occur)
	var input_queue = character.get_component("InputQueue")
	assert_false(input_queue.is_input_queued())
	TestFunctions.queue_scenes_free([character, dagger, shield])
	await get_tree().process_frame

func test_input_queue_data_is_saved_to_history_on_combo_start() -> void:
	var character = TestFunctions.init_player_character()
	await get_tree().process_frame
	_add_dagger_and_shield_to_character(character)
	var dagger = character.primary_weapon
	var shield = character.secondary_weapon
	var frame = TestFunctions.random_frame()

	frame = character_attack_primary_attack_release_attack_secondary(frame, character)

	frame = _play_animation_to_end_and_set_input_queue_held_frames_to_one(frame, character, dagger, TestFunctions.create_attack_secondary_pressed_action(true))
	var final_frame = CommandFrame.get_previous_frame(frame)
	var input_queue = character.get_component("InputQueue")
	var input_queue_history = input_queue.history.retrieve_data(final_frame)
	assert_eq(input_queue_history.input, InputQueueComponent.string_to_int["attack_secondary"])

	# I have no clue why held frames would be three???
	#assert_eq(input_queue_history.held_frames, 3)
	TestFunctions.queue_scenes_free([character, dagger, shield])
	await get_tree().process_frame

func test_combo_does_not_occur_after_charge_attack() -> void:
	var character = TestFunctions.init_player_character()
	await get_tree().process_frame
	_add_dagger_and_shield_to_character(character)
	var dagger = character.primary_weapon
	var shield = character.secondary_weapon
	var frame = TestFunctions.random_frame()

	# Set up a charging animation
	var attack_primary = TestFunctions.create_attack_pressed_action(true)
	var attack_released = TestFunctions.create_attack_pressed_action(false)
	var attack_secondary = TestFunctions.create_attack_secondary_pressed_action(true)
	var attack_secondary_released = TestFunctions.create_attack_secondary_pressed_action(false)

	for _i in range(30):
		frame = TestFunctions.register_input_and_execute_frame(frame, character, attack_primary)

	assert_eq(dagger.get_current_animation_tree_node(), "Charging")
	frame = TestFunctions.register_input_and_execute_frame(frame, character, attack_released)
	assert_eq(dagger.get_current_animation_tree_node(), "ChargeAttack")
	# Queue a secondary attack
	frame = TestFunctions.register_input_and_execute_frame(frame, character, attack_secondary)
	frame = TestFunctions.register_input_and_execute_frame(frame, character, attack_secondary_released)

	frame = _play_weapon_animation_to_end(frame, character, dagger)
	frame = TestFunctions.register_input_and_execute_frame(frame, character, InputActions.new())

	assert_eq(_get_player_state(character), SystemController.STATES.ATTACK_SECONDARY)
	assert_eq(shield.weapon_data.is_executing, true)
	assert_eq(dagger.weapon_data.is_executing, false)
	assert_eq(shield.get_current_animation_tree_node(), "Attack_1")

	TestFunctions.queue_scenes_free([character, dagger, shield])
	await get_tree().process_frame

func _set_up_combo(frame : int, character, primary_combo = false, with_input_held = InputActions.new()) -> int:
	var attack_action
	var attack_released
	var other_attack_action
	if primary_combo:
		attack_action = TestFunctions.create_attack_secondary_pressed_action(true)
		attack_released = TestFunctions.create_attack_secondary_pressed_action(false)
		other_attack_action = TestFunctions.create_attack_pressed_action(true)
	else:
		attack_action = TestFunctions.create_attack_pressed_action(true)
		attack_released = TestFunctions.create_attack_pressed_action(false)
		other_attack_action = TestFunctions.create_attack_secondary_pressed_action(true)
	var empty_action = InputActions.new()
	frame = TestFunctions.register_input_and_execute_frame(frame, character, attack_action)
	frame = TestFunctions.register_input_and_execute_frame(frame, character, attack_released)
	frame = TestFunctions.register_input_and_execute_frame(frame, character, other_attack_action)
	var weapon = character.secondary_weapon if primary_combo else character.primary_weapon
	frame = _play_weapon_animation_to_end(frame, character, weapon, with_input_held)
	return frame

func character_attack_primary_attack_release_attack_secondary(frame : int, character) -> int:
	var attack_primary_input = TestFunctions.create_attack_pressed_action(true)
	var attack_released = TestFunctions.create_attack_pressed_action(false)
	var attack_secondary_input = TestFunctions.create_attack_secondary_pressed_action(true)
	frame = TestFunctions.register_input_and_execute_frame(frame, character, attack_primary_input)
	frame = TestFunctions.register_input_and_execute_frame(frame, character, attack_released)
	frame = TestFunctions.register_input_and_execute_frame(frame, character, attack_secondary_input)
	return frame

func _assert_combo_occurs(character, dagger, shield) -> void:
	assert_eq(dagger.weapon_data.attack_end, WeaponData.ATTACK_END.COMBO_SECONDARY)
	assert_eq(shield.weapon_data.attack_sequence, shield.get_combo_sequence())
	assert_eq(_get_player_state(character), SystemController.STATES.ATTACK_SECONDARY)
	assert_eq(shield.weapon_data.attack_end, WeaponData.ATTACK_END.NONE)
	assert_eq(shield.get_current_animation_tree_node(), "Combo")

func _assert_primary_combo_occurs(character, dagger, shield) -> void:
	assert_eq(shield.weapon_data.attack_end, WeaponData.ATTACK_END.COMBO_PRIMARY)
	assert_eq(dagger.weapon_data.attack_sequence, dagger.get_combo_sequence())
	assert_eq(_get_player_state(character), SystemController.STATES.ATTACK_PRIMARY)
	assert_eq(dagger.weapon_data.attack_end, WeaponData.ATTACK_END.NONE)
	assert_eq(dagger.get_current_animation_tree_node(), "Combo")

func _play_weapon_animation_to_end(frame : int, character, weapon, with_input_held = InputActions.new(), stop_on_attack_sequence = -1):
	var failsafe = 0
	var final_frame = 0
	while weapon.weapon_data.is_executing:
		frame = TestFunctions.register_input_and_execute_frame(frame, character, with_input_held)
		final_frame += 1
		failsafe += 1
		if failsafe > 300:
			assert_true(false)
			break
		if weapon.weapon_data.attack_sequence == stop_on_attack_sequence:
			break
	return frame

func _play_animation_to_end_and_set_input_queue_held_frames_to_one(frame : int, character, weapon, with_input_held = InputActions.new()):
	var failsafe = 0
	var final_frame = 0
	while weapon.weapon_data.is_executing:
		frame = TestFunctions.register_input_and_execute_frame(frame, character, with_input_held)
		failsafe += 1
		final_frame += 1
		var input_queue = character.get_component("InputQueue")
		input_queue.data_container.held_frames = 1
		input_queue.history.add_data(frame, input_queue.data_container)
		if failsafe > 300:
			assert_true(false)
			break
	return frame

func _get_player_state(character) -> int:
	var state_system_component = character.get_component("StateSystem")
	return state_system_component.data_container.state

func _assert_combo_ends(character, dagger, shield) -> void:
	assert_eq(_get_player_state(character), SystemController.STATES.MOVE)
	assert_eq(shield.weapon_data.is_executing, false)
	assert_eq(dagger.weapon_data.is_executing, false)

func _add_dagger_and_shield_to_character(character) -> void:
	var dagger = TestFunctions.instance_scene(dagger_path)
	var shield = TestFunctions.instance_scene(shield_path)
	character.add_weapon(0, dagger)
	character.add_weapon(0, shield)
