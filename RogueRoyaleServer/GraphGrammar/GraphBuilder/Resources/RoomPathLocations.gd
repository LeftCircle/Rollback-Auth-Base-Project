extends Resource
class_name RoomPathLocations

@export var floor_to_load: String = "FirstFloor"
var base_path_to_grammars = "res://Scenes/Map/RegionGeneration/RegionFromGrammar/GrammarSaves/"
var base_path_to_rooms = "res://Scenes/Map/DungeonRooms/RoomScenes/"

var room_dict : Dictionary
var file_lister = FileLister.new()

func set_floor_to_load(floor_name : String) -> void:
	floor_to_load = floor_name

func build_room_path_dict():
	_search_for_room_types()
	var room_types = file_lister.get_folder_names()
	var room_type_paths = file_lister.get_folder_paths()
	room_dict = _build_room_type_dict(room_types, room_type_paths)

func _search_for_room_types():
	var room_scenes_path = base_path_to_rooms + "/" + floor_to_load
	file_lister.set_folder_path(room_scenes_path)
	file_lister.set_create_list_of_folders(true)
	file_lister.load_resources()

func _build_room_type_dict(room_types : Array, room_paths : Array) -> Dictionary:
	file_lister.set_create_list_of_folders(false)
	file_lister.set_file_ending(".tscn")
	room_dict = {}
	for room_type in room_types:
		for path in room_paths:
			if path.ends_with(room_type):
				room_paths.erase(path)
				file_lister.set_folder_path(path)
				file_lister.load_resources()
				room_dict[room_type] = {
					"TypePath" : path,
					"RoomPaths" : file_lister.get_file_paths()
				}
				break
	return room_dict

func assign_room_to_node(node) -> void:
	var rooms = room_dict[node.node_info.room_type]["RoomPaths"]
	#if rooms.is_empty():
	#	_refill_room_dict(node.node_info.room_type)
	#	rooms = room_dict[node.node_info.room_type]["RoomPaths"]
	var random_room = rooms[Map.map_rng.randi() % rooms.size()]
	node.set_room_scene_from_path(random_room)
	#room_dict[node.node_info.room_type]["RoomPaths"].erase(random_room)

func _refill_room_dict(room_type : String) -> void:
	file_lister.set_folder_path(room_dict[room_type]["TypePath"])
	file_lister.set_create_list_of_folders(true)
	file_lister.load_resources()
	room_dict[room_type]["RoomPaths"] = file_lister.get_file_paths()
