extends GutTestRogue


func test_components_are_not_deleted_until_server_says_so() -> void:
	# Create a knockback component and give it a random instance id
	# Throw it on a character, then remove it from the character
	# assert that the component is in the deferred delete system
	# have the server send a player sync packet for the same deletion frame
	# assert that the component is still there
	# then have the server send a component delete packet
	# assert that the component is gone
	var character : ClientPlayerCharacter = await init_player_character()
	var frame : int = random_frame()
	var random_id = randi_range(0, 10000)
	var knockback : C_Knockback = await instance_scene_by_id("KBK")
	knockback.netcode.is_from_server = true
	knockback.netcode.class_instance_id = random_id
	ObjectsInScene.track_object(knockback)
	character.add_component(frame, knockback)
	character.remove_component(knockback)
	assert_true(DeferredDeleteComponent.has_deferred_delete(knockback))

	var class_id_int = ObjectCreationRegistry.class_id_to_int_id[knockback.netcode.class_id]
	var instance_id = knockback.netcode.class_instance_id
	assert_true(ObjectsInScene.has(class_id_int, instance_id))

	# Now have the ComponentFreeSystem delete the component
	ComponentFreeSystem.free_component(class_id_int, instance_id)
	assert_false(ObjectsInScene.has(class_id_int, instance_id))
	assert_false(DeferredDeleteComponent.has_deferred_delete(knockback))
	assert_true(knockback.is_queued_for_deletion())

