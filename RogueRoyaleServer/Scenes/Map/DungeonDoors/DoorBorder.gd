@tool
extends Node2D
class_name DoorBorder

enum SIDE{TOP, BOTTOM, LEFT, RIGHT}

@export var door_width := int(4) : set = set_door_width
@export var door_search_distance := int(10) : set = set_door_search_distance
@export var door_side: SIDE = SIDE.TOP : set = set_door_side

var TILE_SIZE = ProjectSettings.get_setting("global/TILE_SIZE")
var door_r2_tiles_local : Rect2
var door_r2_world_local : Rect2
var color = Color(0, 255, 0)
var number : int

func _init():
	set_notify_transform(true)

func set_door_width(new_value : int) -> void:
	door_width = new_value
	queue_redraw()
	build_door_r2s()

func set_door_search_distance(new_value : int) -> void:
	door_search_distance = new_value
	queue_redraw()
	build_door_r2s()

func set_door_side(new_side : int) -> void:
	door_side = new_side
	queue_redraw()
	build_door_r2s()

func _ready():
	add_to_group("Doors")
	queue_redraw()
	snap_pos_to_TILE_SIZE()
	build_door_r2s()

func build_door_r2s() -> void:
	var size : Vector2
	if door_side in [SIDE.TOP, SIDE.BOTTOM]:
		size = Vector2(door_width, door_search_distance)
		if door_side == SIDE.BOTTOM:
			position = position - Vector2(0, door_search_distance) * TILE_SIZE
	else:
		size = Vector2(door_search_distance, door_width)
		if door_side == SIDE.LEFT:
			position = position - Vector2(door_search_distance, 0) * TILE_SIZE
	door_r2_tiles_local = Rect2(Vector2.ZERO, size)
	door_r2_world_local = Rect2(Vector2.ZERO, size * TILE_SIZE)

func get_border_position_tiles() -> Vector2:
	if door_side in [SIDE.RIGHT, SIDE.TOP]:
		return door_r2_tiles_local.end
	else:
		return door_r2_tiles_local.position

func get_local_rect2_tiles() -> Rect2:
	return Rect2(position / TILE_SIZE, door_r2_tiles_local.size)

func update_color(new_color : Color) -> void:
	color = new_color
	queue_redraw()

func get_door_center_on_room_global():
	if door_side == SIDE.TOP:
		return to_global(Vector2(door_r2_world_local.size.x / 2, 0))
	elif door_side == SIDE.BOTTOM:
		return to_global(Vector2(door_r2_world_local.size.x / 2, door_r2_world_local.size.y))
	elif door_side == SIDE.RIGHT:
		return to_global(Vector2(0, door_r2_world_local.size.y / 2))
	else:
		return to_global(Vector2(door_r2_world_local.size.x, door_r2_world_local.size.y / 2))

func _draw():
	if Engine.is_editor_hint() or true:
		draw_circle(Vector2(0, 0), 10, Color(255, 0, 0))
		draw_rect(Rect2(Vector2.ZERO, door_r2_world_local.size), color, false)

func _notification(notif) -> void:
	if Engine.is_editor_hint() and notif == NOTIFICATION_TRANSFORM_CHANGED:
		snap_pos_to_TILE_SIZE()

func snap_pos_to_TILE_SIZE():
	position = position.snapped(Vector2(TILE_SIZE, TILE_SIZE))

func get_data_to_send():
	var data = {
		"Side" : door_side,
		"Position" : position,
		"SearchDistance" : door_search_distance,
		"Width" : door_width,
		"Number" : number
	}
	return data
