extends GutTestRogue

var path_to_test_scene = "res://Tests/01_TestScenes/Animations/LocalRollbackStateMachineTest.tscn"

func test_rollback_animation_tree_has_history() -> void:
	var rollback_animation_tree = LocalRollbackAnimationTree.new()
	add_child(rollback_animation_tree)
	await get_tree().process_frame
	var history = rollback_animation_tree.history
	assert_true(history is RollbackAnimationTreeHistory)

func test_manually_starting_idle() -> void:
	var test_scene = await instance_scene(path_to_test_scene)
	var rollback_tree : LocalRollbackAnimationTree = test_scene.get_node("LocalRollbackAnimationTree")
	assert_false(rollback_tree.is_looping)
	var input_vector = Vector2.RIGHT
	rollback_tree.start_playing_node("Idle", input_vector)
	
	var idle_blend_position = rollback_tree.get_blend_position_for("Idle")
	var active_node = rollback_tree.get_active_node()
	var animation_frame = rollback_tree.get_animation_frame()

	assert_true(rollback_tree.is_looping)
	assert_true(rollback_tree.is_playing())
	assert_eq(idle_blend_position, Vector2.RIGHT)
	assert_eq(active_node, "Idle")
	assert_eq(animation_frame, 0)
	
	var command_frame = 0
	rollback_tree.execute(command_frame)
	
	animation_frame = rollback_tree.get_animation_frame()
	assert_eq(animation_frame, 1)
	assert_true(rollback_tree.is_playing())

func test_looping_idle_animation_manually() -> void:
	# The idle animation should be set not to be looping in the AnimationPlayer, but it sets the AnimationTree to be looping
	# Then the animation tree should restart the animation when it reaches the end
	# We will check this by advancing the animation tree to the end of the animation, then advancing once more. The current animation 
	# frame should be 0
	var test_scene = await instance_scene(path_to_test_scene)
	var rollback_tree : LocalRollbackAnimationTree = test_scene.get_node("LocalRollbackAnimationTree")
	var input_vector = Vector2.RIGHT
	rollback_tree.start_playing_node("Idle", input_vector)
	var n_frames = rollback_tree.get_current_animation_length()
	assert_eq(n_frames, 3)
	for i in range(n_frames):
		rollback_tree.execute(i)
		assert_eq(rollback_tree.get_animation_frame(), i + 1)
	assert_eq(rollback_tree.get_animation_frame(), 3, "Might actually be zero")
	rollback_tree.execute(n_frames)
	assert_eq(rollback_tree.get_animation_frame(), 0)

func test_resetting_on_rollback() -> void:
	# Start the idle animation, then advance it two steps. Then rollback one frame and assert
	# that the frame is one
	var test_scene = await instance_scene(path_to_test_scene)
	var rollback_tree : LocalRollbackAnimationTree = test_scene.get_node("LocalRollbackAnimationTree")
	var input_vector = Vector2.RIGHT
	rollback_tree.start_playing_node("Idle", input_vector)
	for i in range(3):
		rollback_tree.execute(i)
		rollback_tree.save_history(i)
	assert_eq(rollback_tree.get_animation_frame(), 3)
	rollback_tree._on_rollback(1)
	# Rolls back to frame 1 because we reset to the START of command frame 1, which results in the
	# animation frame of 1
	assert_eq(rollback_tree.get_animation_frame(), 1)
	assert_eq(rollback_tree.get_active_node(), "Idle")

func test_character_animation_is_in_local_animation_system() -> void:
	# Instance a player character and grab their RollbackAnimationPlayer from their animations variable
	# Confirm that the player character's animation player is in the local animation system
	pass

func test_move_system_queues_idle_animation_to_play() -> void:
	pass

func test_rollback_resets_animation() -> void:
	pass

func test_history_is_saved_only_when_all_component_history_is_saved() -> void:
	# Instead of calling history.add_data(frame, self) from within the animation system, 
	# let this occur in the StateHistorySystem
	pass

func test_waling_right_plays_walk_right_animation() -> void:
	pass
