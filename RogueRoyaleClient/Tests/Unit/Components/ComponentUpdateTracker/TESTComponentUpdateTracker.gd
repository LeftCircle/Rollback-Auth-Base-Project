extends GutTestRogue


func test_client_created_components_are_specially_tracked() -> void:
	var frame = random_frame()
	var knockback_component = await instance_scene_by_id("KBK")
	knockback_component.netcode.is_from_server = false
	var player : ClientPlayerCharacter = await init_player_character(randi_range(0, 1000000))
	player.add_component(frame, knockback_component)
	assert_false(ComponentUpdateTracker.has_client_update(frame, knockback_component))
	assert_true(PredictedCreationSystem.has_component(frame, knockback_component))

func test_client_created_components_are_not_tracked_by_component_update_tracker_on_update() -> void:
	var frame = random_frame()
	var next_frame = CommandFrame.get_next_frame(frame)
	var knockback_component = await instance_scene_by_id("KBK")
	knockback_component.netcode.is_from_server = false
	knockback_component.data_container.knockback_speed = 1000
	var player : ClientPlayerCharacter = await init_player_character(randi_range(0, 1000000))
	player.add_component(frame, knockback_component)
	KnockBackSystem.execute(next_frame)
	assert_true(KnockBackSystem.has_entity(player))
	assert_false(ComponentUpdateTracker.has_client_update(next_frame, knockback_component))

func test_server_created_components_are_tracked_on_update() -> void:
	var frame = random_frame()
	var next_frame = CommandFrame.get_next_frame(frame)
	var knockback_component : C_Knockback = await instance_scene_by_id("KBK")
	knockback_component.data_container.knockback_speed = 1000
	knockback_component.netcode.is_from_server = true
	var player : ClientPlayerCharacter = await init_player_character(randi_range(0, 1000000))
	player.add_component(frame, knockback_component)
	KnockBackSystem.execute(next_frame)
	assert_true(KnockBackSystem.has_entity(player))
	assert_true(ComponentUpdateTracker.has_client_update(next_frame, knockback_component))

func test_client_created_components_are_erased_if_server_frame_equal_or_greater_arrives() -> void:
	var frame = random_frame()
	var next_frame = CommandFrame.get_next_frame(frame)
	var knockback_component : C_Knockback = await instance_scene_by_id("KBK")
	knockback_component.netcode.is_from_server = false
	var player : ClientPlayerCharacter = await init_player_character(randi_range(0, 1000000))
	player.add_component(frame, knockback_component)

	# Assert that the component is tracked
	assert_true(PredictedCreationSystem.has_component(frame, knockback_component))
	# NOTE -> The predicted component system has to get the server frame somehow still
	assert_true(PlayerStateSync.server_player_frame_processed.is_connected(PredictedCreationSystem._on_server_update))
	PredictedCreationSystem._on_server_update(frame)
	assert_false(PredictedCreationSystem.has_component(frame, knockback_component))
	assert_false(player.has_component(knockback_component))
	assert_true(ComponentFreeSystem.has_immediate_delete(knockback_component))
	assert_false(ComponentFreeSystem.has_deferred_delete(knockback_component))

func test_created_components_are_not_retracked_by_system_after_rollback() -> void:
	assert_true(false, "Not yet implemented")
	# Create a client predicted component on frame n and add it to a character
	# Advance the frame to n + 3
	# add the component to the deferred delete system
	# Roll back to frame n + 1
	# assert that the PredictedCreationSystem does not have the component for frame n + 1

func test_tracked_client_components_are_cleared_at_start_of_frame() -> void:
	# Set the frame to n
	# place tracked components in frame n + 1
	# advance to frame n + 1
	# Assert that there are no tracked components in frame n + 1
	var frame = TestFunctions.random_frame()
	var next_frame = CommandFrame.get_next_frame(frame)
	var move_component : C_Move = await instance_scene_by_id("MVE")
	move_component.netcode.is_from_server = true
	ComponentUpdateTracker.track_client_update(next_frame, move_component)
	assert_true(ComponentUpdateTracker.has_client_update(next_frame, move_component))
	FrameInitSystem.execute(next_frame)
	assert_false(ComponentUpdateTracker.has_client_update(next_frame, move_component))

func test_collision_based_components_are_not_erased_in_regular_frame() -> void:
	assert_true(false, "Not yet implemented")
	# Set the frame to n
	# Set a hitbox to hit a hurtbox, causing a knockback to get tracked
	# advance to frame n + 1
	# Assert that the knockback component is still tracked

func test_tracked_client_components_are_cleared_at_start_of_rollback() -> void:
	# Set the frame to n
	# Save a component for frames n - 1, n - 2, and n - 3
	# Roll back to frame n - 3. Assert that the component is still tracked
	# Assert that the component is not tracked in frame n - 2 or n - 1
	var frame = TestFunctions.random_frame()
	var frame_minus_one = CommandFrame.get_previous_frame(frame)
	var frame_minus_two = CommandFrame.get_previous_frame(frame_minus_one)
	var frame_minus_three = CommandFrame.get_previous_frame(frame_minus_two)
	var move_component : C_Move = await instance_scene_by_id("MVE")
	move_component.netcode.is_from_server = true
	ComponentUpdateTracker.track_client_update(frame_minus_one, move_component)
	ComponentUpdateTracker.track_client_update(frame_minus_two, move_component)
	ComponentUpdateTracker.track_client_update(frame_minus_three, move_component)
	assert_true(ComponentUpdateTracker.has_client_update(frame_minus_one, move_component))
	assert_true(ComponentUpdateTracker.has_client_update(frame_minus_two, move_component))
	assert_true(ComponentUpdateTracker.has_client_update(frame_minus_three, move_component))

	RollbackSystem.emit_signal("rollback_started", frame_minus_three)

	assert_true(ComponentUpdateTracker.has_client_update(frame_minus_three, move_component))
	assert_false(ComponentUpdateTracker.has_client_update(frame_minus_two, move_component))
	assert_false(ComponentUpdateTracker.has_client_update(frame_minus_one, move_component))




func test_collision_based_components_are_not_erased_in_rollback() -> void:
	assert_true(false, "Not yet implemented")
