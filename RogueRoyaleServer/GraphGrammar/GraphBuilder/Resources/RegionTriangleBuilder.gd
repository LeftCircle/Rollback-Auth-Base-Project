extends Resource
class_name RegionTriangleBuilder

var region_triangles : Array
var region_nodes : Array
var nodes_not_in_trianlges : Array
var closest_point_finder = ClosestPointFinder.new()
var new_region_triangles : Array
var max_attempts = 300
var attempts = 0
var min_distance

func init(nodes : Array) -> void:
	region_nodes = nodes

func build_triangles():
	_set_starting_arrays()
	_build_first_trianlge()
	#while not nodes_not_in_trianlges.is_empty():
	_build_remaining_triangles()

func _build_remaining_triangles():
	while _triangle_with_points_above_exists():
		new_region_triangles = []
		for triangle in region_triangles:
			if not triangle.edges_with_points_above.is_empty():
				_build_neighboring_trianlges(triangle)
		region_triangles.append_array(new_region_triangles)

func build_triangles_from_graph(graph_nodes : Array, graph_springs : Array) -> void:
	# Start by creating partial triangles from all of the node connections,
	# Then filling out the third point of each partial triangle
	_set_starting_arrays()
	var partial_triangles = []
	for spring in graph_springs:
		var partial_t = RegionTriangle.new()
		partial_t.init_two_points(spring.g_node_a, spring.g_node_b)
		partial_triangles.append(partial_t)
	# Build each of the partial triangles
	_build_partial_triangles(partial_triangles, graph_nodes, graph_springs)
	_build_remaining_triangles()
	_build_triangle_neighbor_arrays()

func _build_partial_triangles(partial_tirangles, graph_nodes : Array, springs : Array) -> void:
	for partial_t in partial_tirangles:
		var nodes_to_search = graph_nodes.duplicate(true)
		nodes_to_search.erase(partial_t.triangle[0])
		nodes_to_search.erase(partial_t.triangle[1])
		while not nodes_to_search.is_empty():
			var s0 = partial_t.triangle[0].position
			var s1 = partial_t.triangle[1].position
			var closest_node = closest_point_finder.find_closest_node_to_segment(s0, s1, nodes_to_search)
			var discounted_nodes = [partial_t.triangle[0], partial_t.triangle[1], closest_node]
			var intersects_spring = false
			for spring in springs:
				if spring.g_node_a in discounted_nodes or spring.g_node_b in discounted_nodes:
					continue
				else:
					var spring_point_a = spring.g_node_a.position
					var spring_point_b = spring.g_node_b.position
					if Geometry.segment_intersects_segment(s0, closest_node.position, spring_point_a, spring_point_b):
						nodes_to_search.erase(closest_node)
						intersects_spring = true
						break
					elif Geometry.segment_intersects_segment(s1, closest_node.position, spring_point_a, spring_point_b):
						nodes_to_search.erase(closest_node)
						intersects_spring = true
						break
			if intersects_spring:
				continue
			var intersects_0 = _new_segment_intersects_triangles(closest_node.position, s0)
			var intersects_1 = _new_segment_intersects_triangles(closest_node.position, s1)
			# We also have to confirm that the new triangle doesn't overlap any of the springs!
			if not intersects_0 and not intersects_1:
				partial_t.init(partial_t.triangle[0], partial_t.triangle[1], closest_node)
				if _triangle_already_exists(partial_t):
					break
				region_triangles.append(partial_t)
				break
			else:
				nodes_to_search.erase(closest_node)
			
func _set_starting_arrays():
	region_triangles.clear()
	nodes_not_in_trianlges = region_nodes.duplicate(true)

func _build_first_trianlge():
	var current_node = region_nodes[-1]
	var node_b = _get_closest_node_not_in_triangles(current_node)
	var node_c = closest_point_finder.find_closest_node_to_segment(current_node.position, node_b.position, nodes_not_in_trianlges)
	#var node_c = _get_closest_node_not_in_triangles(current_node)
	nodes_not_in_trianlges.erase(current_node)
	nodes_not_in_trianlges.erase(node_b)
	nodes_not_in_trianlges.erase(node_c)
	var triangle = RegionTriangle.new()
	triangle.init(current_node, node_b, node_c)
	region_triangles.append(triangle)

func _get_closest_node_not_in_triangles(node):
	var closest_node = closest_point_finder.find_closest_node_to(node, nodes_not_in_trianlges)
	nodes_not_in_trianlges.erase(closest_node)
	return closest_node

func _triangle_with_points_above_exists():
	for triangle in region_triangles:
		if not triangle.edges_with_points_above.is_empty():
			return true
	return false

func _build_neighboring_trianlges(triangle):
	for i in range(triangle.edges_with_points_above.size()-1, -1, -1):
		var nodes_above = triangle.get_nodes_above_edge(triangle.edges_with_points_above[i], region_nodes)
		var edge_nodes = triangle.get_nodes_for_edge(triangle.edges_with_points_above[i])
		while not nodes_above.is_empty():
			var closest_node = closest_point_finder.find_closest_node_to_segment(edge_nodes[0].position, edge_nodes[1].position, nodes_above)
			var intersects_0 = _new_segment_intersects_triangles(closest_node.position, edge_nodes[0].position)
			var intersects_1 = _new_segment_intersects_triangles(closest_node.position, edge_nodes[1].position)
			if intersects_0 or intersects_1:
				nodes_above.erase(closest_node)
				continue
			else:
				nodes_not_in_trianlges.erase(closest_node)
				_build_new_triangle_on(triangle, triangle.edges_with_points_above[i], closest_node)
				triangle.edges_with_points_above.erase(triangle.edges_with_points_above[i])
				break
		if nodes_above.is_empty():
			triangle.edges_with_points_above.erase(triangle.edges_with_points_above[i])


func _new_segment_intersects_triangles(s0, s1) -> bool:
	var all_triangles = region_triangles + new_region_triangles
	for triangle in all_triangles:
		if triangle.segment_intersects(s0, s1):
			return true
	return false

#func _new_triangle_intersects_others(new_triangle) -> bool:
#	var all_triangles = region_triangles + new_region_triangles
#	for triangle in all_triangles:
#		if triangle.intersects_triangle(new_triangle):
#			return true
#	return false

func _build_new_triangle_on(triangle, edge : int, closest_node):
	var new_triangle = RegionTriangle.new()
	var edge_nodes = triangle.get_nodes_for_edge(edge)
	new_triangle.init(edge_nodes[1], edge_nodes[0], closest_node)
	if _triangle_already_exists(new_triangle):
		return
	new_triangle.edges_with_points_above.erase(new_triangle.get_edge_for_nodes(edge_nodes[0], edge_nodes[1]))
	new_triangle.neighboring_triangles.append(triangle)
	triangle.neighboring_triangles.append(new_triangle)
	new_region_triangles.append(new_triangle)

func _triangle_already_exists(new_triangle) -> bool:
	var all_triangles = region_triangles + new_region_triangles
	for triangle in all_triangles:
		if triangle.matches_triangle(new_triangle):
			return true
	return false

# Expand the smallest triangle. Then grab the neighboring triangles
# and expand/reposition the triangles to fit with the smallest one. 
# Continue until all triangles have been expanded. 
func grow_triangles(new_min_distance : float) -> void:
	for triangle in region_triangles:
		triangle.grown = false
	min_distance = new_min_distance
	var shortest_edged_triangle = _get_shortest_edged_triangle()
	var shortest_size = shortest_edged_triangle.get_size_of_smallest_edge()
	var percent_growth = min_distance / shortest_size
	if percent_growth > 1:
		shortest_edged_triangle.grow_triangle(percent_growth)
		var grown_triangles = [shortest_edged_triangle]
		while not grown_triangles.is_empty():
			var current_triangle = grown_triangles.pop_back()
			var newly_grown = _grow_and_return_neighbors(current_triangle, percent_growth)
			grown_triangles.append_array(newly_grown)

func grow_triangles_by_percent(percent_growth : float) -> void:
	for triangle in region_triangles:
		triangle.grown = false
	region_triangles[0].grow_triangle(percent_growth)
	var grown_triangles = [region_triangles[0]]
	while not grown_triangles.is_empty():
		var current_triangle = grown_triangles.pop_back()
		var newly_grown = _grow_and_return_neighbors(current_triangle, percent_growth)
		grown_triangles.append_array(newly_grown)

func _grow_and_return_neighbors(triangle, percent_growth):
	var newly_grown_neighbors = []
	for neighbor in triangle.neighboring_triangles:
		if not neighbor.grown:
			neighbor.grow_and_reposition_to_expanded(percent_growth, triangle)
			newly_grown_neighbors.append(neighbor)
	return newly_grown_neighbors

func _get_shortest_edged_triangle() -> RegionTriangle:
	var shortest_edge = INF
	var shortest_triangle : RegionTriangle
	for triangle in region_triangles:
		var t_shortest = triangle.get_size_of_smallest_edge()
		if t_shortest < shortest_edge:
			shortest_edge = t_shortest
			shortest_triangle = triangle
			shortest_triangle = triangle
	return shortest_triangle

func get_triangle_that_contains_point(point) -> RegionTriangle:
	for triangle in region_triangles:
		if triangle.contains_point(point):
			return triangle
	return null

func _build_triangle_neighbor_arrays():
	var n_triangles = region_triangles.size()
	for i in range(n_triangles - 1):
		for j in range(i + 1, n_triangles):
			var triangle_i = region_triangles[i]
			var triangle_j = region_triangles[j]
			if triangle_i.is_neighbor(triangle_j):
				if not triangle_i in triangle_j.neighboring_triangles:
					triangle_j.neighboring_triangles.append(triangle_i)
				if not triangle_j in triangle_i.neighboring_triangles:
					triangle_i.neighboring_triangles.append(triangle_j)

func get_triangles_with_edge(node_a, node_b):
	var triangles_with_edge = []
	for triangle in region_triangles:
		if triangle.has_edge(node_a, node_b):
			triangles_with_edge.append(triangle)
	return triangles_with_edge
