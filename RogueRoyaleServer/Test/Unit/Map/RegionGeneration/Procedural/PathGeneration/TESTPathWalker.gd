extends GutTest


var path_walker_path = "res://Scenes/Map/RegionGeneration/RegionFromGrammar/ProceduralGeneration/PathWalker.gd"
var floor_to_load = "GutRegionGeneration"
var region_from_grammar_path = "res://Scenes/Map/RegionGeneration/RegionFromGrammar/RegionFromGrammar.tscn"
var test_tile_map_path = "res://Test/Unit/Map/RegionGeneration/Procedural/PathGeneration/EmptyTileMap.tscn"
var floor_tile = 1
var wall_tile = 0

func test_25_tiles_are_placed_on_successfull_step():
	var path_walker = _instance_path_walker()
	path_walker.step(Vector2.ZERO)
	var used_cells = path_walker.tile_map.get_used_cells(0)
	assert_eq(path_walker.tile_map.get_used_cells(0).size(), 25)
	assert_eq(path_walker.tile_map.get_cell_source_id(0, Vector2i.ZERO), floor_tile)
	assert_eq(path_walker.tile_map.get_cell_source_id(0, Vector2i(-2, -2)), wall_tile)
	queue_scenes_free(path_walker)

func test_floor_tiles_overwrite_walls_and_walls_do_not_overwrite_floors():
	var path_walker = _instance_path_walker()
	path_walker.step(Vector2.ZERO)
	path_walker.step(Vector2(1, 0))
	var n_walls = path_walker.tile_map.get_used_cells_by_id(0, wall_tile).size()
	var n_floors = path_walker.tile_map.get_used_cells_by_id(0, floor_tile).size()
	assert_eq(n_walls, 18)
	assert_eq(n_floors, 12)
	queue_scenes_free(path_walker)

func test_path_walks_between_points() -> void:
	var path_walker = _instance_path_walker()
	var point_a = Vector2(0, 0)
	var point_b = Vector2(20, 20)
	path_walker.walk_between_tile_points(point_a, point_b)
	var n_walls = path_walker.tile_map.get_used_cells_by_id(0, wall_tile).size()
	var n_floors = path_walker.tile_map.get_used_cells_by_id(0, floor_tile).size()
	var expected_walls = 96
	var expoected_floors = 107
	assert_eq(n_walls, expected_walls)
	assert_eq(n_floors, expoected_floors)
	queue_scenes_free(path_walker)

func _instance_path_walker() -> PathWalker:
	var path_walker = load(path_walker_path).new()
	path_walker.tile_map = _instance_test_tile_map()
	path_walker.floor_tile = floor_tile
	path_walker.wall_tile = wall_tile
	return path_walker

func _instance_test_tile_map() -> TileMap:
	var test_tile_map = load(test_tile_map_path).instantiate()
	ObjectCreationRegistry.add_child(test_tile_map)
	return test_tile_map

func _build_test_region() -> RegionFromGrammar:
	# Loads a test region that is just two normal rooms next to eachother
	# Load in the region generation then yield until it is complete.
	var region_from_grammar = load(region_from_grammar_path).instantiate()
	region_from_grammar.floor_to_load = floor_to_load
	# To ensure that edge tiles are hit by the path generation
	region_from_grammar.n_tiles_to_grow_region = 3
	ObjectCreationRegistry.add_child(region_from_grammar)
	return region_from_grammar

func _build_polygon_from_rect(rect2 : Rect2) -> PackedVector2Array:
	var polygon = PackedVector2Array()
	polygon.append(rect2.position)
	polygon.append(rect2.position + Vector2(rect2.size.x, 0))
	polygon.append(rect2.end)
	polygon.append(rect2.position + Vector2(0, rect2.size.y))
	return polygon

func queue_scenes_free(path_walker : PathWalker) -> void:
	path_walker.tile_map.queue_free()
