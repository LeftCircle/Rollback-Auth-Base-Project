extends Resource
class_name ClosestPointFinder

func find_closest_node_to(node, other_nodes):
	var min_dist_sq = INF
	var closest_node
	other_nodes.erase(node)
	for other_node in other_nodes:
		var dist_sq = node.position.distance_squared_to(other_node.position)
		if dist_sq < min_dist_sq:
			min_dist_sq = dist_sq
			closest_node = other_node
	return closest_node 

func find_closest_node_to_point(point, other_nodes):
	var min_dist_sq = INF
	var closest_node
	for other_node in other_nodes:
		var dist_sq = point.distance_squared_to(other_node.position)
		if dist_sq < min_dist_sq:
			min_dist_sq = dist_sq
			closest_node = other_node
	return closest_node 

func find_closest_node_to_segment(s0 : Vector2, s1 : Vector2, other_nodes : Array):
	var min_dist_sq = INF
	var closest_node
	for other_node in other_nodes:
		var seg_p = Geometry.get_closest_point_to_segment(s0, s1, other_node.position)
		var dist_sq = seg_p.distance_squared_to(other_node.position)
		if dist_sq < min_dist_sq:
			min_dist_sq = dist_sq
			closest_node = other_node
	return closest_node
