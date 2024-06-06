extends GutTestRogue


func test_server_component_container_is_created() -> void:
	assert_true(is_instance_valid(ServerComponentContainer))

func test_server_components_added_to_server_component_contianer() -> void:
	# Create the character on frame 1
	Server._on_packet_received(1, TestFunctions.character_server_data.duplicate())
	PlayerUpdateSystem.execute()
	await get_tree().process_frame
	var char_id = ObjectCreationRegistry.class_id_to_int_id["CHR"]
	var expected_char = ObjectsInScene.find_and_return_object(char_id, TestFunctions.server_character_instance_id)
	assert_true(is_instance_valid(expected_char))
	
	# Create the move component for the character on frame 8
	Server._on_packet_received(1, TestFunctions.move_server_data.duplicate())
	PlayerUpdateSystem.execute()
	#assert_false(expected_char.has_component_group("Move"))
	var move_id = ObjectCreationRegistry.class_id_to_int_id["MVE"]
	var expected_move = ObjectsInScene.find_and_return_object(move_id, TestFunctions.server_move_instance_id)
	assert_true(ServerComponentContainer.frame_has_component(TestFunctions.move_server_frame, expected_move))
	
	# Rollback from frame 1 to the move frame, then confirm that move is added to the entity
	CommandFrame.frame = 0
	CommandFrame.execute()
	RollbackSystem.execute(CommandFrame.get_next_frame(TestFunctions.move_server_frame))
	assert_true(expected_char.has_component_group("Move"))
	
	expected_char.queue_free()
	await get_tree().process_frame

func test_server_component_creation_frame_is_frame_added() -> void:
	# All we have to do for this is change the execution frame to rollback frame when adding components
	var frame = TestFunctions.random_frame()
	var frame_three_back = CommandFrame.get_previous_frame(frame, 3)
	var knockback = TestFunctions.instance_scene_by_id("KBK")
	knockback.netcode.owner_class_id = ObjectCreationRegistry.class_id_to_int_id["CHR"]
	await get_tree().process_frame
	ServerComponentContainer.add_component(frame_three_back, knockback)
	ServerComponentContainer.on_rollback_frame(frame)
	assert_eq(knockback.component_data.creation_frame, frame_three_back)
	knockback.queue_free()
	await get_tree().process_frame

func instance_character_with_class_instance_id(instance_id : int) -> ClientPlayerCharacter:
	var character = TestFunctions.init_player_character(instance_id)
	character.netcode.class_instance_id = instance_id
	await get_tree().process_frame
	return character

func create_server_component_for_player(component_id : String, character):
	var component = TestFunctions.instance_scene_by_id(component_id)
	await get_tree().process_frame
	# We need to assign an instance_id and an owner to the character and component
	component.netcode.class_instance_id = randi_range(0, 1000)
	component.netcode.owner_class_id = ObjectCreationRegistry.class_id_to_int_id[character.netcode.class_id]
	component.netcode.owner_instance_id = character.netcode.class_instance_id
