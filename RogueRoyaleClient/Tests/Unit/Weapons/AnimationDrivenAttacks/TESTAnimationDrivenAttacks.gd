extends GutTestRogue
class_name TestAnimationDrivenAttacks

func test_hitbox_rotates_on_attack():
	var dagger_and_char = await _init_dagger_and_character()
	await get_tree().process_frame
	var dagger = dagger_and_char[1].get_primary_weapon()
	var test_direction = TestFunctions.get_random_direction()
	_advance_daggger_to_attack_1(dagger, test_direction)
	assert_almost_eq(dagger.rotation, test_direction.angle(), 0.01)
	assert_almost_eq(dagger.node_interpolater.global_rotation, 0, 0.01)
	_free_objects(dagger_and_char)

func _advance_daggger_to_attack_1(dagger, attack_direction : Vector2 = Vector2.ZERO) -> void:
	var attack_pressed = TestFunctions.create_attack_pressed_action(true)
	attack_pressed.current_actions.set_input_vector(attack_direction)
	#var empty_actions = InputActions.new()
	#empty_actions.current_actions.set_input_vector(attack_direction)

	dagger.execute(0, attack_pressed)
	var release_actions = _create_release_and_aimed_action(attack_direction)
	dagger.execute(0, release_actions)

func test_animation_frame_in_anticipation_hold_longer_than_animation():
	var dagger_and_char = await _init_dagger_and_character()
	await get_tree().process_frame
	var dagger = dagger_and_char[1].get_primary_weapon()
	var expected_frame = _play_animation_for_an_extra_frame(dagger, 1)
	assert_true(dagger.weapon_data.animation_frame == expected_frame)
	_free_objects(dagger_and_char)

func test_animation_frame_in_anticipation():
	var dagger_and_char = await _init_dagger_and_character()
	await get_tree().process_frame
	var dagger = dagger_and_char[1].get_primary_weapon()
	var expected_frame = _play_animation_for_an_extra_frame(dagger, -2)
	assert_eq(dagger.weapon_data.animation_frame, expected_frame) # ???
	#assert_true(dagger.weapon_data.animation_frame == expected_frame + 1)
	_free_objects(dagger_and_char)

# TO DO -> look into the weird bug caused by blend space 2d's causing the animation frame to be 0 as opposed to 1
func test_advance_to_attack_1():
	var dagger_and_char = await _init_dagger_and_character()
	await get_tree().process_frame
	var dagger = dagger_and_char[1].get_primary_weapon()
	_advance_daggger_to_attack_1(dagger)
	assert_true(dagger.weapon_data.attack_sequence == 1)
	assert_true(_animation_matches(dagger, "Attack_1"))
	assert_eq(dagger.weapon_data.animation_frame, 1)
	_free_objects(dagger_and_char)

func test_attack_sequence_map():
	var dagger_and_char = await _init_dagger_and_character()
	await get_tree().process_frame
	var dagger = dagger_and_char[1].get_primary_weapon()
	var expected = {
		0 : WeaponRollbackAnimationTreeStateMachine.STATES.ANTICIPATION,
		1 : WeaponRollbackAnimationTreeStateMachine.STATES.ATTACK,
		2 : WeaponRollbackAnimationTreeStateMachine.STATES.PREFINISHER,
		3 : WeaponRollbackAnimationTreeStateMachine.STATES.FINISHER,
		4 : WeaponRollbackAnimationTreeStateMachine.STATES.CHARGING,
		5 : WeaponRollbackAnimationTreeStateMachine.STATES.CHARGE_ATTACK,
		6 : WeaponRollbackAnimationTreeStateMachine.STATES.COMBO
	}
	assert_true(_sequence_map_matches_expected(dagger, expected))
	_free_objects(dagger_and_char)

func test_attack_animation_map():
	var dagger_and_char = await _init_dagger_and_character()
	await get_tree().process_frame
	var dagger = dagger_and_char[1].get_primary_weapon()
	var expected = {
		0 : "Anticipation",
		1 : "Attack_1",
		2 : "Attack_2",
		3 : "Finisher",
		4 : "Charging",
		5 : "ChargeAttack",
		6 : "Combo"
	}
	assert_true(_do_dicts_match(dagger.animation_tree.attack_sequence_to_animation, expected))
	_free_objects(dagger_and_char)

func test_advance_to_finisher():
	var dagger_and_char = await _init_dagger_and_character()
	var character : ClientPlayerCharacter = dagger_and_char[1]
	var dagger = dagger_and_char[1].get_primary_weapon()
	var finisher_sequence = dagger.weapon_data.max_sequence
	var frame = TestFunctions.random_frame()
	frame = _attack_with_weapon_to_sequence(frame, character, dagger, finisher_sequence)
	assert_eq(dagger.weapon_data.attack_sequence, 3)
	assert_true(_animation_matches(dagger, "Finisher"))
	_free_objects(dagger_and_char)

func _attack_with_weapon_to_sequence(frame : int, character : ClientPlayerCharacter, weapon, sequence : int, primary : bool = true) -> int:
	var pressed_action : InputActions
	var released_action : InputActions
	if primary:
		pressed_action = TestFunctions.create_attack_pressed_action(true)
		released_action = TestFunctions.create_attack_pressed_action(false)
	else:
		pressed_action = TestFunctions.create_attack_secondary_pressed_action(true)
		released_action = TestFunctions.create_attack_secondary_pressed_action(false)
	for i in range(sequence - 1):
		frame = register_input_and_execute_frame(frame, character, pressed_action)
		frame = register_input_and_execute_frame(frame, character, released_action)
		frame = register_input_and_execute_frame(frame, character, pressed_action)
		frame = register_input_and_execute_frame(frame, character, released_action)
		var attack_seq = weapon.weapon_data.attack_sequence
		frame = _play_weapon_animation_to_end(frame, character, weapon)
	return frame


func test_secondary_weapon_does_not_execute_after_primary_finisher_until_input_released():
	var character = TestFunctions.init_player_character()
	await get_tree().process_frame
	var dagger = character.get_primary_weapon()
	var shield = character.get_secondary_weapon()

	var frame = TestFunctions.random_frame()
	frame = _attack_with_weapon_to_sequence(frame, character, dagger, dagger.weapon_data.max_sequence)
	assert_eq(dagger.get_current_animation_tree_node(), "Finisher")

	var attack_secondary_input = TestFunctions.create_attack_secondary_pressed_action(true)
	var attack_sec_held : InputActions = create_held_input("attack_secondary")
	# Now perform the finisher but queue an attack secondary input
	frame = TestFunctions.register_input_and_execute_frame(frame, character, attack_secondary_input)
	frame = _play_animation_to_end_and_set_input_queue_held_frames_to_one(frame, character, dagger, attack_sec_held)

	assert_false(dagger.weapon_data.is_executing)
	assert_true(shield.weapon_data.is_executing)
	assert_eq(shield.get_current_animation_tree_node(), "Anticipation")

	var attack_secondary_released = TestFunctions.create_attack_secondary_pressed_action(false)
	frame = TestFunctions.register_input_and_execute_frame(frame, character, attack_secondary_released)
	
	# Currently fails because the entity is queued into the attack secondary state this frame?
	# Shouldn't they have been queued last frame though??
	assert_eq(shield.get_current_animation_tree_node(), "Attack_1")

	_free_objects([character, dagger, shield])

func test_dagger_rotates_and_blend_pos():
	var dagger_and_char = await _init_dagger_and_character()
	await get_tree().process_frame
	var dagger = dagger_and_char[1].get_primary_weapon()
	#var empty_actions = InputActions.new()
	var attack_actions = TestFunctions.create_attack_pressed_action(true)
	dagger.execute(0, attack_actions)
	var test_direction = TestFunctions.get_random_direction()
	var release_actions = _create_release_and_aimed_action(test_direction)
	dagger.execute(0, release_actions)
	assert_almost_eq(dagger.rotation, test_direction.angle(), 0.001)
	assert_almost_eq(dagger.weapon_data.attack_direction.angle(), test_direction.angle(), 0.001)
	# This test will be important if we add a blendspace2D
	#assert_true(_does_blend_position_match(dagger, test_direction))
	assert_true(_animation_matches(dagger, "Attack_1"))
	_free_objects(dagger_and_char)

func test_strike_sprite_rotates_after_reset():
	var dagger_and_char = await _init_dagger_and_character()
	await get_tree().process_frame
	var dagger = dagger_and_char[1].get_primary_weapon()
	var angled_left_data = _get_server_data_for_angled_left_attack()
	dagger.reset_to(angled_left_data)
	var attack_action = _create_hold_input_actions()
	dagger.execute(0, attack_action)
	assert_true(_is_stike_angled_to(dagger, angled_left_data.attack_direction))
	_free_objects(dagger_and_char)

func _animation_matches(dagger, animation : String) -> bool:
	# I have a hunch that the blend position is not being set before the animation
	# is playing, which causes the animation to be played in the wrong direction
	var dagger_anim = dagger.get_attack_animation()
	return animation == dagger_anim

func _does_blend_position_match(dagger, direction : Vector2) -> bool:
	var animation_tree = dagger.animation_tree
	var blend_pos = animation_tree.get("parameters/Attack_1/blend_position")
	return is_zero_approx((blend_pos - direction).length())

func get_dagger_data_for_straight_up_attack() -> MeleeWeaponData:
	var server_data = MeleeWeaponData.new()
	server_data.attack_sequence = 1
	server_data.animation_frame = 10
	server_data.attack_direction = Vector2(0, -1)
	server_data.is_in_parry = false
	server_data.is_executing = true
	return server_data

func get_dagger_data_for_end_of_mainanimation_for_first_attack() -> MeleeWeaponData:
	var server_data = MeleeWeaponData.new()
	server_data.attack_sequence = 1
	server_data.animation_frame = 15
	server_data.attack_direction = Vector2(1, 0)
	server_data.is_in_parry = false
	server_data.is_executing = true
	return server_data

func execute_attack_secondary(dagger) -> void:
	var attack_secondary_action = _create_attack_secondary_pressed_action()
	var attack_end : int = dagger.execute(0, attack_secondary_action)

func _is_stike_angled_to(dagger, angle : Vector2) -> bool:
	var strike = dagger.get_node("NodeInterpolater/Strike")
	var global_rotation = strike.global_rotation
	var rot_angle = angle.angle()
	return strike.rotation == angle.angle()

func _get_server_data_for_angled_left_attack() -> MeleeWeaponData:
	var server_data = MeleeWeaponData.new()
	server_data.attack_sequence = 1
	server_data.animation_frame = 5
	server_data.attack_direction = Vector2(-1, 0.1)
	server_data.is_executing = true
	return server_data

func _init_dagger_and_character():
#	var character = load(character_path).instantiate() as ClientPlayerCharacter
	var character = TestFunctions.init_player_character()
	await get_tree().physics_frame
	var dagger = character.get_primary_weapon()
	#var dagger = load(dagger_path).instantiate()
	#ObjectCreationRegistry.add_child(character)
	#ObjectCreationRegistry.add_child(dagger)
	#character.add_weapon(0, dagger)
	
	return [dagger, character]

func _sequence_map_matches_expected(weapon, expected : Dictionary) -> bool:
	var animation_tree = weapon.get_node("RollbackAnimationTree")
	var actual = animation_tree.attack_sequence_map
	if actual.keys().size() != expected.keys().size():
		return false
	for key in expected.keys():
		if not actual.has(key):
			return false
		elif actual[key] != expected[key]:
			return false
	return true

func _do_dicts_match(dict_1 : Dictionary, dict_2 : Dictionary) -> bool:
	if dict_1.keys().size() != dict_2.keys().size():
		return false
	for key in dict_1.keys():
		if not dict_2.has(key):
			return false
		elif dict_1[key] != dict_2[key]:
			return false
	return true

func _play_animation_for_an_extra_frame(dagger, extra_frames : int) -> int:
	var hold_action = _create_hold_input_actions()
	var anim_player = dagger.get_node("AnimationPlayer") as AnimationPlayer
	var anticipation_length = anim_player.get_animation("Anticipation").length
	var frame_length = int(round(anticipation_length / CommandFrame.frame_length_sec))
	for i in range(frame_length + extra_frames):
		dagger.execute(i, hold_action)
	if extra_frames >= 0:
		return frame_length
	else:
		return frame_length + extra_frames

func _free_objects(objects : Array) -> void:
	for object in objects:
		if is_instance_valid(object):
			object.queue_free()

func _create_hold_input_actions() -> InputActions:
	var input_actions = InputActions.new()
	var attack_action = ActionFromClient.new()
	attack_action.action_data.attack_primary = true
	input_actions.receive_action(attack_action)
	input_actions.receive_action(attack_action)
	return input_actions

func _create_attack_released_actions() -> InputActions:
	var input_actions = InputActions.new()
	var attack_action = ActionFromClient.new()
	attack_action.action_data.attack_primary = true
	input_actions.previous_actions.duplicate(attack_action)
	return input_actions

func _create_release_and_aimed_action(direction : Vector2) -> InputActions:
	var input_actions = InputActions.new()
	var attack_action = ActionFromClient.new()
	var directed_action = ActionFromClient.new()
	directed_action.action_data.looking_vector = direction
	attack_action.action_data.attack_primary = true
	input_actions.previous_actions.duplicate(attack_action)
	input_actions.current_actions.duplicate(directed_action)
	return input_actions

func _create_attack_secondary_pressed_action() -> InputActions:
	var input_actions = InputActions.new()
	var attack_action = ActionFromClient.new()
	attack_action.action_data.attack_secondary = true
	input_actions.receive_action(attack_action)
	return input_actions

func _add_dagger_and_shield_to_character(character) -> void:
	var dagger = TestFunctions.instance_scene(dagger_path)
	var shield = TestFunctions.instance_scene(shield_path)
	character.add_weapon(0, dagger)
	character.add_weapon(0, shield)

func _play_weapon_animation_to_end(frame : int, character, weapon, with_input_held = InputActions.new(), stop_on_attack_sequence = -1):
	var failsafe = 0
	var starting_attack_sequence = weapon.weapon_data.attack_sequence
	while weapon.weapon_data.attack_sequence == starting_attack_sequence:
		frame = TestFunctions.register_input_and_execute_frame(frame, character, with_input_held)
		failsafe += 1
		if failsafe > 300:
			assert(false)
			break
		if weapon.weapon_data.attack_sequence == stop_on_attack_sequence:
			break
	return frame

func _play_animation_to_end_and_set_input_queue_held_frames_to_one(frame : int, character, weapon, with_input_held = InputActions.new()):
	var failsafe = 0
	while weapon.weapon_data.is_executing:
		frame = TestFunctions.register_input_and_execute_frame(frame, character, with_input_held)
		failsafe += 1
		var input_queue = character.get_component("InputQueue")
		input_queue.data_container.held_frames = 1
		if failsafe > 300:
			assert_true(false)
			break
	return frame
