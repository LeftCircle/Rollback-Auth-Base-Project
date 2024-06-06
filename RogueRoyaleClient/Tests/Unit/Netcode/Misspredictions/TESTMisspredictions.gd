extends GutTestRogue

const id_test = 053723
const id_expected = 053724

func test_command_frame_comparison():
	var frame_a = 50
	var frame_b = 50
	assert_false(CommandFrame.command_frame_greater_than_previous(frame_a, frame_b))

func test_better_move_misspredict():
	var frame = TestFunctions.random_frame()
	var starting_frame = frame
	var offset = Vector2(10, 0)
	var character = _init_misspredict_character(offset)
	await get_tree().process_frame
	assert_true(MoveStateSystem.is_entity_queued_or_registered(character))
	
	var final_frame = _move_the_characters_right_for_10_frames(frame, character)
	
	# Confirm movement occured
	var move_component = character.get_component("Move")
	var test_start : MoveData = move_component.history.retrieve_data(starting_frame)
	var test_end : MoveData = move_component.history.retrieve_data(final_frame)
	var test_end_position = test_end.global_position
	
	assert_eq(test_start.global_position.y, test_end.global_position.y, "only horizontal movement")
	assert_ne(test_end.global_position, Vector2.ZERO, "Movement should occur")
	
	_trigger_rollback_based_on_offset(starting_frame, final_frame, character, offset)

	# Verify that everything matches
	var end_after_rollback : MoveData = move_component.history.retrieve_data(final_frame)
	assert_eq(end_after_rollback, test_end, "MoveData container should not change")
	var position_diff = test_end_position - end_after_rollback.global_position
	assert_almost_eq(position_diff, offset, Vector2.ONE * 0.001, "Offset should match the position difference after rollback")
	
	character.queue_free()
	await get_tree().process_frame

func test_cannot_roll_back_to_older_frame() -> void:
	var frame = TestFunctions.random_frame()
	MissPredictFrameTracker.receive_server_player_state_frame(frame)
	var previous_frame = CommandFrame.get_previous_frame(frame)
	MissPredictFrameTracker.add_reset_frame(previous_frame)
	assert_eq(MissPredictFrameTracker.frame_to_reset_to, MissPredictFrameTracker.NO_FRAME)

func _init_misspredict_character(offset : Vector2):
	var character = TestFunctions.init_player_character(id_test)
	var rand_start_position = Vector2(randi_range(100, 1000), randi_range(100, 1000))
	character.position = rand_start_position + offset
	if not MoveStateSystem.is_entity_queued(character):
		MoveStateSystem.queue_entity(CommandFrame.frame, character)
	return character

func _move_the_characters_right_for_10_frames(frame, character) -> int:
	var move_inputs = _create_move_right_inputs()
	for i in range(10):
		frame = TestFunctions.register_input_and_execute_frame(frame, character, move_inputs)
	var final_frame = CommandFrame.get_previous_frame(frame)
	assert_true(MoveStateSystem.is_entity_registered(character))
	return final_frame

func _trigger_rollback_based_on_offset(starting_frame, final_frame, character, offset) -> void:
	var move_component = character.get_component("Move")
	var test_start : MoveData = move_component.history.retrieve_data(starting_frame)
	var server_data = MoveData.new()
	server_data.set_data_with_obj(test_start)
	server_data.global_position -= offset
	MissPredictFrameTracker.frame_init(0)
	move_component.receive_test_history_for_frame(starting_frame, server_data, true)
	
	RollbackSystem.execute(CommandFrame.get_next_frame(final_frame))

func _create_move_right_inputs() -> InputActions:
	var input_actions = InputActions.new()
	var move_right_actions = ActionFromClient.new()
	move_right_actions.action_data.input_vector = Vector2.RIGHT
	input_actions.receive_action(move_right_actions)
	input_actions.receive_action(move_right_actions)
	return input_actions

