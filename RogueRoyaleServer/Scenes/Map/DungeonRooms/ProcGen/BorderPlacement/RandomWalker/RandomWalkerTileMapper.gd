@tool
extends TileMapResource
class_name RandomWalkerTileMapper

var walker_resource = load("res://Scenes/Map/DungeonRooms/ProcGen/BorderPlacement/RandomWalker/RandomWalker.gd")

func place_tiles():
	var n_floor_tiles = floor_tiles.size()
	var walker = walker_resource.new()
	walker.init(Vector2(x_range[0], y_range[0]), x_range, y_range)
	for i in range(1000):
		var tile = walker.take_step()
		tile_map.set_cellv(tile, floor_tiles[randi() % n_floor_tiles])
	tile_map.update_bitmask_region()
