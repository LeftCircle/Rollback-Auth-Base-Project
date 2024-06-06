extends GutTestRogue


func test_correctly_created_components_enter_deferred_delete() -> void:
	var character = TestFunctions.init_player_character()
	await get_tree().process_frame
	var knockback = TestFunctions.instance_scene_by_id("KBK")
	knockback.netcode.is_from_server = true
	await get_tree().process_frame
	ObjectsInScene.track_object(knockback)
	assert_true(ObjectsInScene.has_object(knockback))
	
	character.add_component(0, knockback)
	assert_true(ObjectsInScene.has_object(knockback))
	assert_true(KnockBackSystem.has_entity(character))
	
	character.remove_component(knockback)
	assert_false(KnockBackSystem.has_entity(character))
	assert_true(ObjectsInScene.has_object(knockback))
	assert_true(DeferredDeleteComponent.has(knockback))
	
	character.queue_free()
	await get_tree().process_frame

func test_incorrectly_created_components_deleted_immediately():
	var character = TestFunctions.init_player_character()
	await get_tree().process_frame
	var knockback = TestFunctions.instance_scene_by_id("KBK")
	await get_tree().process_frame
	character.add_component(0, knockback)
	character.remove_and_immediately_delete_component(knockback)
	ComponentFreeSystem.execute()
	assert_true(knockback.is_queued_for_deletion())
	assert_false(KnockBackSystem.has_entity(character))
	
	character.queue_free()
	await get_tree().process_frame

#func test_deferred_delete_components_removed_after_server_frame_received() -> void:
	#var frame = TestFunctions.random_frame()
	#var character = TestFunctions.init_player_character()
	#await get_tree().process_frame
	#var knockback = TestFunctions.instance_scene_by_id("KBK")
	#character.add_component(frame, knockback)
	#await get_tree().process_frame
#
	#character.remove_component(knockback)
	#assert_true(DeferredDeleteComponent.deferred_delete_components.has(CommandFrame.execution_frame))
	#
	#DeferredDeleteComponent.receive_server_player_state_frame(CommandFrame.execution_frame)
	#ComponentFreeSystem.execute()
	#assert_true(knockback.is_queued_for_deletion())
#
	#character.queue_free()
	#await get_tree().process_frame

func test_correctly_created_components_deleted_if_rollback_before_creation() -> void:
	# Deferred delete components should receive a rollback frame
	# if any component was created before this rollback frame, delete the component?
	
	# Create a knockback component, attach it to a character, defer the delete, then reset to before the creation
	await get_tree().physics_frame
	var test_frame = TestFunctions.random_frame()
	var character = TestFunctions.init_player_character()
	await get_tree().process_frame
	var knockback = TestFunctions.instance_scene_by_id("KBK")
	character.add_component(test_frame, knockback)
	CommandFrame.execute()
	assert_true(KnockBackSystem.has_entity(character))
	
	character.remove_component(knockback)
	CommandFrame.execute()
	MissPredictFrameTracker.frame_init(0)
	MissPredictFrameTracker.add_reset_frame(CommandFrame.get_previous_frame(test_frame))
	RollbackSystem.execute(CommandFrame.frame)
	
	assert_false(is_instance_valid(knockback))
	assert_false(character.has_component_group("Knockback"))
	assert_false(KnockBackSystem.has_entity(character))
	
	character.queue_free()
	#await get_tree().process_frame

func test_rollback_adds_back_deferred_deltete_components():
	var test_frame = TestFunctions.random_frame()
	var character = TestFunctions.init_player_character()
	await get_tree().process_frame
	var knockback = TestFunctions.instance_scene_by_id("KBK")
	character.add_component(test_frame, knockback)
	assert_eq(knockback.component_data.creation_frame, test_frame)
	CommandFrame.execute()

	character.remove_component(knockback)
	assert_eq(knockback.component_data.creation_frame, test_frame)
	
	CommandFrame.execute()
	MissPredictFrameTracker.frame_init(0)
	MissPredictFrameTracker.add_reset_frame(CommandFrame.get_next_frame(test_frame))
	RollbackSystem.execute(CommandFrame.frame)
	
	assert_true(is_instance_valid(knockback))
	assert_true(character.has_component_group("Knockback"))
	assert_false(DeferredDeleteComponent.has(knockback))
	assert_false(test_frame in DeferredDeleteComponent.deferred_delete_components.keys())
	assert_true(KnockBackSystem.has_entity(character))
	assert_eq(knockback.component_data.creation_frame, test_frame)
	
	character.queue_free()
	await get_tree().process_frame

func test_immediate_deletion_removes_component_from_deferred_delete() -> void:
	# Create a component, attach it to a character, then set it for deferred deletion
	# Then set the component for immediate deletion on a future frame
	# Assert that the component is no longer present for immediate deletion. 
	var random_frame : int = random_frame()
	var character = await init_player_character()
	var knockback = await instance_scene_by_id("KBK")
	character.add_component(random_frame, knockback)
	var next_frame = CommandFrame.get_next_frame(random_frame)
	var next_next_frame = CommandFrame.get_next_frame(next_frame)
	character.remove_component(knockback)
	assert_true(ComponentFreeSystem.has_deferred_delete(knockback))

	DeferredDeleteComponent.queue_free_imediately(knockback)
	assert_false(ComponentFreeSystem.has_deferred_delete(knockback))
	assert_true(ComponentFreeSystem.has_immediate_delete(knockback))

func test_rollback_deletion_clears_predicted_component() -> void:
	# Predict the creation of a component, then roll back to the frame before its creation
	# Confirm that the component is no longer in the PredictedCreationSystem
	var random_frame : int = random_frame()
	var character = await init_player_character()
	var knockback = await instance_scene_by_id("KBK")
	character.add_component(random_frame, knockback)
	assert_true(PredictedCreationSystem.has_component(random_frame, knockback))
	MissPredictFrameTracker.add_reset_frame(CommandFrame.get_previous_frame(random_frame))
	RollbackSystem.execute(random_frame)
	assert_false(character.has_component(knockback))
	assert_false(PredictedCreationSystem.has_component(random_frame, knockback))


func test_deleting_components_stops_them_from_being_tracked() -> void:
	# Spawn a character and have the ObjectCreationRegistry track all the components. 
	# Then add them all to be immediately deleted 
	# Confirm that they are no longer tracked in the ObjectCreationRegistry and that there
	# are no null objects in the ObjectCreationRegistry ObjectsInScene
	assert_true(false, "Not yet implemented")

