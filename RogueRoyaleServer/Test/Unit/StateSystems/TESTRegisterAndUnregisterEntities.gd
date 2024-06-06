extends GutTest


# Test that multiple entities can be registered and unregistered in a given frame

func test_multiple_entity_registered():
	# Test that if multiple entities are queued, they are all moved to registered on the next frame
	var frame = TestFunctions.random_frame()
	var char_0 = TestFunctions.init_player_character()
	var char_1 = TestFunctions.init_player_character()
	var char_2 = TestFunctions.init_player_character()

	# All of these characters should be queued
	#await get_tree().process_frame
	assert_true(MoveStateSystem.is_entity_queued(char_0))
	assert_true(MoveStateSystem.is_entity_queued(char_1))
	assert_true(MoveStateSystem.is_entity_queued(char_2))

	# Assert that the queued state is saved to the component


	# Advance the state system
	SystemController.execute(frame)
	# All of these characters should be registered
	assert_true(MoveStateSystem.is_entity_registered(char_0))
	assert_true(MoveStateSystem.is_entity_registered(char_1))
	assert_true(MoveStateSystem.is_entity_registered(char_2))

	TestFunctions.queue_scenes_free([char_0, char_1, char_2])

func test_state_system_component_tracks_queued_and_unqueued():
	var frame = TestFunctions.random_frame()
	var char = TestFunctions.init_player_character()
	var system_component : StateSystemState = char.get_component("StateSystem")
	assert_true(is_instance_valid(system_component))

	#assert_eq(system_component.data_container.queued_state, SystemController.STATES.MOVE)

	SystemController.execute(frame)
	assert_eq(system_component.data_container.queued_state, SystemController.STATES.NULL)

	# Test that moving to the attack state unregisters the character from move
	var attack_input = TestFunctions.create_attack_pressed_action(true)
	frame = TestFunctions.register_input_and_execute_frame(frame, char, attack_input)
	assert_eq(system_component.data_container.queued_state, SystemController.STATES.ATTACK_PRIMARY)
	assert_eq(system_component.data_container.queued_unregister, SystemController.STATES.MOVE)

	frame = TestFunctions.register_input_and_execute_frame(frame, char, InputActions.new())
	assert_eq(system_component.data_container.queued_state, SystemController.STATES.NULL)
	assert_eq(system_component.data_container.queued_unregister, SystemController.STATES.NULL)
	char.queue_free()


