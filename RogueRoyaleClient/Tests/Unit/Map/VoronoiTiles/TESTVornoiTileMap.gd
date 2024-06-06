extends GutTestRogue

var voronoi_tile_map_path = "res://Scenes/Map/RegionGeneration/VoronoiTileMap/VoronoiTileMap.tscn"
var voronoi_tile_path = "res://Scenes/Map/RegionGeneration/VoronoiTileMap/VoronoiTile/VoronoiTile.tscn"


func test_init():
	var voronoi_placer = _spawn_tile_placer()
	assert_true(is_instance_valid(voronoi_placer))
	voronoi_placer.queue_free()

func test_find_corner_tiles():
	var voronoi_placer = _spawn_tile_placer()
	_spawn_tiles_in_test_square(voronoi_placer)
	assert_eq(voronoi_placer.get_used_cells(0).size(), 9)
	# Expected corner tile type == DownRight
	var expected_edge_tile_pos_and_type = {Vector2i(1, 1) : 2}
	voronoi_placer.find_corner_tile_cells()
	var actual_edge_tile_pos_and_type = voronoi_placer.corner_cells
	assert_true(actual_edge_tile_pos_and_type.keys().size() == 1)
	assert_true(expected_edge_tile_pos_and_type[Vector2i(1, 1)] == actual_edge_tile_pos_and_type[Vector2i(1, 1)])
	voronoi_placer.queue_free()

func test_voronoi_tiles_are_placed():
	var voronoi_placer = _spawn_tile_placer()
	_spawn_tiles_in_test_square(voronoi_placer)
	voronoi_placer.find_corner_tile_cells()
	var expected_voronoi_tile = _get_expected_voronoi_tile_from_test_square(voronoi_placer)
	voronoi_placer._spawn_voronoi_tiles()
	var actual_tile = voronoi_placer.voronoi_tiles[Vector2(1, 1)]
	assert_true(voronoi_placer.voronoi_tiles.keys().size() == 9)
	assert_true(actual_tile.position == expected_voronoi_tile.position)
	voronoi_placer.queue_free()
	expected_voronoi_tile.queue_free()

func test_12_tiles_placed_on_two_neighboring_corners():
	# Spawns a test square like so:
	# 1111  The two corner tiles are at (2, 1) and (2, 3)
	# 0011  There should be 12 voronoi tiles filling the top three rows
	# 0000
	# 0000
	var voronoi_placer = _spawn_tile_placer()
	_spawn_16_tiles_to_test_12_tiles_placed_on_two_neighboring_corners(voronoi_placer)
	voronoi_placer.find_corner_tile_cells()
	voronoi_placer._spawn_voronoi_tiles()
	assert_eq(voronoi_placer.voronoi_tiles.keys().size(), 12)
	voronoi_placer.queue_free()

func _spawn_16_tiles_to_test_12_tiles_placed_on_two_neighboring_corners(voronoi_placer : VoronoiTileMap):
	# Spawns tiles like
	# 1111
	# 0011
	# 0000
	# 0000
	var tile_map = voronoi_placer
	for i in range(0, 4):
		for j in range(0, 4):
			var tile_id = 0
			if j == 0:
				tile_id = 1
			if (j == 1 and i == 2) or (j == 1 and i == 3):
				tile_id = 1
			tile_map.set_cell(0, Vector2i(i, j), tile_id, Vector2i.ZERO)

func _get_expected_voronoi_tile_from_test_square(voronoi_placer : VoronoiTileMap):
	# Test square looks like
	# 111
	# 001
	# 001
	var expected_voronoi_tile = load(voronoi_tile_path).instantiate()
	CommandFrame.add_child(expected_voronoi_tile)
	expected_voronoi_tile.position = Vector2(1, 1) * voronoi_placer.TILE_SIZE
	return expected_voronoi_tile

func _spawn_tiles_in_test_square(voronoi_placer : VoronoiTileMap):
	# Spawns tiles like
	# 111
	# 001
	# 001
	var tile_map = voronoi_placer as TileMap
	for i in range(0, 3):
		for j in range(0, 3):
			var tile_id = 0
			if j == 0 or i == 2:
				tile_id =1
			tile_map.set_cell(0, Vector2i(i, j), tile_id, Vector2i.ZERO)

func _spawn_tile_placer() -> VoronoiTileMap:
	var voronoi_placer = load(voronoi_tile_map_path).instantiate()
	CommandFrame.add_child(voronoi_placer)
	return voronoi_placer
