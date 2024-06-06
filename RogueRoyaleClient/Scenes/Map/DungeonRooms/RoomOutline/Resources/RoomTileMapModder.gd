extends Resource
class_name RoomTileMapModder

var room_outline
var tile_placer = TilePlacer.new()

func init(roomOutline) -> void:
	room_outline = roomOutline
	tile_placer.tile_map = room_outline.get_border_tilemap()

func clear_border_tiles_from_door(door_border : DoorBorder):
	var room_local_center = room_outline.get_local_center_tiles()
	var door_local_rect = door_border.get_local_rect2_tiles()
	var center_proj : Vector2
	var pos_to_center = room_local_center - door_local_rect.position
	if door_border.door_side in ["left", "right"]:
		# Shift by x
		center_proj = door_local_rect.position + Vector2(pos_to_center.x, 0)
	else:
		center_proj = door_local_rect.position + Vector2(0, pos_to_center.y)
	var door_to_center_rect = door_local_rect.expand(center_proj)
	tile_placer.place_tiles_in_rect(door_to_center_rect, -1)
