extends Node2D

signal region_generated()

var world_state_decompresser = WorldStateDecompression.new()

var debug_is_region_generated = false
var map_creation_frame : int = -1

@onready var paths_builder = $PathsGenerater
@onready var region_tile_map = $FirstFloorPath
@onready var floor_tile_map = $FirstFloorFloors
@onready var wall_tile_map = $FirstFloorWalls

func _init():
	world_state_decompresser.connect("done_processing",Callable(self,"_on_map_packet_processed"))

func receive_map_spawn_data(compressed_world_state : Array) -> void:
	var world_state_data = WorldStateData.new()
	var server_frame = world_state_decompresser.get_frame(compressed_world_state)
	world_state_data.frame = server_frame
	world_state_data.compressed_data = compressed_world_state
	world_state_decompresser.decompress_world_state(world_state_data)
	map_creation_frame = server_frame
	RollbackSystem.connect("rollback_frame", _on_rollback_frame)


func _on_rollback_frame(frame : int) -> void:
	if frame == map_creation_frame:
		RollbackSystem.disconnect("rollback_frame", _on_rollback_frame)
		_on_map_packet_processed()
	else:
		pass

func _on_map_packet_processed():
	var rooms = get_tree().get_nodes_in_group("Rooms")
	var doors = get_tree().get_nodes_in_group("Doors")
	paths_builder.init(rooms, doors, floor_tile_map, wall_tile_map)
	paths_builder.path_walker.init_floor_tile_map(floor_tile_map, 0, 1)
	paths_builder.path_walker.init_wall_tile_map(wall_tile_map, 0, 1)
	paths_builder.generate_paths()

func _on_PathsGenerater_paths_completed():
	region_tile_map.spawn_voronoi_tiles()
	emit_signal("region_generated")
	Server.send_map_loaded_and_command_step()
	debug_is_region_generated = true

func get_rect2_around_rooms(rooms : Array) -> Rect2:
	var rect2 = Rect2()
	for room in rooms:
		rect2 = rect2.merge(room.border_rect2)
	return rect2

func get_border_rect2_array(rooms : Array) -> Array:
	var border_rect2_array = []
	for room in rooms:
		border_rect2_array.append(room.border_rect2)
	return border_rect2_array

func get_border_rect2_array_tiles(rooms : Array) -> Array:
	var border_rect2_array = []
	for room in rooms:
		border_rect2_array.append(room.border_rect2_tiles)
	return border_rect2_array

func get_region_tile_map() -> TileMap:
	return region_tile_map

func clear():
	var children = []
	$FirstFloorWalls.clear()
	children += $FirstFloorWalls.get_children()
	$FirstFloorPath.clear()
	children += $FirstFloorPath.get_children()
	$FirstFloorFloors.clear()
	children += $FirstFloorFloors.get_children()
	for child in children:
		child.queue_free()
