extends RefCounted
class_name PathWalker

const STEP_SIZE = 2

var floor_tile_map : TileMap
var wall_tile_map : TileMap
var floor_tile_id : int
var path_tile_id : int
var wall_tile_id : int
var forbidden_tile_id : int

func init_floor_tile_map(new_tile_map : TileMap, new_path_tile : int, new_floor_tile : int) -> void:
	floor_tile_map = new_tile_map
	floor_tile_id = new_floor_tile
	path_tile_id = new_path_tile

func init_wall_tile_map(new_tile_map : TileMap, new_wall_tile : int, new_forbidden_tile : int) -> void:
	wall_tile_map = new_tile_map
	wall_tile_id = new_wall_tile
	forbidden_tile_id = new_forbidden_tile

func build_along(path : Array) -> void:
	var n_point_pairs = path.size() - 1
	for i in range(n_point_pairs):
		var point_a_tiles = floor_tile_map.local_to_map(path[i])
		var point_b_tiles = floor_tile_map.local_to_map(path[i + 1])
		walk_between_tile_points(point_a_tiles, point_b_tiles)
	#floor_tile_map.update_bitmask_region()
	#wall_tile_map.update_bitmask_region()

func build_along_tile(path : Array) -> void:
	var n_point_pairs = path.size() - 1
	for i in range(n_point_pairs):
		walk_between_tile_points(path[i], path[i + 1])
	#floor_tile_map.update_bitmask_region()
	#wall_tile_map.update_bitmask_region()

func walk_between_tile_points(point_a : Vector2, point_b : Vector2) -> void:
	var dir_to_point_b = point_a.direction_to(point_b)
	step(point_a)
	var next_tile = (point_a + dir_to_point_b * STEP_SIZE).round()
	while next_tile != point_b:
		dir_to_point_b = next_tile.direction_to(point_b)
		step(next_tile, dir_to_point_b)
		next_tile = (next_tile + dir_to_point_b * STEP_SIZE).round()
		if next_tile.distance_to(point_b) < STEP_SIZE:
			break
	step(point_b)

func step(tile_pos : Vector2, direction : Vector2 = Vector2.ZERO) -> void:
	# Places a 5x6 region of tiles at the given position, where the tiles should be
	#  f f f f f
	#  f w w w f Where w is a wall and 0 is a floor, p is a path, and f is forbidden. The tile is placed centered on the
	#  f 0 P 0 f
	#  f P P P f The tile is placed centered on the center P <---
	#  f 0 P 0 f
	#  f f f f f
	_set_floor_tiles(tile_pos, direction)
	_set_wall_tiles(tile_pos)

func _set_floor_tiles(pos : Vector2, direction : Vector2 = Vector2.ZERO) -> void:
	if direction == Vector2.ZERO:
		_set_floor_tiles_with_center_path(pos)
	else:
		_set_directional_path(pos, direction)

func _set_floor_tiles_with_center_path(pos : Vector2) -> void:
	_set_floor_tile(pos + Vector2(-1, -1), floor_tile_id)
	_set_floor_tile(pos + Vector2(0, -1), path_tile_id)
	_set_floor_tile(pos + Vector2(1, -1), floor_tile_id)
	_set_floor_tile(pos + Vector2(-1, 0), path_tile_id)
	_set_floor_tile(pos + Vector2(0, 0), path_tile_id)
	_set_floor_tile(pos + Vector2(1, 0), path_tile_id)
	_set_floor_tile(pos + Vector2(-1, 1), floor_tile_id)
	_set_floor_tile(pos + Vector2(0, 1), path_tile_id)
	_set_floor_tile(pos + Vector2(1, 1), floor_tile_id)

func _set_directional_path(pos : Vector2, dir : Vector2) -> void:
	dir = dir.normalized()
	var is_vertical = true if abs(dir.y) > 0.15 else false
	var is_up = true if dir.y < -0.15 else false
	var is_down = true if dir.y > 0.15 else false
	var is_left = true if dir.x < -0.15 else false
	var is_right = true if dir.x > 0.15 else false
	if not is_vertical:
		_set_side_path(pos)
	elif (is_up and is_right) or (is_down and is_left):
		_set_cross_left_down(pos)
	elif (is_up and is_left) or (is_down and is_right):
		_set_cross_right_down(pos)
	elif is_vertical:
		_set_vertical_path(pos)
	else:
		_set_floor_tiles_with_center_path(pos)

func _set_side_path(pos : Vector2) -> void:
	_set_floor_tile(pos + Vector2(-1, -1), floor_tile_id)
	_set_floor_tile(pos + Vector2(0, -1), floor_tile_id)
	_set_floor_tile(pos + Vector2(1, -1), floor_tile_id)
	_set_floor_tile(pos + Vector2(-1, 0), path_tile_id)
	_set_floor_tile(pos + Vector2(0, 0), path_tile_id)
	_set_floor_tile(pos + Vector2(1, 0), path_tile_id)
	_set_floor_tile(pos + Vector2(-1, 1), floor_tile_id)
	_set_floor_tile(pos + Vector2(0, 1), floor_tile_id)
	_set_floor_tile(pos + Vector2(1, 1), floor_tile_id)

func _set_vertical_path(pos : Vector2) -> void:
	_set_floor_tile(pos + Vector2(-1, -1), floor_tile_id)
	_set_floor_tile(pos + Vector2(0, -1), path_tile_id)
	_set_floor_tile(pos + Vector2(1, -1), floor_tile_id)
	_set_floor_tile(pos + Vector2(-1, 0), floor_tile_id)
	_set_floor_tile(pos + Vector2(0, 0), path_tile_id)
	_set_floor_tile(pos + Vector2(1, 0), floor_tile_id)
	_set_floor_tile(pos + Vector2(-1, 1), floor_tile_id)
	_set_floor_tile(pos + Vector2(0, 1), path_tile_id)
	_set_floor_tile(pos + Vector2(1, 1), floor_tile_id)

func _set_cross_right_down(pos : Vector2) -> void:
	_set_floor_tile(pos + Vector2(-1, -1), path_tile_id)
	_set_floor_tile(pos + Vector2(0, -1), floor_tile_id)
	_set_floor_tile(pos + Vector2(1, -1), floor_tile_id)
	_set_floor_tile(pos + Vector2(-1, 0), floor_tile_id)
	_set_floor_tile(pos + Vector2(0, 0), path_tile_id)
	_set_floor_tile(pos + Vector2(1, 0), floor_tile_id)
	_set_floor_tile(pos + Vector2(-1, 1), floor_tile_id)
	_set_floor_tile(pos + Vector2(0, 1), floor_tile_id)
	_set_floor_tile(pos + Vector2(1, 1), path_tile_id)

func _set_cross_left_down(pos : Vector2) -> void:
	_set_floor_tile(pos + Vector2(-1, -1), floor_tile_id)
	_set_floor_tile(pos + Vector2(0, -1), floor_tile_id)
	_set_floor_tile(pos + Vector2(1, -1), path_tile_id)
	_set_floor_tile(pos + Vector2(-1, 0), floor_tile_id)
	_set_floor_tile(pos + Vector2(0, 0), path_tile_id)
	_set_floor_tile(pos + Vector2(1, 0), floor_tile_id)
	_set_floor_tile(pos + Vector2(-1, 1), path_tile_id)
	_set_floor_tile(pos + Vector2(0, 1), floor_tile_id)
	_set_floor_tile(pos + Vector2(1, 1), floor_tile_id)

func _set_wall_tiles(pos : Vector2) -> void:
	_set_wall_tile(pos + Vector2(-1, -2))
	_set_wall_tile(pos + Vector2(0, -2))
	_set_wall_tile(pos + Vector2(1, -2))
	_set_forbidden_tile(pos + Vector2(-2, -3))
	_set_forbidden_tile(pos + Vector2(2, -3))
	_set_forbidden_tile(pos + Vector2(-2, -2))
	_set_forbidden_tile(pos + Vector2(2, -2))
	_set_forbidden_tile(pos + Vector2(-2, -1))
	_set_forbidden_tile(pos + Vector2(2, -1))
	_set_forbidden_tile(pos + Vector2(-2, 0))
	_set_forbidden_tile(pos + Vector2(2, 0))
	_set_forbidden_tile(pos + Vector2(-2, 1))
	_set_forbidden_tile(pos + Vector2(2, 1))
	_set_forbidden_tile(pos + Vector2(-2, 2))
	_set_forbidden_tile(pos + Vector2(-1, 2))
	_set_forbidden_tile(pos + Vector2(0, 2))
	_set_forbidden_tile(pos + Vector2(1, 2))
	_set_forbidden_tile(pos + Vector2(2, 2))

func _set_floor_tile(pos : Vector2, tile_id : int) -> void:
	var current_id = floor_tile_map.get_cell_source_id(0, pos)
	if current_id != path_tile_id:
		floor_tile_map.set_cell(0, pos, tile_id, Vector2i.ZERO)
	wall_tile_map.set_cell(0, pos, -1, Vector2i.ZERO)

func _set_wall_tile(pos : Vector2) -> void:
	if _can_wall_be_placed(pos):
		wall_tile_map.set_cell(0, pos, wall_tile_id, Vector2i.ZERO)
		wall_tile_map.set_cell(0, pos + Vector2(0, -1), forbidden_tile_id, Vector2i.ZERO)

func _can_wall_be_placed(pos : Vector2) -> bool:
	var tile_id = floor_tile_map.get_cell_source_id(0, pos)
	var tile_above_id = floor_tile_map.get_cell_source_id(0, pos + Vector2(0, -1))
	if tile_id == floor_tile_id or tile_id == path_tile_id or tile_above_id == floor_tile_id or tile_above_id == path_tile_id:
		return false
	return true

func _set_forbidden_tile(pos : Vector2) -> void:
	if _can_forbidden_tile_be_placed(pos):
		wall_tile_map.set_cell(0, pos, forbidden_tile_id, Vector2i.ZERO)

func _can_forbidden_tile_be_placed(pos : Vector2) -> bool:
	var tile_id = floor_tile_map.get_cell_source_id(0, pos)
	var tile_below = floor_tile_map.get_cell_source_id(0, pos + Vector2(0, 1))
	if tile_id == floor_tile_id or tile_id == path_tile_id or tile_below == floor_tile_id or tile_below == path_tile_id:
		return false
	return true
