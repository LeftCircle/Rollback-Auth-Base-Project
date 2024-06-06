extends GutTestRogue

const test_character_instance_id = 10
const test_move_instance_id = 99
# From TESTCharacterNetcodeBase on the server
#const character_data = [128, 9, 16, 64, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 45, 0, 1]
# Most recent one from failed server test is below
const character_data = [128, 9, 16, 64, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 45, 0, 1]
#const move_data = [219, 159, 18, 96, 12, 0, 48, 1, 20, 0, 26, 83, 111, 76, 93, 233, 179, 0, 0, 128, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 186, 0, 1]
const move_data = [219, 159, 18, 96, 12, 0, 48, 1, 20, 0, 26, 83, 111, 76, 93, 233, 179, 0, 0, 128, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8, 0, 0, 186, 0, 1]


var move_component_path = "res://Scenes/Characters/ModularSystems/Move/Move.tscn"


func test_entities_and_components_identified_before_ready():
	var character = load(character_path).instantiate()
	var move = load(move_component_path).instantiate()
	assert_true(character.is_entity)
	assert_false(move.is_entity)
	character.queue_free()
	move.queue_free()
	await get_tree().process_frame

func test_character_gets_move_added_from_server() -> void:
	CommandFrame.frame = TestFunctions.move_server_frame + 3
	CommandFrame.execute()
	MissPredictFrameTracker.add_reset_frame(TestFunctions.move_server_frame - 3)
	
	# Spawn the character
	Server._on_packet_received(1, character_data.duplicate())
	PlayerUpdateSystem.execute()
	await get_tree().process_frame
	var char_id = ObjectCreationRegistry.class_id_to_int_id["CHR"]
	var expected_char = ObjectsInScene.find_and_return_object(char_id, test_character_instance_id)
	assert_true(is_instance_valid(expected_char))
	await get_tree().process_frame

	# Spawn the move component
	Server._on_packet_received(1, move_data.duplicate())
	PlayerUpdateSystem.execute()
	await get_tree().process_frame
	var move_id = ObjectCreationRegistry.class_id_to_int_id["MVE"]
	var expected_mov_comp = ObjectsInScene.find_and_return_object(move_id, test_move_instance_id)

	# Perform the rollback to spawn the character and attach components
	RollbackSystem.execute(CommandFrame.frame)

	# Confirm that the move component is added to the player
	assert_true(is_instance_valid(expected_mov_comp))
	assert_true(expected_char.components.has(expected_mov_comp), "Currently failing because we character hasn't entered the scene tree")
	assert_false(expected_mov_comp.is_lag_comp)
	ObjectsInScene.stop_tracking(expected_char.netcode.class_id, expected_char.netcode.class_instance_id)
	ObjectsInScene.stop_tracking(expected_mov_comp.netcode.class_id, expected_mov_comp.netcode.class_instance_id)
	TestFunctions.queue_scenes_free([expected_char])
	await get_tree().process_frame
#	_assert_components_hang_around_until_entity_is_created()
#
##func _assert_components_hang_around_until_entity_is_created():
##	# Spawn the move data
#	Server._on_packet_received(1, move_data.duplicate())
#	PlayerUpdateSystem.execute()
#	await get_tree().process_frame
#	#var move_id = ObjectCreationRegistry.class_id_to_int_id["MVE"]
#	var move_component = ObjectsInScene.find_and_return_object(move_id, test_move_instance_id)
#	assert_true(ObjectCreationRegistry.is_connected("entity_created",Callable(move_component.netcode,"_on_entity_created")))
#	# Then spawn the entity, assert that the component is added and the signal is disconnected
#	await get_tree().process_frame
#
#	# Spawn the player
#	Server._on_packet_received(1, character_data.duplicate())
#	PlayerUpdateSystem.execute()
#	await get_tree().process_frame
#	#var char_id = ObjectCreationRegistry.class_id_to_int_id["CHR"]
#	var character = ObjectsInScene.find_and_return_object(char_id, test_character_instance_id)
#
#	# Confirm the player gets the move component attached to it
#	assert_true(character.components.has(move_component))
#	assert_false(ObjectCreationRegistry.is_connected("entity_created",Callable(move_component.netcode,"_on_entity_created")))
#	ObjectCreationRegistry.stop_tracking(character.netcode.class_id, character.netcode.class_instance_id)
#	ObjectCreationRegistry.stop_tracking(move_component.netcode.class_id, move_component.netcode.class_instance_id)
#	TestFunctions.queue_scenes_free([move_component, character])
#	await get_tree().process_frame
