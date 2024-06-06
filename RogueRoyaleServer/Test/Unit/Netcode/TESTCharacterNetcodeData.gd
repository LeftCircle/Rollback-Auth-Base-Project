extends GutTest

var move_path = "res://Scenes/Characters/ModularSystems/Move/Move.tscn"
const test_instance_id = 10
const test_move_id = 99

func test_character_data_to_client() -> void:
	var character = TestFunctions.init_player_character()
	Server.on_player_verified(character.player_id)
	character.netcode.class_instance_id = test_instance_id
	PlayerStateSync._reset()
	PlayerStateSync.packets_to_players[character.player_id].reset()
	PlayerStateSync._add_netcode_to_compress(character.netcode)
	PlayerStateSync._compress_netcode_objects()
	var comp_player_state = PlayerStateSync.packets_to_players[character.player_id].create_array_to_send()
	comp_player_state += [PacketTypes.PLAYER_STATES]
	print(comp_player_state)
	var expected = [128, 9, 16, 64, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 45, 0, 1]
	assert_eq(expected.size(), comp_player_state.size())
	character.remove_component(0, character.move)
	character.move.queue_free()
	var move_component = load(move_path).instantiate()
	character.add_component(0, move_component)
	await get_tree().process_frame
	move_component.netcode.class_instance_id = test_move_id
	PlayerStateSync._reset()
	PlayerStateSync.packets_to_players[character.player_id].reset()
	PlayerStateSync._add_netcode_to_compress(move_component.netcode)
	PlayerStateSync._compress_netcode_objects()
	comp_player_state = PlayerStateSync.packets_to_players[character.player_id].create_array_to_send()
	comp_player_state += [PacketTypes.PLAYER_STATES]
	print(comp_player_state)
	var expected_move = [219, 159, 18, 96, 12, 0, 48, 1, 20, 0, 26, 83, 111, 76, 93, 233, 179, 0, 0, 128, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8, 0, 0, 186, 0, 1]
	assert_eq(expected_move.size(), comp_player_state.size())

	TestFunctions.queue_scenes_free([character])


