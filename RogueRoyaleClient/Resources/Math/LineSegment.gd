extends Resource
class_name LineSegment

var point_a : Vector2
var point_b : Vector2
# [a, b, c] for ax + by + c = 0
var line_equation : Array

func init(_point_a, _point_b) -> void:
	point_a = _point_a
	point_b = _point_b
	_build_line_equation(point_a, point_b)

func _build_line_equation(pos_a : Vector2, pos_b : Vector2):
	var a = pos_b.y - pos_a.y
	var b = pos_a.x - pos_b.x
	var c = pos_b.cross(pos_a)
	line_equation = [a, b, c]

func get_intersection(other_line : LineSegment, on_segment = true):
	var a0 = line_equation[0]
	var b0 = line_equation[1]
	var c0 = line_equation[2]
	var a1 = other_line.line_equation[0]
	var b1 = other_line.line_equation[1]
	var c1 = other_line.line_equation[2]
	var num_x = (b0 * c1 - b1 * c0)
	var den_x = (a0 * b1 - a1 * b0)
	var num_y = (c0 * a1 - c1 * a0)
	var den_y = (a0 * b1 - a1 * b0)
	if den_x == 0 or den_y == 0:
		return _get_intersection(other_line)
	var x = num_x / den_x
	var y = num_y / den_y
	var intersection = Vector2(x, y)
	if not on_segment:
		return intersection
	else:
		if has_point(intersection) and other_line.has_point(intersection):
			return intersection
		return null

func _get_intersection(other_line : LineSegment):
	var g_intersect = Geometry2D.segment_intersects_segment(point_a, point_b,
			other_line.point_a, other_line.point_b)
	if not g_intersect == null:
		return g_intersect
	elif other_line.point_a == point_a or other_line.point_b == point_a:
		return point_a
	elif other_line.point_a == point_b or other_line.point_b == point_b:
		return point_b
	else:
		return null

func has_point(p : Vector2, threshold = 0.1) -> bool:
	var a_to_b = point_a.direction_to(point_b)
	var a_ext = point_a + threshold * -a_to_b
	var b_ext = point_b + threshold * a_to_b
	p = _account_for_floats(p)
	return (p.x <= max(a_ext.x, b_ext.x) and p.x >= min(a_ext.x, b_ext.x) and
			p.y <= max(a_ext.y, b_ext.y) and p.y >= min(a_ext.y, b_ext.y))

func _account_for_floats(p, threshold = 0.1):
	var x_eq_a = abs(point_a.x - p.x) < threshold
	var x_eq_b = abs(point_b.x - p.x) < threshold
	var y_eq_a = abs(point_a.y - p.y) < threshold
	var y_eq_b = abs(point_b.y - p.y) < threshold
	if x_eq_a:
		p.x = point_a.x
	elif x_eq_b:
		p.x = point_b.x
	if y_eq_a:
		p.y = point_a.y
	elif y_eq_b:
		p.y = point_b.y
	return p

func is_point_close_to_end(point : Vector2, threshold : float) -> bool:
	var thresh_sq = pow(threshold, 2)
	return (point.distance_squared_to(point_a) < thresh_sq or
		point.distance_squared_to(point_b) < thresh_sq)

func get_center():
	return (point_a + point_b) / 2

func move_point_towards_center(point : Vector2, shift : float) -> Vector2:
	var point_to_center = point.direction_to(get_center())
	return point + point_to_center * shift
