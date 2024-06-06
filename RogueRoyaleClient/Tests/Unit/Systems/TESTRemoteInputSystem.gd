extends GutTestRogue


# func test_input_packets_enter_a_buffer_when_received() -> void:
# 	pass

# func test_input_packets_are_read_on_RemoteInputSystem_update() -> void:
# 	pass

func test_server_received_inputs_are_marked() -> void:
	var remote_action_buffer = RemoteActionRingBuffer.new()
	var test_action = ActionFromClient.new()
	assert_false(test_action.is_from_client)
	var test_frame = 10
	remote_action_buffer.receive_action(test_frame, test_action)
	var action_in_buffer = remote_action_buffer.get_action_or_duplicate_for_frame(test_frame)
	assert_true(action_in_buffer.is_from_client)

func test_remote_client_uses_previous_frame_actions_if_no_input_received() -> void:
	# Set the current frame to 10 and have a server received frame for 9. Try and grab an input for frame 
	# 10, and confirm that the input matches frame 9, except is marked as predicted. 
	var remote_action_buffer = RemoteActionRingBuffer.new()
	var test_action = ActionFromClient.new()
	test_action.action_data.attack_primary = true
	var input_frame = 9
	var no_input_frame = 10
	remote_action_buffer.receive_action(input_frame, test_action)
	var action_in_buffer = remote_action_buffer.get_action_or_duplicate_for_frame(no_input_frame)
	assert_false(action_in_buffer.is_from_client)
	assert_true(action_in_buffer.action_data.attack_primary)


func test_rollback_does_not_occur_on_silent_missprediction() -> void:
	# predict an input, then receive the same input with a different looking vector. Ensure that a rollback frame is not
	# added to the rollback buffer.
	
	# Start by passing an action into frame 9 then predicting it on frame 10.
	var predicted_action = ActionFromClient.new()
	predicted_action.action_data.looking_vector = Vector2.RIGHT
	var remote_action_buffer = RemoteActionRingBuffer.new()
	remote_action_buffer.receive_action(9, predicted_action)
	var predicted_action_in_buffer = remote_action_buffer.get_action_or_duplicate_for_frame(10)

	var actual_action = ActionFromClient.new()
	actual_action.action_data.looking_vector = Vector2.LEFT
	
	MissPredictFrameTracker.before_gut_test()
	remote_action_buffer.receive_action(10, actual_action)

	# assert that frame 9 is not in the missprediction buffer
	assert_ne(MissPredictFrameTracker.frame_to_reset_to, 9)

func test_future_inputs_are_updated_on_silent_misspredict() -> void:
	CommandFrame.set_physics_process(false)
	CommandFrame.frame = 11
	var predicted_action = ActionFromClient.new()
	predicted_action.action_data.looking_vector = Vector2.RIGHT
	var actual_action = ActionFromClient.new()
	actual_action.action_data.looking_vector = Vector2.LEFT
	var remote_action_buffer = RemoteActionRingBuffer.new()
	var starting_frame = 9
	remote_action_buffer.receive_action(starting_frame - 1, predicted_action)
	remote_action_buffer.get_action_or_duplicate_for_frame(starting_frame)
	remote_action_buffer.get_action_or_duplicate_for_frame(starting_frame + 1)
	remote_action_buffer.get_action_or_duplicate_for_frame(starting_frame + 2)

	remote_action_buffer.receive_action(starting_frame, actual_action)
	var predicted_next_action = remote_action_buffer.get_action_or_duplicate_for_frame(starting_frame + 1)
	var predicted_next_next = remote_action_buffer.get_action_or_duplicate_for_frame(starting_frame + 2)
	assert_eq(predicted_next_action.action_data.looking_vector, Vector2.LEFT)
	assert_eq(predicted_next_next.action_data.looking_vector, Vector2.LEFT)
	assert_false(predicted_next_action.is_from_client)
	assert_false(predicted_next_next.is_from_client)
	CommandFrame.set_physics_process(true)

func test_rollback_occurs_on_loud_missprediction() -> void:
	CommandFrame.set_physics_process(false)
	CommandFrame.frame = 11
	var predicted_action = ActionFromClient.new()
	predicted_action.action_data.looking_vector = Vector2.RIGHT
	var actual_action = ActionFromClient.new()
	actual_action.action_data.attack_primary = true

	var remote_action_buffer = RemoteActionRingBuffer.new()
	var starting_frame = 9
	remote_action_buffer.receive_action(starting_frame - 1, predicted_action)
	remote_action_buffer.get_action_or_duplicate_for_frame(starting_frame)
	remote_action_buffer.get_action_or_duplicate_for_frame(starting_frame + 1)
	remote_action_buffer.get_action_or_duplicate_for_frame(starting_frame + 2)

	remote_action_buffer.receive_action(starting_frame, actual_action)
	assert_true(MissPredictFrameTracker.frame_to_reset_to == starting_frame - 1)

	var predicted_next_action = remote_action_buffer.get_action_or_duplicate_for_frame(starting_frame + 1)
	var predicted_next_next = remote_action_buffer.get_action_or_duplicate_for_frame(starting_frame + 2)
	assert_eq(predicted_next_action.action_data.attack_primary, true)
	assert_eq(predicted_next_next.action_data.attack_primary, true)
	CommandFrame.set_physics_process(true)

func inputs_before_server_verified_frame_do_not_cause_misspredictions() -> void:
	# A future optimization to look into
	pass

func test_inputs_are_updated_on_missprediction_until_other_received_frame_or_current_frame() -> void:
	# Set the current frame to 10, then have a server received frame on 8. Misspredict an input on frame
	# 5, and confirm that inputs 8, 9, and 10 are not changed.
	
	# Implemented but not tested
	pass
