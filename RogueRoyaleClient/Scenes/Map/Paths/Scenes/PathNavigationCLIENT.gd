extends Node2D

#var region
##var nav_polygon = NavigationPolygon.new()
#@onready var nav_poly_instance = $NavigationRegion2D
#
#func _ready():
#	nav_poly_instance.navpoly = NavigationPolygon.new()
#
#func build_navigation_polygon(region_node):
#	region = region_node
#	var region_rect = region.get_region_rect2()
#	# If the rect isn't grown, the navigation polygon doesn't know how to
#	# exclude the rooms on the border
#	region_rect = region_rect.grow(128)
#	var region_vertices = _build_polygon_from_rect(region_rect)
#	nav_poly_instance.navpoly.add_outline(region_vertices)
#	_exclude_room_polygons_from(nav_poly_instance.navpoly)
#	nav_poly_instance.navpoly.make_polygons_from_outlines()
#	# If the navigation polygon is not reset, then it fails to work
#	nav_poly_instance.enabled = false
#	nav_poly_instance.enabled = true
#
#func _build_polygon_from_rect(rect2 : Rect2) -> PackedVector2Array:
#	var polygon = PackedVector2Array()
#	polygon.append(rect2.position)
#	polygon.append(rect2.position + Vector2(rect2.size.x, 0))
#	polygon.append(rect2.end)
#	polygon.append(rect2.position + Vector2(0, rect2.size.y))
#	return polygon
#
#func _exclude_room_polygons_from(poly):
#	for node_n in region.grammar_data.rooms:
#		var room_scene = region.grammar_data.rooms[node_n]
#		var room_poly = _build_polygon_from_rect(room_scene.border_rect2)
#		poly.add_outline(room_poly)
#
#func connect_doors():
#	var paths = _get_paths_between_doors()
#	_place_tiles_on_paths(paths)
#
#func _get_paths_between_doors() -> Array:
#	var paths = []
#	for spring in region.grammar_data.springs:
#		var new_line = Line2D.new()
#		new_line.width = 100
#		var a_local = to_local(spring.door_a.get_door_center_on_room_global())
#		var b_local = to_local(spring.door_b.get_door_center_on_room_global())
#		var path = get_simple_path(a_local, b_local)
#		paths.append(path)
#		new_line.points = path
#		add_child(new_line)
#	return paths
#
#func _place_tiles_on_paths(paths : Array) -> void:
#	var straight_line_placer = StraightLinePlacer.new()
#	var tmap = region.region_filler_tilemap
#	straight_line_placer.init(tmap, 8)
#	for path in paths:
#		# Break the path up into line segments
#		var loop_size = path.size() - 1
#		for i in range(loop_size):
#			var line_seg = LineSegment.new()
#			var a_tile = tmap.local_to_map(path[i])
#			var b_tile = tmap.local_to_map(path[i + 1])
#			line_seg.init(a_tile, b_tile)
#			straight_line_placer.place_line_in_tiles(line_seg, -1)
#
#func queue_navigation_free():
#	queue_free()
