extends GutTestRogue

const test_character_instance_id = 10
const test_move_instance_id = 99


func test_updated_client_components_are_added_to_tracker():
	var character = TestFunctions.init_player_character()
	await get_tree().process_frame
	var move_component = character.get_component("Move")
	move_component.netcode.is_from_server = true
	var move_inputs = TestFunctions.create_random_move_input()
	var execution_frame = TestFunctions.random_frame()
	FrameInitSystem.execute(execution_frame)
	var next_frame = TestFunctions.register_input_and_execute_frame(execution_frame, character, move_inputs)

	assert_true(ComponentUpdateTracker.is_component_updated(execution_frame, move_component))

	character.queue_free()
	await get_tree().process_frame

