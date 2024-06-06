extends GutTestRogue


func test_queue_valid_input():
	var input_queue = C_InputQueue.new()
	var data = InputQueueData.new()
	var attack_input = _build_test_attack_input()
	input_queue._execute_system(data, attack_input)
	assert_true(data.input == input_queue.string_to_int["attack_primary"])
	assert_true(data.is_released == false)
	assert_true(data.held_frames == 0)
	input_queue.free()

#func test_queue_invalid_input():
	#var input_queue = C_InputQueue.new()
	#var data = InputQueueData.new()
	#var invalid = _build_invalid_input()
	#input_queue._execute_system(data, invalid)
	#assert_true(data.input == input_queue.string_to_int["NONE"])
	#assert_true(data.is_released == false)
	#assert_true(data.held_frames == 0)
	#input_queue.free()

func test_hold_release_hold():
	var input_queue = C_InputQueue.new()
	var data = InputQueueData.new()
	var attack_input = _build_test_attack_input()
	var empty_input = InputActions.new()
	var frames_to_hold = 10
	# Modifying
	_hold_input_for_x_frames(input_queue, data, frames_to_hold, attack_input)
	input_queue._execute_system(data, empty_input)
	_hold_input_for_x_frames(input_queue, data, frames_to_hold, attack_input)
	# Testing
	assert_true(data.input == input_queue.string_to_int["attack_primary"])
	assert_true(data.is_released == true)
	assert_true(data.held_frames == frames_to_hold - 1)
	input_queue.free()

func test_reset_to_server_data():
	var input_queue = C_InputQueue.new()
	var server_data = _build_server_data(input_queue)
	input_queue.reset_to(server_data)
	assert_true(input_queue.data_container.matches(server_data))
	input_queue.free()

func test_data_container_same_as_netcode_data():
	var input_queue = C_InputQueue.new()
	ObjectCreationRegistry.add_child(input_queue)
	assert_true(input_queue.data_container == input_queue.netcode.state_data)
	input_queue.free()

func _build_server_data(input_queue) -> InputQueueData:
	var server_data = InputQueueData.new()
	server_data.input = input_queue.string_to_int["attack_secondary"]
	server_data.held_frames = 10
	server_data.is_released = false
	return server_data

func _build_test_attack_input() -> InputActions:
	var test_input = InputActions.new()
	var test_action = ActionFromClient.new()
	test_action.action_data.attack_primary = true
	test_input.receive_action(test_action)
	return test_input

#func _build_invalid_input() -> InputActions:
	#var test_input = InputActions.new()
	#var test_action = ActionFromClient.new()
	#test_action.action_data.dodge = true
	#test_input.receive_action(test_action)
	#return test_input

func _hold_input_for_x_frames(input_queue : InputQueueComponent, data : InputQueueData, frames : int, input : InputActions) -> void:
	for i in range(frames):
		input_queue._execute_system(data, input)

func test_dodge_input_is_tracked_even_if_other_inputs() -> void:
	var input_queue = C_InputQueue.new()
	var data = InputQueueData.new()
	var attack_input = _build_test_attack_input()
	var dodge_input = _build_test_dodge_input()
	input_queue._execute_system(data, attack_input)
	input_queue._execute_system(data, dodge_input)
	assert_true(data.input == input_queue.string_to_int["dodge"])
	assert_true(data.is_released == false)
	assert_eq(data.held_frames, 0)
	input_queue.free()

func _build_test_dodge_input() -> InputActions:
	var test_input = InputActions.new()
	var test_action = ActionFromClient.new()
	test_action.action_data.dodge = true
	test_input.receive_action(test_action)
	return test_input
