extends TileMap

var TILE_SIZE = ProjectSettings.get_setting("global/TILE_SIZE")
var region_nodes : Array

func _ready():
	pass # Replace with function body.

func add_filler(_region_nodes : Array) -> void:
	region_nodes = _region_nodes
	_add_collision_filler_tiles()
	_clear_space_for_rooms()
	update_bitmask_region()

#func _build_region_rect2() -> Rect2:
#	var rect : Rect2
#	var x_min = INF
#	var x_max = -INF
#	var y_min = INF
#	var y_max = -INF
#	for node in region_nodes:
#		var node_rect2 = node.room_scene.border_rect2
#		x_min = min(x_min, node_rect2.position.x)
#		y_min = min(y_min, node_rect2.position.y)
#		x_max = max(x_max, node_rect2.position.x + node_rect2.size.x)
#		y_max = max(y_max, node_rect2.position.y + node_rect2.size.y)
#	var pos = Vector2(x_min, y_min)
#	var size = Vector2(x_max - x_min, y_max - y_min)
#	return Rect2(pos, size)
#
#func _add_collision_filler_tiles():
#	var region_rect2 = _build_region_rect2()
#	var x_min = region_rect2.position.x / TILE_SIZE
#	var x_max = (region_rect2.position.x + region_rect2.size.x) / TILE_SIZE
#	var y_min = region_rect2.position.y / TILE_SIZE
#	var y_max = (region_rect2.position.y + region_rect2.size.y) / TILE_SIZE
#	for x in range(x_min, x_max):
#		for y in range(y_min, y_max):
#			set_cell(x, y, 0)

func _add_collision_filler_tiles() -> void:
	pass

func _clear_space_for_rooms() -> void:
	for node in region_nodes:
		_set_cells_in_rect2(node.room_scene.border_rect2_tiles, -1)

func _set_cells_in_rect2(rect : Rect2, tile_id):
	var trc = rect.position + rect.size
	for x in range(rect.position.x, trc.x):
		for y in range(rect.position.y, trc.y):
			set_cell(x, y, tile_id)
