extends GutTestRogue


var test_area_2d_path = "res://Tests/Unit/Physics/CollisionTest.tscn"

func test_player_moves_properly_with_rollback():
	# Have a character move twice normally by advancing frames, 
	# then have a duplicate character move twice via rollback with the same initial conditions
	# They should match.
	var expected_char = TestFunctions.init_player_character(1)
	var test_char = TestFunctions.init_player_character(2)
	test_char.global_position = Vector2(0, 500)
	expected_char.global_position = Vector2.ZERO
	await get_tree().physics_frame
	await get_tree().physics_frame
	var frame = TestFunctions.random_frame()
	
	var move_right = TestFunctions.create_directional_input(Vector2(1,0))
	TestFunctions.register_input_and_execute_frame(frame, expected_char, move_right)
	TestFunctions.register_input_and_execute_frame(frame, expected_char, move_right)
	
	var expected_position = expected_char.global_position
	var starting_position = test_char.global_position
	#assert_eq(expected_position.x, 37)
	assert_eq(starting_position.x, 0)

	# Now advance the physics engine by hand
	var test_move = test_char.get_component("Move") as C_Move
	PhysicsServer2D.advance_physics_post_simulation()
	PhysicsServer2D.sync_physics_before_simulation()
	test_move.execute(frame, test_char, move_right.current_actions.get_input_vector())
	PhysicsServer2D.advance_physics_post_simulation()
	
	PhysicsServer2D.sync_physics_before_simulation()
	test_move.execute(frame, test_char, move_right.current_actions.get_input_vector())
	PhysicsServer2D.advance_physics_post_simulation()


	assert_almost_eq(test_char.global_position.x, expected_position.x, 0.01)
	assert_almost_eq(expected_char.global_position.x, expected_position.x, 0.01)
	assert_ne(expected_char.global_position.x, 0)
	
	TestFunctions.queue_scenes_free([expected_char, test_char])
	await get_tree().process_frame

#func test_rigid_bodies_advance_properly_with_rollback():
#	assert_true(false)

func test_collisions_detected_with_rollback():
	var area_a = _instance_area2D(Vector2(0, 0))
	var area_b = _instance_area2D(Vector2(100, 0))
	await get_tree().physics_frame
	assert_eq(area_a.get_overlapping_areas().size(), 0)
	move_areas_to_overlap(area_a, area_b, Vector2(50,0))
	
	PhysicsServer2D.advance_physics_post_simulation()
	_assert_collisions_dont_occur_after_advance(area_a)
	
	PhysicsServer2D.sync_physics_before_simulation()
	_assert_collisions_occur_after_sync(area_a, area_b)
	TestFunctions.queue_scenes_free([area_a, area_b])
	await get_tree().process_frame

func test_knockback_is_not_double_created_if_reset_to_creation_frame():
	assert_true(false, "Not yet implemented")
	# Set up a character hitting another, then rollback to the frame that the creation occurs
	# we have to see if a new component will be created or not. 

func move_areas_to_overlap(area_a : Area2D, area_b : Area2D, overlap_position : Vector2):
	area_a.global_position = overlap_position
	area_b.global_position = overlap_position

func _instance_area2D(pos : Vector2):
	var area = load(test_area_2d_path).instantiate()
	area.position = pos
	ObjectCreationRegistry.add_child(area)
	return area

func _assert_collisions_dont_occur_after_advance(area_a : Area2D) -> void:
	assert_eq(area_a.get_overlapping_areas().size(), 0)
	assert_false(area_a.collision_occured)

func _assert_collisions_occur_after_sync(area_a : Area2D, area_b : Area2D) -> void:
	assert_eq(area_a.get_overlapping_areas().size(), 1)
	assert_true(area_a.collision_occured)
	assert_eq(area_a.global_position, area_b.global_position)
