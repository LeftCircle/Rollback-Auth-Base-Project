extends Resource
class_name NonRoomTiles
# Casts rays through the rect2 around a region, and finds all of the tiles
# that are not currently in a room

var tile_map
var region
var region_rect2_tiles
var left_intersections_x
var right_intersections_x
var region_line_seg = LineSegment.new()
var non_room_tiles = []
var noise = OpenSimplexNoise.new()
var threshold = [-0.05, 0.5]
var placed = 0
var unplaced = 0

func init(new_region) -> void:
	region = new_region
	region_rect2_tiles = region.get_region_rect2_tiles()
	region_rect2_tiles.grow(10)
	tile_map = region.region_filler_tilemap

func _ready():
	noise.seed = WorldState.map_rng.randi()
	noise.lacunarity = 3
	noise.octaves = 3
	noise.period = 31.892
	noise.persistence = 0.5

func build_non_room_tiles_array():
	for y in range(region_rect2_tiles.position.y, region_rect2_tiles.end.y):
		y += 0.5
		region_line_seg.init(Vector2(region_rect2_tiles.position.x, y),
							Vector2(region_rect2_tiles.end.x, y))
		left_intersections_x = []
		right_intersections_x = []
		_get_room_intersections()
		if not left_intersections_x.is_empty():
			_walk_region_edges(y)
			_walk_room_intersections(y)
		else:
			for x in range(region_line_seg.point_a.x, region_line_seg.point_b.x):
				non_room_tiles.append(Vector2(x, y))
				_set_cells_if_noise_allows(x, y, 0)
	return non_room_tiles

func _get_room_intersections():
	for node in region.grammar_data.LHS_nodes:
		var border_rect = node.room_scene.border_rect2_extended_tiles
		var left_inter = border_rect.left_line.get_intersection(region_line_seg)
		if left_inter and not left_inter == border_rect.left_line.point_b:
			var right_inter = border_rect.right_line.get_intersection(region_line_seg)
			left_intersections_x.append(left_inter.x)
			right_intersections_x.append(right_inter.x)
	left_intersections_x.sort()
	right_intersections_x.sort()

func _walk_room_intersections(y):
	var n_intersections = left_intersections_x.size()
	for i in range(n_intersections):
		for x in range(right_intersections_x[i], left_intersections_x[i]):
			_add_non_room_tile_and_set_cell(x, y)

func _walk_region_edges(y):
	for x in range(region_line_seg.point_a.x, left_intersections_x[0]):
		_add_non_room_tile_and_set_cell(x, y)
	for x in range(right_intersections_x[-1], region_line_seg.point_b.x):
		_add_non_room_tile_and_set_cell(x, y)
	left_intersections_x.pop_front()
	right_intersections_x.pop_back()

func _add_non_room_tile_and_set_cell(x, y):
	non_room_tiles.append(Vector2(x, y))
	_set_cells_if_noise_allows(x, y, 0)

func _set_cells_if_noise_allows(x : int, y : int, tile_id) -> void:
	var noise_value = noise.get_noise_2d(x, y)
	if threshold[0] < noise_value and noise_value <= threshold[1]:
		tile_map.set_cell(x, y, tile_id)
		placed += 1
	else:
		unplaced += 1


