extends Resource
class_name Rect2Extended

var rect2 : Rect2
var top_line : LineSegment
var bottom_line : LineSegment
var left_line : LineSegment
var right_line : LineSegment
var line_segments : Array

func init(rect : Rect2) -> void:
	rect2 = rect
	_build_rect2_lines()

func _build_rect2_lines() -> void:
	# bottom left corner, ...
	var blc = rect2.position
	var brc = rect2.position + Vector2.RIGHT * rect2.size.x
	var tlc = rect2.position + Vector2(0, 1) * rect2.size.y
	var trc = rect2.end
	top_line = LineSegment.new()
	top_line.init(tlc, trc)
	bottom_line = LineSegment.new()
	bottom_line.init(blc, brc)
	left_line = LineSegment.new()
	left_line.init(blc, tlc)
	right_line = LineSegment.new()
	right_line.init(brc, trc)
	line_segments.append(top_line)
	line_segments.append(bottom_line)
	line_segments.append(left_line)
	line_segments.append(right_line)

func is_point_close_to_corner(point : Vector2, threshold : float) -> bool:
	return (top_line.is_point_close_to_end(point, threshold) or
		bottom_line.is_point_close_to_end(point, threshold))
