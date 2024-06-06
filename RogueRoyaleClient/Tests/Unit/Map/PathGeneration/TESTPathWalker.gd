extends GutTestRogue

var path_tile_id = 0
var floor_tile_id = 1
var wall_tile_id = 0
var forbidden_tile_id = 1
var floor_tile_map_path = "res://Scenes/Map/TileMaps/FirstFloor/Floor/FirstFloorFloors.tscn"
var wall_tile_map_path = "res://Scenes/Map/TileMaps/FirstFloor/Walls/Walls.tscn"

func test_path_walker_places_walls_and_floors():
	var path_walker_and_tilemaps = _init_path_walker_and_tilemaps()
	var path_walker = path_walker_and_tilemaps[0]
	var floor_tile_map = path_walker_and_tilemaps[1]
	var wall_tile_map = path_walker_and_tilemaps[2]
	path_walker.init_floor_tile_map(floor_tile_map, 0, 1)
	path_walker.init_wall_tile_map(wall_tile_map, 0, 1)
	path_walker.step(Vector2.ZERO)
	assert_floor_and_path_tiles_are_placed(floor_tile_map)
	assert_walls_are_placed(wall_tile_map)
	TestFunctions.queue_scenes_free([floor_tile_map, wall_tile_map])
	await get_tree().process_frame

func test_walls_replaced_by_floors():
	var path_walker_and_tilemaps = _init_path_walker_and_tilemaps()
	var path_walker = path_walker_and_tilemaps[0]
	var floor_tile_map = path_walker_and_tilemaps[1]
	var wall_tile_map = path_walker_and_tilemaps[2]
	path_walker.init_floor_tile_map(floor_tile_map, 0, 1)
	path_walker.init_wall_tile_map(wall_tile_map, 0, 1)
	path_walker.step(Vector2.ZERO)
	path_walker.step(Vector2.RIGHT * PathWalker.STEP_SIZE)
	assert_correct_number_of_walls_after_step(wall_tile_map)
	TestFunctions.queue_scenes_free([floor_tile_map, wall_tile_map])
	await get_tree().process_frame

func test_direcitonal_step():
#	var path_walker_and_tilemaps = _init_path_walker_and_tilemaps()
#	var path_walker = path_walker_and_tilemaps[0]
#	var floor_tile_map = path_walker_and_tilemaps[1]
#	var wall_tile_map = path_walker_and_tilemaps[2]
#	path_walker.init_floor_tile_map(floor_tile_map, 0, 1)
#	path_walker.init_wall_tile_map(wall_tile_map, 0, 1)
#	pass
	pass

func assert_floor_and_path_tiles_are_placed(floor_tile_map : TileMap):
	# The step function acts like so:
	# Places a 5x6 region of tiles at the given position, where the tiles should be
	#  f f f f f
	#  f w w w f Where w is a wall and 0 is a floor, p is a path, and f is forbidden. The tile is placed centered on the
	#  f 0 P 0 f
	#  f P P P f The tile is placed centered on the center P <---
	#  f 0 P 0 f
	#  f f f f f
	var n_used_floor = floor_tile_map.get_used_cells_by_id(0, floor_tile_id).size()
	var n_used_path = floor_tile_map.get_used_cells_by_id(0, path_tile_id).size()
	assert_eq(n_used_floor + n_used_path, 9)
	assert_true(n_used_floor > 0)
	assert_true(n_used_path > 0)

func assert_walls_are_placed(wall_tile_map : TileMap):
	assert_true(wall_tile_map.get_used_cells_by_id(0, wall_tile_id).size() == 3)
	assert_true(wall_tile_map.get_used_cells_by_id(0, forbidden_tile_id).size() == 18)

func assert_correct_number_of_walls_after_step(wall_tile_map : TileMap):
	# The step to the right should result in
	#  f f f f f f f
	#  f w w w w w f  <-- this can only occur if a wall can replace a forbidden tile
	#  f 0 0 0 0 0 f      If not, wall_tiles == 4 and n_forbidden == 23
	#  f 0 P 0 P 0 f
	#  f 0 0 0 0 0 f
	#  f f f f f f f
	var wall_tiles = wall_tile_map.get_used_cells_by_id(0, wall_tile_id).size()
	var n_forbidden = wall_tile_map.get_used_cells_by_id(0, forbidden_tile_id).size()
	assert_eq(wall_tiles, 5)
	assert_eq(n_forbidden, 22)

func _init_path_walker_and_tilemaps() -> Array:
	var new_walker = PathWalker.new()
	var floor_tile_map = load(floor_tile_map_path).instantiate()
	var wall_tile_map = load(wall_tile_map_path).instantiate()
	ObjectCreationRegistry.add_child(floor_tile_map)
	ObjectCreationRegistry.add_child(wall_tile_map)
	return [new_walker, floor_tile_map, wall_tile_map]

