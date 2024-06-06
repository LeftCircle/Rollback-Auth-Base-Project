extends GutTestRogue

var test_id_1 = 9120344
var test_id_2 = 9120345

func test_character_is_owner_of_components() -> void:
	var character = TestFunctions.init_player_character(test_id_1)
	var second_character = TestFunctions.init_player_character(test_id_2)
	await get_tree().process_frame
	var all_first_owned = _does_character_own_all_components(character)
	var all_second_owned = _does_character_own_all_components(second_character)
	assert_true(all_first_owned, "checking first character")
	assert_true(all_second_owned, "checking second character")
	TestFunctions.queue_scenes_free([character, second_character])

func _does_character_own_all_components(character : ServerPlayerCharacter) -> bool:
	var all_components_are_owned = true
	for component in character.components.get_children():
		var owner_class_matches = component.netcode.owner_class_id == ObjectCreationRegistry.class_id_to_int_id[character.netcode.class_id]
		var owner_instance_matches = component.netcode.owner_instance_id == character.netcode.class_instance_id
		all_components_are_owned = all_components_are_owned and owner_class_matches and owner_instance_matches
	return all_components_are_owned

func test_component_is_sent_to_clients_on_creation_frame() -> void:
	PlayerStateSync.set_physics_process(true)
	var frame = random_frame()
	var knockback_component = await instance_scene_by_id("KBK")
	var player : ServerPlayerCharacter = await init_player_character(randi_range(0, 1000000))
	player.add_component(frame, knockback_component)
	# Assert the knockback component is being sent to clients
	assert_true(PlayerStateSync.has_component(knockback_component))
	PlayerStateSync._reset()
	PlayerStateSync.set_physics_process(false)
