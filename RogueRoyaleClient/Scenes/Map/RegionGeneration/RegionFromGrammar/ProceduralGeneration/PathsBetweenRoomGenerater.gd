extends Node2D
class_name PathBetweenRoomGenerater

signal paths_completed()

const PATH_HALF_WIDTH = 3

# Is a node so must be freed
#onready var nav_agent = $CharacterBody2D/NavigationAgent2D
var region_rect : Rect2
var rect_array : Array
var rect_array_tiles : Array
var rooms : Array
var doors : Array
var door_pairs : Dictionary
var map : RID
var path_walker = PathWalker.new()
var tile_clearer = TileClearer.new()
var TILE_SIZE = ProjectSettings.get_setting("global/TILE_SIZE")
var floor_tile_map : TileMap
var wall_tile_map : TileMap

@onready var nav_poly_inst = $NavPoly

func init(new_rooms : Array, new_doors : Array, new_floor_tile_map : TileMap, new_wall_tile_map : TileMap) -> void:
	floor_tile_map = new_floor_tile_map
	wall_tile_map = new_wall_tile_map
	doors = new_doors
	_build_door_pairs(doors)
	rooms = new_rooms
	region_rect = Map.get_rect2_around_rooms(rooms)
	rect_array = Map.get_border_rect2_array(rooms)
	rect_array_tiles = Map.get_border_rect2_array_tiles(rooms)
	_build_nav_poly(region_rect, rect_array)
	_init_nav_map()
	#path_walker.init(tile_map, 1, 0)

func _build_door_pairs(doors_array : Array) -> void:
	for door in doors_array:
		var connected_doors = door.get_connected_doors()
		for connected_door in connected_doors:
			if door_pairs.has(door) and door_pairs[door].has(connected_door):
				continue
			if door_pairs.has(connected_door) and door_pairs[connected_door].has(door):
				continue
			if not door_pairs.has(door):
				door_pairs[door] = []
			door_pairs[door].append(connected_door)

func _init_nav_map() -> void:
	map = NavigationServer2D.map_create()
	NavigationServer2D.region_set_map(nav_poly_inst.get_region_rid(), map)
	NavigationServer2D.map_force_update(map)

func generate_paths() -> void:# : RegionFromGrammar) -> void:
	connect_doors()
	_clear_tiles_from_rects()
	path_walker.floor_tile_map.spawn_voronoi_tiles()
	path_walker.wall_tile_map.spawn_voronoi_tiles()
	emit_signal("paths_completed")

func _build_nav_poly(outer_rect : Rect2, forbidden_rects : Array) -> void:
	outer_rect = outer_rect.grow(PATH_HALF_WIDTH * TILE_SIZE * 4)
	var region_vertices = _build_polygon_from_rect(outer_rect)
	nav_poly_inst.navpoly.add_outline(region_vertices)
	_exclude_rects_from_nav_poly(forbidden_rects)
	nav_poly_inst.navpoly.make_polygons_from_outlines()
	# If the navigation polygon is not reset, then it fails to work
	nav_poly_inst.enabled = false
	nav_poly_inst.enabled = true

func _exclude_rects_from_nav_poly(forbidden_rects : Array) -> void:
	for rect in forbidden_rects:
		var extended_rect = rect.grow(TILE_SIZE)
		var rect_poly = _build_polygon_from_rect(extended_rect)
		nav_poly_inst.navpoly.add_outline(rect_poly)

func _build_polygon_from_rect(rect2 : Rect2) -> PackedVector2Array:
	var polygon = PackedVector2Array()
	polygon.append(rect2.position)
	polygon.append(rect2.position + Vector2(rect2.size.x, 0))
	polygon.append(rect2.end)
	polygon.append(rect2.position + Vector2(0, rect2.size.y))
	return polygon

func connect_doors():
	var paths_bewtween_rooms = _get_paths_between_doors()
	_place_tiles_on_paths(paths_bewtween_rooms)
	#var paths_around_rooms = _generate_paths_surrounding_rooms()
	#_place_tiles_on_paths(paths_around_rooms)

func _get_paths_between_doors() -> Array:
	var paths = []
	for door in door_pairs.keys():
		for connected_door in door_pairs[door]:
			_generate_path_between_points(door.get_center(), connected_door.get_center(), paths)
	return paths

# func _generate_paths_surrounding_rooms() -> Array:
# 	var paths = []
# 	for room in rooms:
# 		var doors = room.get_doors()
# 		var used_doors = []
# 		for door in doors:
# 			if door in used_doors:
# 				continue
# 			var closest_door = room.get_closest_door_to(door)
# 			used_doors.append(door)
# 			_generate_path_between_points(door.get_center(), closest_door.get_center(), paths)
# 			_connect_doors(door, closest_door)
# 	return paths

func _generate_path_between_points(start : Vector2, end : Vector2, path_array : Array) -> void:
	var closest_start = NavigationServer2D.map_get_closest_point(map, start)
	var closest_end = NavigationServer2D.map_get_closest_point(map, end)
	var path = NavigationServer2D.map_get_path(map, closest_start, closest_end, true)
	if path.size() > 0:
		path_array.append(Array(path))

func _place_tiles_on_paths(paths : Array) -> void:
	for path in paths:
		#non_linear_path_builder.build_along(path)
		path_walker.build_along(path)

func _clear_tiles_from_rects():
	for forbidden_rect in rect_array_tiles:
		tile_clearer.clear_tiles_in_rect(floor_tile_map, wall_tile_map, forbidden_rect)
