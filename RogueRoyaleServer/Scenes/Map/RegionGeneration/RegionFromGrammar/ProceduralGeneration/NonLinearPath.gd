extends RefCounted
class_name NonLinearRegionPathBuilder

var excluded_rects : Array
var path : Array
var tile_map : TileMap
var map_rid : RID
var tile_size_vec = Vector2.ONE * ProjectSettings.get_setting("global/TILE_SIZE")
var half_tile_vec = tile_size_vec / 2.0
var PATH_HALF_WIDTH = 3

func init(new_tile_map : TileMap, new_map_rid : RID) -> void:
	tile_map = new_tile_map
	map_rid = new_map_rid

func build_along(new_path : Array) -> void:
	var line_seg = LineSegment.new()
	var n_point_pairs = new_path.size() - 1
	for i in range(n_point_pairs):
		var a_tile = tile_map.local_to_map(new_path[i])
		var b_tile = tile_map.local_to_map(new_path[i + 1])
		line_seg.init(a_tile, b_tile)
		#line_seg.init(new_path[i], new_path[i + 1])
		place_line_in_tiles(line_seg)

func place_line_in_tiles(line_segment : LineSegment) -> void:
	var min_x = min(line_segment.point_a.x, line_segment.point_b.x)
	var max_x = max(line_segment.point_a.x, line_segment.point_b.x)
	var min_y = min(line_segment.point_a.y, line_segment.point_b.y)
	var max_y = max(line_segment.point_a.y, line_segment.point_b.y)
	if abs(line_segment.line_equation[0]) < abs(line_segment.line_equation[1]):
		_set_cells_by_walking_x(line_segment.line_equation, min_x, max_x)
	else:
		_set_cells_by_walking_y(line_segment.line_equation, min_y, max_y)
	tile_map.update_bitmask_region()

func _set_cells_by_walking_x(line_eq : Array, min_x, max_x) -> void:
	for x in range(min_x, max_x):
		var y = -(line_eq[2] + line_eq[0] * x) / line_eq[1]
		#tile_map.set_cell(x, y, tile_id)
		#for i in range(1, PATH_HALF_WIDTH):
		#	tile_map.set_cell(x, y + i, tile_id)
		#	tile_map.set_cell(x, y - i, tile_id)
		_place_tile_at(Vector2(x, y + PATH_HALF_WIDTH))
		_place_tile_at(Vector2(x, y - PATH_HALF_WIDTH))

func _set_cells_by_walking_y(line_eq : Array, min_y, max_y) -> void:
	for y in range(min_y, max_y):
		var x = -(line_eq[2] + line_eq[1] * y) / line_eq[0]
		# tile_map.set_cell(x, y, tile_id)
		# for i in range(1, PATH_HALF_WIDTH):
		# 	tile_map.set_cell(x + i, y, tile_id)
		# 	tile_map.set_cell(x - i, y, tile_id)
		_place_tile_at(Vector2(x + PATH_HALF_WIDTH, y))
		_place_tile_at(Vector2(x - PATH_HALF_WIDTH, y))

func _place_tile_at(tile_pos : Vector2) -> void:
	# Check to see if the closest point on the navpoly is the same as point. If not, do not set a tile.
	# We should probably also shift the point to the center of the tile, and convert it to global space instead of grid space
	var global_pos = tile_map.map_to_local(tile_pos)
	var closest_point = NavigationServer2D.map_get_closest_point(map_rid, global_pos)
	if is_equal_approx(closest_point.distance_squared_to(global_pos), 0):
		#var tile_pos = tile_map.local_to_map(global_pos)
		tile_map.set_cellv(0, tile_pos, 0, Vector2i.ZERO)

