extends Resource
class_name PolygonFiller

const DIRECTIONS = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]

var tile_map : TileMap
var nav2D : Navigation2D
var nav_poly : NavigationPolygon
var TILE_SIZE = ProjectSettings.get_setting("global/TILE_SIZE")
var WORLD_DIRECTIONS = [
	Vector2(0, TILE_SIZE),
	Vector2(0, -TILE_SIZE),
	Vector2(TILE_SIZE, 0),
	Vector2(-TILE_SIZE, 0)
]

func init(tilemap : TileMap, nav2d, navpoly) -> void:
	tile_map = tilemap
	nav2D = nav2d
	nav_poly = navpoly

func fill_nav2D_world_to_tiles(tile_id : int) -> void:
	var inner_tiles = []
	var tile_snap = Vector2(TILE_SIZE, TILE_SIZE)
	var world_pos_to_check = _get_starting_world_positions()
	while not world_pos_to_check.is_empty():
		var world_pos = world_pos_to_check.pop_back()
		var tile = world_pos.snapped(tile_snap) / TILE_SIZE
		if tile in inner_tiles:
			continue
		var closest_point = nav2D.get_closest_point(world_pos)
		if not closest_point == world_pos:
			continue
		inner_tiles.append(tile)
		tile_map.set_cellv(tile - Vector2.ONE, tile_id)
		for dir in WORLD_DIRECTIONS:
			var next_world_pos = world_pos + dir
			if not next_world_pos.snapped(tile_snap) / TILE_SIZE in inner_tiles:
				world_pos_to_check.append(next_world_pos)
	tile_map.update_bitmask_region()

func _get_starting_world_positions() -> Array:
	#var starting_point = polygon[0]
	var starting_point = nav_poly.get_vertices()[0]
	if int(starting_point.x) % TILE_SIZE == 0:
		starting_point.x += TILE_SIZE / 2
	if int(starting_point.y) % TILE_SIZE == 0:
		starting_point.y += TILE_SIZE / 2
	var tiles = [starting_point]
	for dir in WORLD_DIRECTIONS:
		tiles.append(starting_point + dir)
	return tiles
