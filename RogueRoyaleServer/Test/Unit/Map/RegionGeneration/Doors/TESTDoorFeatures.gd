extends GutTest

var tile_door_path = "res://Scenes/Map/DungeonDoors/TileDoor/S_TileDoor.tscn"
var TILE_SIZE = ProjectSettings.get_setting("global/TILE_SIZE")

func test_get_tile_door_center():
	var tile_door = _instance_tile_door(3, true, Vector2(0, 0))
	await get_tree().process_frame
	var expected_center = _get_expected_center(3, true, Vector2(0, 0))
	var door_center = tile_door.get_center()
	var dif = door_center.distance_squared_to(expected_center)
	assert_almost_eq(dif, 0, 0.001)
	tile_door.queue_free()

func test_add_connected_door():
	var tile_door = _instance_tile_door(3, true, Vector2(0, 0))
	var connected_door = _instance_tile_door(3, true, Vector2(10, 10))
	tile_door.add_connected_door(connected_door)
	# size is two because we need the class and instance id
	assert_eq(tile_door.connected_doors.size(), 2)
	assert_eq(tile_door.netcode.state_data.connected_doors[0], ObjectCreationRegistry.class_id_to_int_id[connected_door.netcode.class_id])
	assert_eq(tile_door.netcode.state_data.connected_doors[1], connected_door.netcode.class_instance_id)
	tile_door.queue_free()
	connected_door.queue_free()

func _get_expected_center(n_tiles : int, is_horizontal : bool, position : Vector2) -> Vector2:
	var expected_center = position
	if is_horizontal:
		expected_center.x += n_tiles / 2.0 * TILE_SIZE
	else:
		expected_center.y += n_tiles / 2.0 * TILE_SIZE
	return expected_center

func _instance_tile_door(n_tiles : int, is_horizontal : bool, position : Vector2):
	var tile_door = load(tile_door_path).instantiate()
	tile_door.n_tiles = n_tiles
	tile_door.is_horizontal = is_horizontal
	tile_door.position = position
	ObjectCreationRegistry.add_child(tile_door)
	return tile_door
