extends GutTestRogue

# This is a packet containing map data from the server. It should contain two rooms and six doors.
# Acquired by grabbing the packet from map spawn data
var test_packet_from_server = [7, 95, 32, 0, 0, 96, 5, 24, 32, 1, 0, 11, 192, 0, 81, 145, 4, 3, 0, 0, 43, 128, 0, 168, 8, 128, 42, 146, 170, 0, 168, 34, 169, 4, 144, 1, 0, 43, 128, 128, 172, 4, 128, 42, 146, 74, 0, 41, 0, 176, 2, 13, 160, 138, 0, 168, 34, 169, 0, 128, 42, 146, 42, 0, 49, 0, 192, 0, 16, 0, 42, 1, 160, 138, 164, 42, 64, 18, 0, 48, 0, 4, 164, 74, 0, 168, 34, 169, 10, 144, 5, 0, 11, 176, 0, 170, 12, 128, 42, 146, 10, 0, 168, 34, 169, 6, 128, 42, 146, 138, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 148, 1, 0, 124, 3, 6]
var floor_tile_id = 0
var path_tile_id = 1
var wall_tile_id = 0
var forbidden_tile_id = 1

func test_rooms_doors_and_paths_spawn():
	var frame = _read_test_packet()
	CommandFrame.frame = frame
	CommandFrame.execute()
	RollbackSystem.execute(CommandFrame.get_next_frame(frame))
	await get_tree().process_frame
	#await Map.region_generated
	var rooms = get_tree().get_nodes_in_group("Rooms")
	var doors = get_tree().get_nodes_in_group("Doors")
	assert_eq(rooms.size(), 2)
	assert_eq(doors.size(), 6)
	assert_path_between_room_generater_is_initialized()
	assert_paths_are_created()
	assert_true(Map.debug_is_region_generated)
	assert_path_places_floor_path_wall_and_forbidden_tiles()
	Map.clear()
	SceneFreer.queue_scenes_free(rooms)
	SceneFreer.queue_scenes_free(doors)

func _read_test_packet() -> int:
	Server._on_packet_received(1, test_packet_from_server)
	return 404 # 404 is the frame from the server packet

func assert_path_between_room_generater_is_initialized():
	var doors = get_tree().get_nodes_in_group("Doors")
	var rooms = get_tree().get_nodes_in_group("Rooms")
	var region_rect = Map.get_rect2_around_rooms(rooms)
	var rect_array = Map.get_border_rect2_array(rooms)
	var rect_array_tiles = Map.get_border_rect2_array_tiles(rooms)
	assert_eq(Map.paths_builder.region_rect, region_rect)
	assert_true(TestFunctions.arrays_match(Map.paths_builder.rect_array, rect_array), "Rect arrays match")
	assert_true(TestFunctions.arrays_match(Map.paths_builder.rect_array_tiles, rect_array_tiles), "Rect array tiles match")
	assert_true(TestFunctions.arrays_match(Map.paths_builder.rooms, rooms), "Rooms match")
	assert_true(TestFunctions.arrays_match(Map.paths_builder.doors, doors), "Doors match")

func assert_path_places_floor_path_wall_and_forbidden_tiles():
	assert_true(Map.floor_tile_map.get_used_cells_by_id(0, floor_tile_id).size() > 0)
	assert_true(Map.floor_tile_map.get_used_cells_by_id(0, path_tile_id).size() > 0)
	assert_true(Map.wall_tile_map.get_used_cells_by_id(0, wall_tile_id).size() > 0)
	assert_true(Map.wall_tile_map.get_used_cells_by_id(0, forbidden_tile_id).size() > 0)

func assert_floors_tilemap_and_wall_tilemap_are_created():
	assert_true(Map.floor_tile_map.get_used_cells(0).size() > 0)
	assert_true(Map.wall_tile_map.get_used_cells(0).size() > 0)

func assert_paths_are_created():
	var n_tiles_placed = Map.floor_tile_map.get_used_cells(0).size()
	assert_true(n_tiles_placed > 0)
	var n_walls = Map.wall_tile_map.get_used_cells(0).size()
	assert_true(n_walls > 0)

