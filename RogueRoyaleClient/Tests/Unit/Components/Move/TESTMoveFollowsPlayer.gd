extends GutTestRogue


func test_move_follows_player() -> void:
	var rand_id = randi_range(0, 1000000)
	var player = TestFunctions.init_player_character(rand_id)
	await get_tree().process_frame

	var move = player.get_component("Move")
	var og_move_position = move.global_position
	var og_player_position = player.global_position
	assert_eq(og_move_position, og_player_position)

	var move_right_input = TestFunctions.create_directional_input(Vector2.RIGHT)
	var random_frame = TestFunctions.random_frame()
	random_frame = TestFunctions.register_input_and_execute_frame(random_frame, player, move_right_input)
	assert_eq(move.global_position, player.global_position)
	assert_ne(og_move_position, move.global_position)
	assert_ne(og_player_position, player.global_position)
	var test_position = Vector2(10, 10)
	player.global_position = test_position
	assert_eq(move.global_position, player.global_position)
	assert_eq(player.global_position, test_position)
	
	player.queue_free()

#func test_move_plays_animation() -> void:
#	var rand_id = randi_range(0, 1000000)
#	var player = await testFunctions().instance_character_await(rand_id)
#
#	var idle_input = TestFunctions.create_directional_input(Vector2.ZERO)
#	var move_right_input = TestFunctions.create_directional_input(Vector2.RIGHT)
#
#	var animation_player : RollbackAnimationPlayer = player.animations
#
#	var random_frame = TestFunctions.random_frame()
#	assert_true(false, "Not yet implemented")
#	player.queue_free()



