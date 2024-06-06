extends Resource
class_name TileMapResource

@export var floor_tiles setget set_floor_tiles # (Array, int)
@export var wall_tiles setget set_wall_tiles # (Array, int)

var tile_map : TileMap
var tile_size_multiplier
var x_range
var y_range
signal resource_updated

func init(_tile_map : TileMap, _room_rect2_tiles : Rect2, tile_size_multiplier : int):
	tile_map = _tile_map
	var size = _room_rect2_tiles.size * tile_size_multiplier
	x_range = Vector2(_room_rect2_tiles.position.x, _room_rect2_tiles.position.x + size.x) 
	y_range = Vector2(_room_rect2_tiles.position.y, _room_rect2_tiles.position.y + size.y)

# In place of a virtual function, we just have this pass. All derived classes
# should have a draw tiles function
func draw_tiles():
	pass

func set_floor_tiles(tiles : Array) -> void:
	floor_tiles = tiles
	send_signal_if_in_editor()

func set_wall_tiles(tiles : Array) -> void:
	wall_tiles = tiles
	send_signal_if_in_editor()

func send_signal_if_in_editor():
	if Engine.is_editor_hint():
		emit_signal("resource_updated")
