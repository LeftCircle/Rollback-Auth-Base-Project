extends GutTestRogue


func test_objects_register_to_deletion_system_when_queued_free() -> void:
	# When a netcode object is queued free, it should enter a queued 
	# free system. This system should track the class_id and instance_id
	# of the component. It should keep track of the number of instances of 
	# a given class that are to be queued free on that frame. 
	var character = await init_player_character()
	var knockback : S_Knockback = await instance_scene_by_id("KBK")
	var frame = random_frame()
	character.add_component(frame, knockback)
	character.remove_component(frame, knockback, true)
	assert_true(NetcodeFreeComponent.has_component(knockback.netcode.class_id, knockback.netcode.class_instance_id))
	assert_eq(1, NetcodeFreeComponent.get_queue_free_count(knockback.netcode.class_id))

