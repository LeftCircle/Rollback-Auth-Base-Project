extends Node2D
class_name PathBetweenRoomGenerator

const PATH_HALF_WIDTH = 3

# Is a node so must be freed
#onready var nav_agent = $CharacterBody2D/NavigationAgent2D
var forbidden_rects_tiles : Array
var region
var map : RID
var non_linear_path_builder = NonLinearRegionPathBuilder.new()
var path_walker = PathWalker.new()
var tile_map : TileMap
var tile_clearer = TileClearer.new()
var TILE_SIZE = ProjectSettings.get_setting("global/TILE_SIZE")
var rooms : Array

@onready var nav_poly_inst = $NavPoly

func init(region_rect : Rect2, new_forbidden_rects : Array, new_tile_map : TileMap, new_forbidden_rects_tiles : Array, room_scenes : Array) -> void:
	tile_map = new_tile_map
	rooms = room_scenes
	forbidden_rects_tiles = new_forbidden_rects_tiles
	_build_nav_poly(region_rect, new_forbidden_rects)
	_init_nav_map()
	non_linear_path_builder.init(tile_map, map)
	path_walker.init(tile_map, 2, 0)

func _init_nav_map() -> void:
	map = NavigationServer2D.map_create()
	NavigationServer2D.region_set_map(nav_poly_inst.get_region_rid(), map)
	NavigationServer2D.map_force_update(map)

func generate_paths(new_region) -> void:# : RegionFromGrammar) -> void:
	region = new_region
	connect_doors()
	_clear_tiles_from_rects()

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
	var paths_around_rooms = _generate_paths_surrounding_rooms()
	_place_tiles_on_paths(paths_around_rooms)

func _get_paths_between_doors() -> Array:
	var paths = []
	for spring in region.grammar_data.LHS_springs:
		var door_pair = spring.g_node_a.room_scene.get_closest_door_pair_to(spring.g_node_b.room_scene)
		_connect_doors(door_pair[0], door_pair[1])
		_generate_path_between_points(door_pair[0].get_center(), door_pair[1].get_center(), paths)
		#var new_line = Line2D.new()
		#new_line.width = 10
		#new_line.points = paths[-1]
		#add_child(new_line)
	return paths

func _connect_doors(door_a, door_b) -> void:
	door_a.add_connected_door(door_b)
	door_b.add_connected_door(door_a)

func _generate_paths_surrounding_rooms() -> Array:
	var paths = []
	for room in rooms:
		var doors = room.get_doors()
		var used_doors = []
		for door in doors:
			if door in used_doors:
				continue
			var closest_door = room.get_closest_door_to(door)
			used_doors.append(door)
			_generate_path_between_points(door.get_center(), closest_door.get_center(), paths)
			_connect_doors(door, closest_door)
	return paths

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
	for forbidden_rect in forbidden_rects_tiles:
		tile_clearer.clear_tiles_in_rect(tile_map, forbidden_rect)
