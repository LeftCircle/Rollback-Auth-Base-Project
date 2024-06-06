extends GutTestRogue

var char_path = "res://Scenes/Characters/PlayerCharacter/ClientPlayerCharacter.tscn"

func test_char_load():
	var character = _load_character()
	await get_tree().process_frame
	assert_true(is_instance_valid(character))
	#assert_true(_is_sprite_container_loaded_for_states(character))
	character.queue_free()
	await get_tree().process_frame

func _is_sprite_container_loaded_for_states(character) -> bool:
	var attack_state = character.get_node("PlayerStates/AttackPrimaryState")
	return is_instance_valid(attack_state.sprite_container)

func _load_character() -> ClientPlayerCharacter:
#	var character = load(char_path).instantiate()
#	ObjectCreationRegistry.add_child(character)
#	return character
	return TestFunctions.init_player_character()
