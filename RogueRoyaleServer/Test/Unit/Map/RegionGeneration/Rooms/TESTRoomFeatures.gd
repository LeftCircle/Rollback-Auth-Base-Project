extends GutTest

var base_path_to_rooms = "res://Scenes/Map/DungeonRooms/"
var base_path_to_doors = "res://Scenes/Map/DungeonDoors/"
var test_character_path = "res://Test/TestScenes/TestCharacter/BasicTestCharacter.tscn"
var test_room_path = "res://Scenes/Map/DungeonRooms/RoomScenes/PlayTest/SpawnRooms/PlayTestRoom.tscn"
var base_enemy_path = "res://Scenes/Characters/Enemies/BaseEnemy.tscn"

func test_all_rooms_have_at_least_one_door():
	var rooms = _get_all_rooms()
	var all_rooms_have_doors = true
	for room in rooms:
		var room_has_door = _does_room_have_door(room)
		if not room_has_door:
			all_rooms_have_doors = false
			print("Room " + room.name + " does not have a door")
	assert_true(all_rooms_have_doors)
	_queue_scenes_free(rooms)

func test_all_rooms_are_netcode_objects():
	var rooms = _get_all_rooms()
	var all_rooms_are_netcode_objects = _are_all_scenes_netcode_objects(rooms)
	assert_true(all_rooms_are_netcode_objects)
	_queue_scenes_free(rooms)

func test_all_doors_are_netcode_objects():
	var doors = _get_all_doors()
	var all_doors_are_netcode_objects = _are_all_scenes_netcode_objects(doors)
	assert_true(all_doors_are_netcode_objects)
	_queue_scenes_free(doors)

func test_doors_close_when_player_enters():
	var room_and_char = _spawn_test_room_with_character_inside()
	var test_room = room_and_char[0]
	var test_character = room_and_char[1]
	assert_true(test_room.door_container.doors_closed == true)
	test_room.queue_free()
	test_character.queue_free()

func test_doors_open_if_player_leaves_room_border():
	var test_room = _spawn_test_room()
	var test_character = _spawn_test_character()
	_character_enter_then_exit_room(test_character, test_room)
	assert_true(test_room.door_container.doors_closed == false)
	assert_true(test_room.get_node("MobAndDoorController/RoomMobSpawner").players_who_have_entered.is_empty() == true)
	_queue_scenes_free([test_room, test_character])

func test_at_least_one_mob_spawns_on_first_encounter():
	var test_room = _spawn_test_room()
	_add_base_enemy_to_room(test_room)
	var test_character = _spawn_test_character()
	move_character_to_center_of_room(test_character, test_room)
	var mob_spawner = test_room.get_node("MobAndDoorController/RoomMobSpawner")
	mob_spawner._on_MobSpawner_body_entered(test_character)
	assert_true(mob_spawner.mobs.size() > 0)
	_queue_scenes_free([test_room, test_character])

func test_doors_open_when_all_mobs_are_killed():
	var room_and_char = _spawn_test_room_with_character_inside()
	var test_room = room_and_char[0]
	kill_all_mobs_in_room(test_room)
	assert_true(test_room.door_container.doors_closed == false)
	_queue_scenes_free(room_and_char)

func test_doors_dont_close_after_first_successful_encounter_and_mobs_spawn():
	var test_room = _spawn_test_room()
	var test_char = _spawn_test_character()
	var second_test_character = _spawn_test_character()
	_have_player_enter_room_and_spawn_mob(test_char, test_room)
	assert_true(test_room.door_container.doors_closed == true)
	kill_all_mobs_in_room(test_room)
	assert_true(_does_room_have_mobs(test_room) == false)
	_have_player_exit_room(test_char, test_room)
	_have_player_enter_room(second_test_character, test_room)
	assert_true(test_room.door_container.doors_closed == false)
	assert_true(_does_room_have_mobs(test_room) == true)
	_queue_scenes_free([test_room, test_char, second_test_character])

func _character_enter_then_exit_room(test_character, test_room):
	test_room.get_node("MobAndDoorController/PlayerExitCheck")._on_PlayerExitCheck_body_entered(test_character)
	test_room.get_node("MobAndDoorController/RoomMobSpawner")._on_MobSpawner_body_entered(test_character)
	test_room.get_node("MobAndDoorController/RoomMobSpawner")._on_MobSpawner_body_exited(test_character)
	test_room.get_node("MobAndDoorController/PlayerExitCheck")._on_PlayerExitCheck_body_exited(test_character)

func _are_all_scenes_netcode_objects(scenes : Array) -> bool:
	var all_scenes_are_netcode_objects = true
	for scene in scenes:
		var has_netcode = scene.get("netcode") != null
		if not has_netcode:
			all_scenes_are_netcode_objects = false
			print("Scene " + scene.name + " is not a netcode object")
	return all_scenes_are_netcode_objects

func _queue_scenes_free(scenes : Array) -> void:
	for scene in scenes:
		scene.queue_free()

func _does_room_have_door(room) -> bool:
	var door_container = room.get_node_or_null("Doors")
	if not is_instance_valid(door_container):
		return false
	else:
		var door_count = door_container.get_child_count()
		if door_count > 0:
			return true
		else:
			return false

func _get_all_rooms():
	var rooms = []
	var file_lister = FileLister.new()
	file_lister.folder_path = base_path_to_rooms
	file_lister.file_ending = ".tscn"
	file_lister.with_sub_folders = true
	file_lister.load_resources()
	for file in file_lister.all_file_paths:
		var room = load(file).instantiate()
		rooms.append(room)
	return rooms

func _get_all_doors():
	var doors = []
	var file_lister = FileLister.new()
	file_lister.folder_path = base_path_to_doors
	file_lister.file_ending = ".tscn"
	file_lister.with_sub_folders = true
	file_lister.load_resources()
	for file in file_lister.all_file_paths:
		var door = load(file).instantiate()
		doors.append(door)
	return doors

func _does_room_have_mobs(test_room) -> bool:
	var mob_spawner = test_room.get_node("MobAndDoorController/RoomMobSpawner")
	return mob_spawner.mobs.size() > 0

func _have_player_enter_room(test_character, test_room) -> void:
	test_room.get_node("MobAndDoorController/PlayerExitCheck")._on_PlayerExitCheck_body_entered(test_character)
	test_room.get_node("MobAndDoorController/RoomMobSpawner")._on_MobSpawner_body_entered(test_character)

func _have_player_enter_room_and_spawn_mob(test_character, test_room) -> void:
	_add_base_enemy_to_room(test_room)
	move_character_to_center_of_room(test_character, test_room)
	test_room.get_node("MobAndDoorController/PlayerExitCheck")._on_PlayerExitCheck_body_entered(test_character)
	test_room.get_node("MobAndDoorController/RoomMobSpawner")._on_MobSpawner_body_entered(test_character)

func _have_player_exit_room(test_character, test_room) -> void:
	test_room.get_node("MobAndDoorController/RoomMobSpawner")._on_MobSpawner_body_exited(test_character)
	test_room.get_node("MobAndDoorController/PlayerExitCheck")._on_PlayerExitCheck_body_exited(test_character)

func kill_all_mobs_in_room(test_room) -> void:
	var mob_spawner = test_room.get_node("MobAndDoorController/RoomMobSpawner")
	for mob in mob_spawner.mobs:
		mob._on_death()
		mob.queue_free()

func _spawn_test_room_with_character_inside() -> Array:
	var test_room = _spawn_test_room()
	var test_character = _spawn_test_character()
	_have_player_enter_room_and_spawn_mob(test_character, test_room)
	return [test_room, test_character]

func move_character_to_center_of_room(character, room):
	var room_center = room.get_room_center()
	character.global_position = room_center

func _spawn_test_character():
	var test_character = load(test_character_path).instantiate()
	ObjectCreationRegistry.add_child(test_character)
	return test_character

func _spawn_test_room():
	var test_room = load(test_room_path).instantiate()
	ObjectCreationRegistry.add_child(test_room)
	return test_room

func _spawn_base_enemy():
	var base_enemy = load(base_enemy_path).instantiate()
	ObjectCreationRegistry.add_child(base_enemy)
	return base_enemy

func _add_base_enemy_to_room(room):
	var mob_spawner = room.get_node("MobAndDoorController/RoomMobSpawner")
	mob_spawner.mob_scene_paths.append(base_enemy_path)
