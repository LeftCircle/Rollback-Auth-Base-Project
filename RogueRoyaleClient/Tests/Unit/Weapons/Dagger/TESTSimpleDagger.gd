extends GutTestRogue



#func test_dagger_pivot_rotates_with_attack_direction():
#	var dagger_and_character = _init_dagger_and_character()
#	var dagger = dagger_and_character[0]
#	var attack_direction = Vector2(1, 1)
#	_advance_daggger_to_attack_1(dagger, attack_direction)
#	# Dagger is currently rotating the pivot an extra 90 degrees
#	var expected_angle = attack_direction.rotated(PI / 2.0).angle()
#	assert_almost_eq(dagger.get_pivot().global_rotation, expected_angle, 0.001)
#	TestFunctions.queue_scenes_free(dagger_and_character)
#
#func _init_dagger_and_character() -> Array:
#	var character = load(character_path).instantiate()
#	var dagger = load(simple_dagger_path).instantiate()
#	ObjectCreationRegistry.add_child(character)
#	ObjectCreationRegistry.add_child(dagger)
#	character.add_weapon(0, dagger)
#	return [dagger, character]
#
#func _advance_daggger_to_attack_1(dagger, attack_direction : Vector2 = Vector2.ZERO) -> void:
#	var empty_actions = InputActions.new()
#	dagger.execute(0, empty_actions)
#	var release_actions = TestFunctions.create_release_and_aimed_action(attack_direction)
#	dagger.execute(0, release_actions)
