extends Resource
class_name TriangulatePolygon

func triangulate_polygon(polygon: PackedVector2Array):
	var res_delaunay = Geometry.triangulate_delaunay(polygon)
	var polygons = []
	for i in range(0, res_delaunay.size(), 3):
		var vec_array = PackedVector2Array([
			polygon[res_delaunay[i]],
			polygon[res_delaunay[i + 1]],
			polygon[res_delaunay[i + 2]]
		])
		polygons.append(vec_array)
	return polygons

func triangulate_nodes(node_array : Array) -> Array:
	var point_array = PackedVector2Array()
	for node in node_array:
		point_array.append(node.get_position())
	var res_delaunay = Geometry.triangulate_delaunay(point_array)
	var triangles = []
	for i in range(0, res_delaunay.size(), 3):
		var triangle = RegionTriangle.new()
		triangle.init(node_array[res_delaunay[i]],
						node_array[res_delaunay[i + 1]],
						node_array[res_delaunay[i + 2]])
		triangles.append(triangle)
	return triangles
