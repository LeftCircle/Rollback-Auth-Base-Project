extends GutTestRogue


func test_queued_input_actually_exists() -> void:
	var rand_id = randi_range(0, 1000000)
	var player = await testFunctions().instance_character_await(rand_id)
	var move_right_input : InputActions = TestFunctions.create_directional_input(Vector2.RIGHT)
	assert_eq(move_right_input.current_actions.action_data.input_vector, Vector2.RIGHT)
	var random_frame = TestFunctions.random_frame()
	var next_frame = TestFunctions.register_input_and_execute_frame(random_frame, player, move_right_input)
	assert(next_frame == random_frame + 1)
	assert_eq(move_right_input.current_actions.action_data.input_vector, Vector2.RIGHT)
	var input_for_frame : ActionFromClient = InputProcessing.get_action_or_duplicate_for_frame(random_frame, rand_id)
	assert_eq(input_for_frame.action_data.input_vector, Vector2.RIGHT)
