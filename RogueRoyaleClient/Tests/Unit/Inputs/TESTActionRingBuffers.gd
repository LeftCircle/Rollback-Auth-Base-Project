extends GutTestRogue


func test_local_player_gets_local_action_ring_buffer() -> void:
	var test_id = randi_range(0, 10000)
	InputProcessing.register_local_player(test_id)
	assert_false(InputProcessing.is_ring_buffer_remote(test_id))

func test_remote_player_gets_remote_ActionRingBuffer() -> void:
	var test_id = randi_range(0, 1000000)
	InputProcessing.register_remote_player(test_id)
	assert_true(InputProcessing.is_ring_buffer_remote(test_id))

func test_predicted_actions_are_marked_as_not_verified():
	var test_id = randi_range(0, 1000000)
	var frame = TestFunctions.random_frame()
	InputProcessing.register_remote_player(test_id)
	var action = InputProcessing.get_action_or_duplicate_for_frame(frame, test_id)
	assert_false(action.is_from_client)

func test_received_actions_are_marked_as_verified():
	var test_id = randi_range(0, 1000000)
	var frame = TestFunctions.random_frame()
	InputProcessing.register_remote_player(test_id)
	InputProcessing.receive_action_for_player(frame, test_id, ActionFromClient.new())
	var action = InputProcessing.get_action_or_duplicate_for_frame(frame, test_id)
	assert_true(action.is_from_client)
