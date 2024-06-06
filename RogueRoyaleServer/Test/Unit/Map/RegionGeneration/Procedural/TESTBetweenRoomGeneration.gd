extends GutTest

var floor_to_load = "GutRegionGeneration"
var region_from_grammar_path = "res://Scenes/Map/RegionGeneration/RegionFromGrammar/RegionFromGrammar.tscn"

func test_region_is_generated():
	var region_from_grammar = _build_test_region()
	await region_from_grammar.region_generation_complete
	assert_true(region_from_grammar.region_built == true)
	assert_true(_are_all_rooms_connected(region_from_grammar))
	assert_closest_doors_are_found(region_from_grammar)
	region_from_grammar.queue_free()

func _are_all_rooms_connected(region : RegionFromGrammar) -> bool:
	var spring = region.spring_container.get_child(0)
	var rooms = region.room_container.get_children()
	var has_room_0 = spring.g_node_a.room_scene in rooms
	var has_room_1 = spring.g_node_a.room_scene in rooms
	return has_room_0 and has_room_1

func assert_closest_doors_are_found(region : RegionFromGrammar) -> void:
	var closest_door_pair = _get_closest_door_pair(region)
	assert_true(is_instance_valid(closest_door_pair[0]) and is_instance_valid(closest_door_pair[1]))

func are_edge_tiles_are_not_ereased(region : RegionFromGrammar) -> bool:
	var region_rect_tiles = region.get_region_rect2_tiles()
	region_rect_tiles = region_rect_tiles.grow(region.n_tiles_to_grow_region)
	for x in range(region_rect_tiles.position.x, region_rect_tiles.end.x):
		if region.region_filler_tilemap.get_cell_source_id(0, Vector2i(x, region_rect_tiles.position.y)) != 1:
			return false
		if region.region_filler_tilemap.get_cell_source_id(0, Vector2i(x, region_rect_tiles.end.y)) != 1:
			return false
	for y in range(region_rect_tiles.position.y, region_rect_tiles.end.y):
		if region.region_filler_tilemap.get_cell_source_id(0, Vector2i(region_rect_tiles.position.x, y)) != 1:
			return false
		if region.region_filler_tilemap.get_cell_source_id(0, Vector2i(region_rect_tiles.end.x, y)) != 1:
			return false
	return true

func _get_closest_door_pair(region : RegionFromGrammar) -> Array:
	var spring = region.spring_container.get_child(0)
	var room_0 = spring.g_node_a.room_scene
	var room_1 = spring.g_node_b.room_scene
	return room_0.get_closest_door_pair_to(room_1)

func _build_test_region() -> RegionFromGrammar:
	# Loads a test region that is just two normal rooms next to eachother
	# Load in the region generation then yield until it is complete.
	var region_from_grammar = load(region_from_grammar_path).instantiate()
	region_from_grammar.floor_to_load = floor_to_load
	# To ensure that edge tiles are hit by the path generation
	region_from_grammar.n_tiles_to_grow_region = 3
	ObjectCreationRegistry.add_child(region_from_grammar)
	return region_from_grammar

