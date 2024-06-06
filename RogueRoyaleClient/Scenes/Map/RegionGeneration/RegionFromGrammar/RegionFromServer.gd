extends Node2D
class_name RegionFromServer

#export var door_border: PackedScene
#
#var region_data : Dictionary
#var grammar_data #: GrammarData
#
#onready var room_container = $RoomContainer
#onready var path_navigation = $PathNavigation
#onready var region_filler_tilemap = $FillerTiles
#
#func init(_grammar_data) -> void:
#	grammar_data = _grammar_data
#
#func spawn_region():
#	spawn_rooms()
#	build_paths()
#	Server.send_map_loaded_and_command_step()
#
#func spawn_rooms() -> void:
#	for room_n in grammar_data.rooms:
#		var room_scene = grammar_data.rooms[room_n]
#		add_child(room_scene)
#
#func build_paths():
#	path_navigation.build_navigation_polygon(self)
#	path_navigation.connect_doors()
#
#func get_region_rect2():
#	var rect2 = Rect2()
#	for node_n in grammar_data.rooms:
#		var room_scene = grammar_data.rooms[node_n]
#		rect2 = rect2.merge(room_scene.border_rect2)
#	return rect2
