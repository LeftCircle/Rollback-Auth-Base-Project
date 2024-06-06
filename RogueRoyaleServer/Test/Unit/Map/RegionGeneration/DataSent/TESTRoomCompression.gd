extends GutTest

var test_id = 12345
var test_room_path = "res://Scenes/Map/DungeonRooms/RoomScenes/PlayTest/SpawnRooms/PlayTestRoom.tscn"
var test_room_position = Vector2(-10, 10)

#func __test_room_compression() -> void:
#	var test_room = _spawn_test_room()
#	await get_tree().create_timer(0.3).timeout
#	_register_test_client()
#	test_room.prep_data_to_send()
	#MapClientSpawner.send_map_data_test()
	#var compressed_data = MapClientSpawner.packets_to_players[test_id]
	# We should compress the data, then decompress the data and get the returned data container, and verify
	# that the returned data container matches the original data container
	#assert_true(test_room.netcode.test_compressed_data_matches_decompression())
	#for door in test_room.door_container.get_children():
	#	print("testing door")
	#	assert_true(door.netcode.test_compressed_data_matches_decompression())
	#test_room.queue_free()


func _register_test_client() -> void:
	Server.on_player_verified(test_id)

func _spawn_test_room():
	var test_room = load(test_room_path).instantiate()
	test_room.position = test_room_position
	ObjectCreationRegistry.add_child(test_room)
	return test_room
