extends AStar2D
class_name TileMapAStar

var tile_map : TileMap
var rect2 : Rect2
var x_mod
var y_mod

func init(tilemap : TileMap) -> void:
	tile_map = tilemap

func build_nodes_in_rect2(new_rect2 : Rect2) -> void:
	rect2 = new_rect2
	clear()
	var _add_nodes_funcref = funcref(self, "_add_nodes_in_rect")
	FunctionQueue.queue_funcref(_add_nodes_funcref, [rect2])
	var _connect_nodes_funcref = funcref(self, "_connect_nodes_as_a_grid")
	FunctionQueue.queue_funcref(_connect_nodes_funcref, [rect2])
	#_add_nodes_in_rect(rect2)
	#_connect_nodes_as_a_grid(rect2)

# ID's are all relative to the rect2
func _add_nodes_in_rect(rect : Rect2) -> void:
	reserve_space(rect.size.x * rect.size.y)
	x_mod = -rect.position.x if rect.position.x < 0 else 0
	y_mod = -rect.position.y if rect.position.y < 0 else 0
	for x in range(rect.position.x, rect.end.x):
		for y in range(rect.position.y, rect.end.y):
			var id = (x + x_mod) + rect.size.x * (y + y_mod)
			add_point(id, Vector2(x, y))

func _connect_nodes_as_a_grid(rect : Rect2) -> void:
	# TO DO -> fix this so that it actually creates a true grid (The edges are
	# broken)
	var x_bounds = [rect.position.x, rect.end.x - 1]
	var y_bounds = [rect.position.y, rect.end.y - 1]
	for x in range(x_bounds[0], x_bounds[1]):
		for y in range(y_bounds[0], y_bounds[1]):
			var point = Vector2(x + x_mod, y + y_mod)
			var center = point.x + rect.size.x * point.y
			var upper = point.x + (rect.size.x * point.y + 1)
			var right = (point.x + 1) + rect.size.x * point.y
			connect_points(center, upper)
			connect_points(center, right)

func remove_nodes_in_rect2(rect) -> void:
	for x in range(rect.position.x, rect.end.x):
		for y in range(rect.position.y, rect.end.y):
			remove_point(x + y * rect.size.x)
