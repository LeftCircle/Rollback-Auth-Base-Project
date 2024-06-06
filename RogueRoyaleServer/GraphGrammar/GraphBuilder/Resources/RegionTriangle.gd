extends Resource
class_name RegionTriangle


#var triangle : PackedVector2Array
var triangle : Array
var edges_with_points_above = [0, 1, 2]
var grown = false
var neighboring_triangles = []
var original_triangle : PackedVector2Array

func init(node_0, node_1, node_2) -> void:
	triangle = [node_0, node_1, node_2]
	if not Geometry.is_polygon_clockwise(get_polygon()):
		triangle.invert()
	original_triangle = PackedVector2Array([
		triangle[0].position,
		triangle[1].position,
		triangle[2].position
	])

func init_two_points(node_0, node_1) -> void:
	triangle = [node_0, node_1]

func add_neighboring_triangle(other_triangle : RegionTriangle) -> void:
	neighboring_triangles.append(other_triangle)

func get_polygon() -> PackedVector2Array:
	return PackedVector2Array([triangle[0].position, triangle[1].position, triangle[2].position])

func get_nodes_above_edge(edge : int, nodes_to_check : Array):
	var nodes_above = []
	for node in nodes_to_check:
		if not node in triangle:
			var new_triangle = PackedVector2Array([triangle[edge].position, triangle[(edge + 1) % 3].position, node.position])
			if not Geometry.is_polygon_clockwise(new_triangle):
					nodes_above.append(node)
	return nodes_above

func get_nodes_for_edge(edge : int) -> Array:
	return [triangle[edge], triangle[(edge + 1) % 3]]

func get_edge_for_nodes(node_0, node_1) -> int:
	for i in range(3):
		if ((triangle[i] == node_0 and triangle[(i + 1) % 3] == node_1) or 
			(triangle[i] == node_1 and triangle[(i + 1) % 3] == node_0)):
			return i
	assert(false) #,"We should never reach this point")
	return -1

func get_size_of_smallest_edge() -> float:
	var smallest_edge = INF
	for i in range(3):
		var p0 = triangle[i].position
		var p1 = triangle[(i + 1) % 3].position
		var edge_length = p0.distance_to(p1)
		if edge_length < smallest_edge:
			smallest_edge = edge_length
	return smallest_edge

func grow_triangle(percent_growth : float) -> void:
	var p0 = triangle[0].position
	var p1 = triangle[1].position
	var p2 = triangle[2].position
	triangle[1].position = (p1 - p0) * percent_growth + p0
	triangle[2].position = (p2 - p0) * percent_growth + p0
	grown = true

func grow_and_reposition_to_expanded(percent_growth : float, neighbor : RegionTriangle) -> void:
	assert(neighbor.grown == true) #,"The other triangle MUST be expanded")
	var non_shared_node = get_non_shared_node(neighbor)
	var non_shared_index = get_index_of_node(non_shared_node)
	var other_index = (non_shared_index + 1) % 3
	var og_vec = original_triangle[non_shared_index] - original_triangle[other_index]
	var new_vector = og_vec * percent_growth
	non_shared_node.position = triangle[other_index].position + new_vector
	_reset_original_triangle()
	grown = true

func _reset_original_triangle():
	original_triangle = PackedVector2Array([
		triangle[0].position,
		triangle[1].position,
		triangle[2].position
	])

func get_shared_nodes(neighbor_triangle : RegionTriangle) -> Array:
	var shared_points = []
	for i in range(3):
		for j in range(3):
			if triangle[i] == neighbor_triangle.triangle[j]:
				shared_points.append(triangle[i])
	return shared_points

func get_index_of_node(node) -> int:
	for i in range(3):
		if triangle[i] == node:
			return i
	assert(false) #,"We should never reach this point")
	return -1

func get_non_shared_node(neighbor_triangle : RegionTriangle):
	for i in range(3):
		if not triangle[i] in neighbor_triangle.triangle:
			return triangle[i]

func get_center_of_edge(edge) -> Vector2:
	var p0 = triangle[edge].position
	var p1 = triangle[(edge + 1) % 3].position
	return (p0 + p1) / 2

func segment_intersects(s0, s1) -> bool:
	for i in range(3):
		var p0 = triangle[i].position
		var p1 = triangle[(i + 1) % 3].position
		#if (s0 == p0 and s1 == p1) or (s0 == p1 and s1 == p0):
		#	continue
		if s0 == p0 or s0 == p1 or s1 == p0 or s1 == p1:
			continue
		else:
			if Geometry.segment_intersects_segment(s0, s1, p0, p1):
				return true
	return false

# Checks to see if one triangle intersects another
func intersects_triangle(other_triangle) -> bool:
	for i in range(3):
		var p0 = triangle[i].position
		var p1 = triangle[(i + 1) % 3].position
		var seg_inter = other_triangle.segment_intersects(p0, p1)
		if seg_inter:
			return true
	return false

func matches_triangle(other_triangle) -> bool:
	for i in range(3):
		if not triangle[i] in other_triangle.triangle:
			return false
	return true

func contains_point(point) -> bool:
	var p0 = triangle[0].position
	var p1 = triangle[1].position
	var p2 = triangle[2].position
	return Geometry.point_is_inside_triangle(point, p0, p1, p2)

func sides_are_greater_than(length : float) -> bool:
	var len_sq = length * length
	for i in range(3):
		var p0 = triangle[i].position
		var p1 = triangle[(i + 1) % 3].position
		var edge_length = p0.distance_squared_to(p1)
		if edge_length < len_sq:
			return false
	return true

func is_neighbor(other_triangle) -> bool:
	var shared_points = 0
	for node in triangle:
		if node in other_triangle.triangle:
			shared_points += 1
	return shared_points == 2

func has_edge(node_a, node_b) -> bool:
	if node_a in triangle and node_b in triangle:
		return true
	return false

func get_center():
	return (triangle[0].position + triangle[1].position + triangle[2].position) / 3
