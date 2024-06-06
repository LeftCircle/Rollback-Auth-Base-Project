@tool
extends Node

#var noise_placer = preload("res://MapInfo/DungeonRooms/ProcGen/Noise/NoisePlacement.gd").new()
var grass_tiles = preload("res://placeholder_textures/TileMaps/GrassTiles.tscn").instantiate()
var trees = preload("res://Textures/FirstFloor/Tree.tscn")
#var border_filler = preload("res://MapInfo/DungeonRooms/ProcGen/BorderPlacement/BorderFiller.tscn")

func _ready():
	var place_tiles_funcref = funcref(self, "_place_tiles")
	if Engine.editor_hint:
		pass
		#_place_tiles()
	else:
		pass
		#FunctionQueue.queue_funcref(place_tiles_funcref)
	#border_filler = border_filler.instantiate()
	#border_filler.init($Border, [trees])
	#$Border.add_child(border_filler)


#func _place_tiles():
#	print("Place tiles called")
#	var aabb_pos = get_parent().room_aabb.position / get_parent().TILE_SIZE
#	var aabb_end = get_parent().room_aabb.end / get_parent().TILE_SIZE
#	var x_range = Vector2(aabb_pos.x, aabb_end.x)
#	var y_range = Vector2(aabb_pos.y, aabb_end.y)
#	noise_placer._fill_area(grass_tiles, 0, x_range, y_range, Vector2(-1, 1))
#	noise_placer._fill_area(grass_tiles, 1, x_range, y_range, Vector2(0.3, 1))
#	#var add_child_funcref = funcref(self, "add_child")
#	add_child(grass_tiles)

func _exit_tree():
	pass
