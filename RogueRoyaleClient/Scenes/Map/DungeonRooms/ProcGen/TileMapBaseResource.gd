extends Resource
class_name TileMapResource

@export var floor_tiles setget set_floor_tiles # (Array, int)
@export var wall_tiles setget set_wall_tiles # (Array, int)

var tile_map : TileMap
var tile_size_multiplier
var room_outline : RoomOutline

signal resource_updated

func init(_tile_map : TileMap, _room_outline : RoomOutline, _tile_size_multiplier : int):
	tile_map = _tile_map
	tile_size_multiplier = _tile_size_multiplier
	room_outline = _room_outline

# In place of a virtual function, we just have this pass. All derived classes
# should have a draw tiles function
func draw_tiles():
	pass

func set_cells_in_r2(rect2 : Rect2, funcref_to_execute : FuncRef, args : Array = []) -> void:
	var temp_rect2 : Rect2
	if tile_size_multiplier != 1:
		var new_size = rect2.size * tile_size_multiplier
		temp_rect2 = Rect2(rect2.position, new_size)
	else:
		temp_rect2 = rect2
	for y_tile in range(temp_rect2.position.y, temp_rect2.end.y):
		for x_tile in range(temp_rect2.position.x, temp_rect2.end.x):
			args = [x_tile, y_tile]
			funcref_to_execute.call_funcv(args)

func set_floor_tiles(tiles : Array) -> void:
	floor_tiles = tiles
	send_signal_if_in_editor()

func set_wall_tiles(tiles : Array) -> void:
	wall_tiles = tiles
	send_signal_if_in_editor()

func send_signal_if_in_editor():
	if Engine.editor_hint:
		emit_signal("resource_updated")
