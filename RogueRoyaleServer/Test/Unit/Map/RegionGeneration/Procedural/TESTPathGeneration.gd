extends GutTest

var floor_to_load = "GutRegionGeneration"
var region_from_grammar_path = "res://Test/Unit/Map/RegionGeneration/Procedural/TestRegionFromGrammar.tscn"
var TILE_SIZE = ProjectSettings.get_setting("global/TILE_SIZE")

func test_path_generation():
	# The test region is built without adding the paths yet
	var region_from_grammar = _build_test_region()
	await region_from_grammar.region_generation_complete
	assert_tiles_cleared_from_rooms(region_from_grammar)
	assert_path_contains_door_centers(region_from_grammar)
	assert_connecting_doors_adds_netcode_data(region_from_grammar)
	region_from_grammar.queue_free()

func assert_tiles_cleared_from_rooms(region_from_grammar : RegionFromGrammar) -> void:
	var rooms = region_from_grammar.room_container.get_children()
	for room in rooms:
		region_from_grammar.path_between_room_generator.path_walker.step(room.room_rect2_tiles.get_center())
	region_from_grammar.path_between_room_generator._clear_tiles_from_rects()
	var n_used_cells = region_from_grammar.region_filler_tilemap.get_used_cells(0).size()
	assert_true(n_used_cells == 0)

func assert_path_contains_door_centers(region_from_grammar : RegionFromGrammar) -> void:
	var rooms = region_from_grammar.room_container.get_children()
	var doors_to_connect = rooms[0].get_closest_door_pair_to(rooms[1])
	var door_center = doors_to_connect[0].get_center()
	var other_center = doors_to_connect[1].get_center()
	var path = region_from_grammar.path_between_room_generator._get_paths_between_doors()
	assert_almost_eq(door_center.distance_to(path[0][0]), TILE_SIZE, TILE_SIZE)
	assert_almost_eq(other_center.distance_to(path[0][-1]), TILE_SIZE, TILE_SIZE)

func assert_connecting_doors_adds_netcode_data(region_from_grammar : RegionFromGrammar) -> void:
	region_from_grammar.path_between_room_generator._get_paths_between_doors()
	region_from_grammar.path_between_room_generator._generate_paths_surrounding_rooms()
	var rooms = region_from_grammar.get_rooms()
	for room in rooms:
		var doors = room.get_doors()
		for door in doors:
			assert_true(door.connected_doors.size() > 0)

# func assert_tile_can_be_placed_outside_of_room(region : RegionFromGrammar) -> void:
# 	var rooms = region.room_container.get_children()
# 	var rect_enclosing_all_rooms = rooms[0].room_rect2_tiles
# 	for room in rooms:
# 		room_rects.append(room.room_rect2_tiles)
# 	var region_rect = region.region_rect2_tiles
# 	var outside_of_room = region_rect.grow(-1).clip(room_rects[0].grow(-1))
# 	region.path_between_room_generator.non_linear_path_builder._place_tile_at(outside_of_room.get_center())
# 	var n_used_cells = region.region_filler_tilemap.get_used_cells(0).size()
# 	assert_true(n_used_cells == 1)

# func assert_tiles_can_be_placed_along_path(region : RegionFromGrammar) -> void:
# 	var paths = region.path_between_room_generator.paths
# 	var non_linear_builder = region.path_between_room_generator.non_linear_path_builder
# 	for path in paths:
# 		non_linear_builder.build_along(path)
# 	#assert_true(non_linear)
# 	#assert_true(false)


func _build_test_region() -> TestRegionFromGrammar:
	# Loads a test region that is just two normal rooms next to eachother
	# Load in the region generation then yield until it is complete.
	var region_from_grammar = load(region_from_grammar_path).instantiate()
	region_from_grammar.floor_to_load = floor_to_load
	# To ensure that edge tiles are hit by the path generation
	region_from_grammar.n_tiles_to_grow_region = 3
	ObjectCreationRegistry.add_child(region_from_grammar)
	return region_from_grammar
