extends RefCounted
class_name TileClearer

func clear_tiles_in_rect(tile_map_a : TileMap, tile_map_b : TileMap, rect2 : Rect2) -> void:
	var rect_end : Vector2 = rect2.end
	for x in range(rect2.position.x, rect_end.x):
		for y in range(rect2.position.y, rect_end.y):
			var cell := Vector2i(x, y)
			tile_map_a.set_cell(0, cell)
			tile_map_b.set_cell(0, cell)
