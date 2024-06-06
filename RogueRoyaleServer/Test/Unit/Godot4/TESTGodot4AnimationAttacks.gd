extends GutTestRogue

var dagger_path = "res://Scenes/Weapons/MeleeWeapons/Primary/Dagger/S_DaggerSimple.tscn"



func test_animation_node_state_machine_travel():
	var character = TestFunctions.init_player_character()
	var dagger = TestFunctions.instance_scene(dagger_path)
	ObjectCreationRegistry.add_child(dagger)
	character.add_weapon(0, dagger)
	var animation_tree = dagger.animation_tree
	await get_tree().process_frame
	# Start by traveling to reset
	var is_playing = animation_tree.state_machine_playback.is_playing()
	assert_false(is_playing)
	animation_tree._start_animation("Anticipation")
	assert_true(animation_tree.state_machine_playback.is_playing())
	assert_eq("Anticipation", dagger.get_current_animation_tree_node())

	# Now step from anticipation to attack
	animation_tree._start_animation("Attack_1")
	assert_eq(dagger.get_current_animation_tree_node(), "Attack_1")
	assert_true(animation_tree.state_machine_playback.is_playing())

	# Now jump from attack to finisher
	animation_tree._start_animation("Finisher")
	assert_eq(dagger.get_current_animation_tree_node(), "Finisher")
	assert_true(animation_tree.state_machine_playback.is_playing())
	character.queue_free()

func test_animation_frame_on_attack_start():
	var character = await init_character_with_dagger()
	await get_tree().process_frame
	var dagger = character.get_primary_weapon()

	# Start the anticipation for the weapon
	var attack_pressed = TestFunctions.create_attack_pressed_action(true)
	dagger.execute(0, attack_pressed)
	assert_eq(dagger.weapon_data.animation_frame, 1)
	character.queue_free

func test_advance_to_attack_1():
	var character = TestFunctions.init_player_character()
	var dagger = TestFunctions.instance_scene(dagger_path)
	character.add_weapon(0, dagger)
	await get_tree().physics_frame

	var attack_direction = TestFunctions.get_random_direction()
	_advance_daggger_to_attack_1(dagger, attack_direction)

	assert_true(dagger.weapon_data.attack_sequence == 1)
	assert_true(_animation_matches(dagger, "Attack_1"))
	assert_eq(dagger.weapon_data.animation_frame, 1)
	assert_eq(dagger.rotation, attack_direction.angle())

	dagger.set_attack_direction(attack_direction)
	dagger.animation_tree.advance(0.0166667)
	dagger.animation_tree.advance(0.0166667)
	assert_eq(dagger.rotation, attack_direction.angle())

	character.queue_free()

func test_dagger_rotates():
	var character = TestFunctions.init_player_character()
	var new_dagger = TestFunctions.instance_scene(dagger_path)
	character.add_weapon(0, new_dagger)
	await get_tree().physics_frame
	var dagger = character.get_primary_weapon()
	var rand_direction = TestFunctions.get_random_direction()
	dagger.set_attack_direction(rand_direction)
	assert_eq(dagger.rotation, rand_direction.angle())
	character.queue_free()

func _advance_daggger_to_attack_1(dagger, attack_direction : Vector2 = Vector2.ZERO) -> void:
	var attack_pressed = TestFunctions.create_attack_pressed_action(true)
	attack_pressed.current_actions.set_looking_vector(attack_direction)
	dagger.execute(0, attack_pressed)
	var release_actions = _create_release_and_aimed_action(attack_direction)
	dagger.execute(0, release_actions)

func _animation_matches(dagger, animation : String) -> bool:
	# I have a hunch that the blend position is not being set before the animation
	# is playing, which causes the animation to be played in the wrong direction
	var dagger_anim = dagger.get_current_animation_tree_node()
	return animation == dagger_anim

func _create_release_and_aimed_action(direction : Vector2) -> InputActions:
	var input_actions = InputActions.new()
	var attack_action = ActionFromClient.new()
	var directed_action = ActionFromClient.new()
	directed_action.action_data.looking_vector = direction
	attack_action.action_data.attack_primary = true
	input_actions.previous_actions.duplicate(attack_action)
	input_actions.current_actions.duplicate(directed_action)
	return input_actions
