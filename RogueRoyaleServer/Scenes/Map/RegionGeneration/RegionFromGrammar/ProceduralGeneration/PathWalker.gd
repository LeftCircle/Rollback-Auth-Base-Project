extends RefCounted
class_name PathWalker

const STEP_SIZE = 2

var tile_map : TileMap
var floor_tile : int
var wall_tile : int

func init(new_tile_map : TileMap, new_floor_tile : int, new_wall_tile : int) -> void:
	tile_map = new_tile_map
	floor_tile = new_floor_tile
	wall_tile = new_wall_tile

func build_along(path : Array) -> void:
	var n_point_pairs = path.size() - 1
	for i in range(n_point_pairs):
		var point_a_tiles = tile_map.local_to_map(path[i])
		var point_b_tiles = tile_map.local_to_map(path[i + 1])
		walk_between_tile_points(point_a_tiles, point_b_tiles)
	#tile_map.update_bitmask_region()

func build_along_tile(path : Array) -> void:
	var n_point_pairs = path.size() - 1
	for i in range(n_point_pairs):
		walk_between_tile_points(path[i], path[i + 1])
	#tile_map.update_bitmask_region()

func walk_between_tile_points(point_a : Vector2, point_b : Vector2) -> void:
	step(point_a)
	var dir_to_point_b = point_a.direction_to(point_b)
	var next_tile = (point_a + dir_to_point_b * STEP_SIZE).round()
	while next_tile != point_b:
		step(next_tile)
		dir_to_point_b = next_tile.direction_to(point_b)
		next_tile = (next_tile + dir_to_point_b * STEP_SIZE).round()
		if next_tile.distance_to(point_b) < STEP_SIZE:
			break
	step(point_b)


func step(tile_pos : Vector2) -> void:
	# Places a 5x5 region of tiles at the given position, where the tiles should be
	# 1 1 1 1 1  Where 1 is a wall and 0 is a floor. The tile is placed centered on the
	# 1 0 0 0 1
	# 1 0 0 0 1 The tile is placed centered on the center 0 <---
	# 1 0 0 0 1
	# 1 1 1 1 1
	_set_floor_tiles(tile_pos)
	_set_wall_tiles(tile_pos)

func _set_floor_tiles(pos : Vector2) -> void:
	_set_floor_tile(pos + Vector2(-1, -1), floor_tile)
	_set_floor_tile(pos + Vector2(0, -1), floor_tile)
	_set_floor_tile(pos + Vector2(1, -1), floor_tile)
	_set_floor_tile(pos + Vector2(-1, 0), floor_tile)
	_set_floor_tile(pos + Vector2(0, 0), floor_tile)
	_set_floor_tile(pos + Vector2(1, 0), floor_tile)
	_set_floor_tile(pos + Vector2(-1, 1), floor_tile)
	_set_floor_tile(pos + Vector2(0, 1), floor_tile)
	_set_floor_tile(pos + Vector2(1, 1), floor_tile)

func _set_wall_tiles(pos : Vector2) -> void:
	_set_wall_tile(pos + Vector2(-2, -2))
	_set_wall_tile(pos + Vector2(-1, -2))
	_set_wall_tile(pos + Vector2(0, -2))
	_set_wall_tile(pos + Vector2(1, -2))
	_set_wall_tile(pos + Vector2(2, -2))
	_set_wall_tile(pos + Vector2(-2, -1))
	_set_wall_tile(pos + Vector2(2, -1))
	_set_wall_tile(pos + Vector2(-2, 0))
	_set_wall_tile(pos + Vector2(2, 0))
	_set_wall_tile(pos + Vector2(-2, 1))
	_set_wall_tile(pos + Vector2(2, 1))
	_set_wall_tile(pos + Vector2(-2, 2))
	_set_wall_tile(pos + Vector2(-1, 2))
	_set_wall_tile(pos + Vector2(0, 2))
	_set_wall_tile(pos + Vector2(1, 2))
	_set_wall_tile(pos + Vector2(2, 2))


func _set_floor_tile(pos : Vector2, tile_id : int) -> void:
	tile_map.set_cell(0, pos, tile_id, Vector2i.ZERO)

func _set_wall_tile(pos : Vector2) -> void:
	if tile_map.get_cell_source_id(0, pos) == -1:
		tile_map.set_cell(0, pos, wall_tile, Vector2i.ZERO)
