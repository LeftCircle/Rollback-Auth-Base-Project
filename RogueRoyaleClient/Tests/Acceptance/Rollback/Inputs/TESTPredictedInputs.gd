extends GutTestRogue
# User Story 342


#func test_remote_client_predicts_input_based_on_last_received_input() -> void:
#	var test_id = randi_range(0, 1000000)
#	var frame = TestFunctions.random_frame()
#	var remote_client = await testFunctions().instance_remote_character_await(test_id)
#	var attack_input = TestFunctions.create_attack_pressed_action(true)
#
#	TestFunctions.register_input_and_execute_frame(frame, remote_client, attack_input)
#	_assert_character_last_received_action_matches(remote_client, attack_input.current_actions)
#	await testFunctions().free_scenes_await([remote_client])
#
#func _assert_character_last_received_action_matches(character : PlayerTemplate, action : ActionFromClient) -> void:
#	var matches = false
#	assert_true(matches, "Last received action must match")

func test_client_predicts_actions_if_none_received() -> void:
	var test_id = randi_range(0, 1000000)
	var frame = TestFunctions.random_frame()
	InputProcessing._on_player_connected(test_id)
	var action = InputProcessing.get_action_or_duplicate_for_frame(frame, test_id)
	assert_false(action.is_from_client)

func test_future_actions_are_stored() -> void:
	var frame = TestFunctions.random_frame()
	var test_id = randi_range(0, 1000000)
	var next_two_frames = _get_next_two_frames(frame)
	_recevie_actions_for_frames(next_two_frames, test_id)
	_assert_actions_for_frames_are_from_client(next_two_frames, test_id)

func test_misspredict_occurs_on_incorrect_prediction() -> void:
	var test_id = randi_range(0, 1000000)
	var frame = TestFunctions.random_frame()
	var frame_10_back = CommandFrame.get_previous_frame(frame, 10)
	var frame_11_back = CommandFrame.get_previous_frame(frame, 11)
	InputProcessing._on_player_connected(test_id)
	var attack_actions = _create_attack_pressed_actions()
	InputProcessing.receive_action_for_player(frame_10_back, test_id, attack_actions)
	assert_eq(MissPredictFrameTracker.frame_to_reset_to, frame_11_back, "Misspredict frame should be 11 frames back")

func _create_attack_pressed_actions() -> ActionFromClient:
	var action : ActionFromClient = ActionFromClient.new()
	action.action_data.attack_primary = true
	return action

func _get_next_two_frames(starting_frame : int) -> Array:
	var next_frame = CommandFrame.get_next_frame(starting_frame)
	var next_next_frame = CommandFrame.get_next_frame(next_frame)
	return [next_frame, next_next_frame]

func _recevie_actions_for_frames(frames : Array, player_id : int) -> void:
	for frame in frames:
		var action = ActionFromClient.new()
		InputProcessing.receive_action_for_player(frame, player_id, action)

func _assert_actions_for_frames_are_from_client(frames : Array, player_id : int) -> void:
	for frame in frames:
		assert_true(InputProcessing.get_action_or_duplicate_for_frame(frame, player_id).is_from_client, "Action must be from client")
