extends Resource
class_name TilePlacer

var tile_map : TileMap
var set = false

func init(tilemap : TileMap) -> void:
	set = true
	tile_map = tilemap

func place_tiles_in_rect(rect : Rect2, tile_id : int) -> void:
	assert(set)
	for x in range(rect.position.x, rect.end.x):
		for y in range(rect.position.y, rect.end.y):
			tile_map.set_cell(x, y, tile_id)
