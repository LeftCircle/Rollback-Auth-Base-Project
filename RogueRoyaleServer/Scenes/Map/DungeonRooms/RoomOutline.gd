extends Node2D
class_name RoomOutline

@export var width_and_height_tiles : Vector2 = Vector2(10, 10) : set = set_width_and_height_tiles
@export var border_size_tiles : int = 4 : set = set_border_size

var netcode = NetcodeBaseEntity.new()

var TILE_SIZE = ProjectSettings.get_setting("global/TILE_SIZE")

var room_rect2 : Rect2 = Rect2(Vector2.ZERO, Vector2.ZERO)
var border_rect2 : Rect2
var room_rect2_tiles : Rect2
var border_rect2_tiles : Rect2
var room_rect2_extended_tiles #: Rect2AABB
var room_rect2_extended
var border_rect2_extended_tiles
#var tile_map_modder = RoomTileMapModder.new()

@onready var door_container : Node2D = $Doors
@onready var room_tiles_container = $RoomTiles
@onready var border_tiles_container = $BorderTiles

func _init():
	_netcode_init()

func _netcode_init():
	netcode.init(self, "RMO", RoomOutlineData.new(), RoomOutlineCompresser.new())

func _process(delta):
	if Engine.is_editor_hint():
		queue_redraw()
	else:
		set_process(false)

func prep_data_to_send():
	netcode.state_data.set_data_with_obj(self)
	MapClientSpawner.add_netcode_to_compress(netcode)
	for door in door_container.get_children():
		door.prep_data_to_send()

func get_border_tilemap():
	return border_tiles_container.get_children()[0]

func set_position_snapped(new_pos : Vector2) -> void:
	position = new_pos.snapped(ProjectSettings.get_setting("global/TILE_VEC"))
	set_room_and_border_rect2()

func get_closest_door_pair_to(other_room : RoomOutline) -> Array:
	# Returns [this_room_closest_door, other_room_closest_door]
	var min_distance = INF
	var other_doors = other_room.get_doors()
	var doors = get_doors()
	var closest_doors = [null, null]
	for other_door in other_doors:
		for door in doors:
			var distance = door.global_position.distance_squared_to(other_door.global_position)
			if distance < min_distance:
				min_distance = distance
				closest_doors[0] = door
				closest_doors[1] = other_door
	return closest_doors

func get_closest_door_to(door):
	var min_distance = INF
	var closest_door
	var doors = get_doors()
	for other_door in doors:
		if other_door == door:
			continue
		var distance = door.global_position.distance_squared_to(other_door.global_position)
		if distance < min_distance:
			min_distance = distance
			closest_door = other_door
	return closest_door

func _draw():
	if Engine.is_editor_hint():
		_draw_room_rect2()
		_draw_border_abb()
#	else:
#		var roomr2 = _aabb_for_scene(room_rect2)
#		var pos_mod = Vector2.ONE * border_size_tiles * 64
#		var borderr2 = Rect2(-pos_mod, border_rect2.size)
#		draw_rect(roomr2, Color.BLUE, false)
#		draw_rect(borderr2, Color.RED, false)

func _draw_room_rect2():
	draw_rect(room_rect2, Color.BLUE, false)

func _draw_border_abb():
	draw_rect(border_rect2, Color.RED, false)

func _aabb_for_scene(aabb : Rect2) -> Rect2:
	var pos = Vector2.ZERO
	return Rect2(pos, aabb.size)

func build_room_rect2aabb() -> void:
	room_rect2_extended_tiles = Rect2Extended.new()
	room_rect2_extended_tiles.init(room_rect2_tiles)
	room_rect2_extended = Rect2Extended.new()
	room_rect2_extended.init(room_rect2)
	border_rect2_extended_tiles = Rect2Extended.new()
	border_rect2_extended_tiles.init(border_rect2_tiles)

func _get_door_side_global(point : Vector2) -> String:
	var side : String
	if room_rect2_extended.top_line.has_point(point):
		side = "top"
	elif room_rect2_extended.bottom_line.has_point(point):
		side = "bottom"
	elif room_rect2_extended.left_line.has_point(point):
		side = "left"
	elif room_rect2_extended.right_line.has_point(point):
		side = "right"
	return side

func _ensure_door_fits_on_room(door : DoorBorder, spawn_point):
	pass
#	var door_width = door.door_width * TILE_SIZE
#	if door.door_side == "top":
#		if room_rect2_extended.top_line.is_point_close_to_end(spawn_point, door_width):
#			door.color = Color.RED
#			return room_rect2_extended.top_line.move_point_towards_center(spawn_point, door_width)
#	elif door.door_side == "bottom":
#		if room_rect2_extended.bottom_line.is_point_close_to_end(spawn_point, door_width):
#			door.color = Color.RED
#			return room_rect2_extended.bottom_line.move_point_towards_center(spawn_point, door_width)
#	elif door.door_side == "left":
#		if room_rect2_extended.left_line.is_point_close_to_end(spawn_point, door_width):
#			door.color = Color.RED
#			return room_rect2_extended.left_line.move_point_towards_center(spawn_point, door_width)
#	elif door.door_side == "right":
#		if room_rect2_extended.right_line.is_point_close_to_end(spawn_point, door_width):
#			door.color = Color.RED
#			return room_rect2_extended.right_line.move_point_towards_center(spawn_point, door_width)
#	return spawn_point

func get_room_center() -> Vector2:
	return room_rect2.get_center()

func get_room_center_tiles() -> Vector2:
	return room_rect2_tiles.get_center()

func get_local_center_tiles() -> Vector2:
	return room_rect2_tiles.size / 2

func get_doors():
	return $Doors.get_children()


################################################################################
######### All of the setters
################################################################################

func _round_vector2(vector : Vector2) -> Vector2:
	vector.x = round(vector.x)
	vector.y = round(vector.y)
	return vector

func set_width_and_height_tiles(_width_and_height : Vector2) -> void:
	assert(_width_and_height.x > 0 and _width_and_height.y > 0) #,"Width and height must be > 0")
	width_and_height_tiles = _round_vector2(_width_and_height)
	set_room_and_border_rect2()

func set_room_and_border_rect2():
	var border_size_vector = Vector2(border_size_tiles, border_size_tiles)
	room_rect2_tiles.position = position / TILE_SIZE #Vector2.ZERO
	room_rect2_tiles.size = width_and_height_tiles
	room_rect2.position = position
	room_rect2.size = width_and_height_tiles * TILE_SIZE
	border_rect2.position = position - border_size_vector * TILE_SIZE
	border_rect2.size = (border_size_vector * 2 + width_and_height_tiles) * TILE_SIZE
	border_rect2_tiles.position = position / TILE_SIZE - border_size_vector
	border_rect2_tiles.size = border_size_vector * 2 + width_and_height_tiles

func set_border_size(size : int) -> void:
	assert(size > 0) #,"there must be a border")
	border_size_tiles = size
	set_width_and_height_tiles(width_and_height_tiles)

func _round_rect2(rect2 : Rect2) -> Rect2:
	rect2.size.x = round(rect2.size.x)
	rect2.size.y = round(rect2.size.y)
	rect2.position.x = round(rect2.position.x)
	rect2.position.y = round(rect2.position.y)
	return rect2
