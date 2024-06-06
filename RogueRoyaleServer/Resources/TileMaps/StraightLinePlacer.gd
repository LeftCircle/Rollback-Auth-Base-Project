extends Resource
class_name StraightLinePlacer

var tile_map : TileMap
var half_width : int
var tile_id

func init(new_tilemap : TileMap, path_half_width : int) -> void:
	tile_map = new_tilemap
	half_width = path_half_width

func place_line_in_tiles(line_segment : LineSegment, new_tile_id : int) -> void:
	tile_id = new_tile_id
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
		tile_map.set_cell(x, y, tile_id)
		for i in range(1, half_width):
			tile_map.set_cell(x, y + i, tile_id)
			tile_map.set_cell(x, y - i, tile_id)

func _set_cells_by_walking_y(line_eq : Array, min_y, max_y) -> void:
	for y in range(min_y, max_y):
		var x = -(line_eq[2] + line_eq[1] * y) / line_eq[0]
		tile_map.set_cell(x, y, tile_id)
		for i in range(1, half_width):
			tile_map.set_cell(x + i, y, tile_id)
			tile_map.set_cell(x - i, y, tile_id)
