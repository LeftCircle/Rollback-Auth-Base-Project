extends GutTestRogue



#func test_predicted_component_is_registered_to_system() -> void:
#	var frame = TestFunctions.random_frame()
#	var knockback_component = C_Knockback.new()
#	var test_character = TestFunctions.init_player_character()
#	await get_tree().process_frame
#	test_character.add_component(frame, knockback_component)
#	var predicted_frame_components = PredictedCreationSystem.get_predicted_components_for_frame(frame)
#	assert_true(predicted_frame_components.has(knockback_component))
#
#	test_character.queue_free()
#
#func test_components_from_server_dont_enter_prediction_system() -> void:
#	assert_true(false)
#
#func test_components_from_server_find_predicted_components() -> void:
#	assert_true(false)
