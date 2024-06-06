@tool
extends TileMapResource
class_name RandomWalkerTileMapper

@onready var walker_resource = load("res://MapInfo/DungeonRooms/ProcGen/BorderPlacement/RandomWalker/RandomWalker.gd")

func place_tiles():
	var n_floor_tiles = floor_tiles.size()
	var walker = walker_resource.new() as RandomWalker
	walker.init(room_outline.room_aabb.position, room_outline.border_aabb_tiles)
	for i in range(1000):
		var tile = walker.take_step()
		tile_map.set_cellv(tile, floor_tiles[randi() % n_floor_tiles])
	tile_map.update_bitmask_region()
