extends Resource
class_name GrammarData

# We need a class that holds all of the rooms and springs
var springs = []
var rooms = {}
var door_border_scene = load("res://Scenes/Map/DungeonDoors/DoorBorder.tscn")

# Data appears as var data = {
#	"Nodes" : {node_n : {
#							Doors : [{Side : String, Position : int, SearchDistance : int, Width : int, Number : int}],
#							Position : int,
#							RoomPath : String}
#			}, ...}
#	"Springs" : [{"NodeA" : {"NodeNumber" : null, "DoorNumber" : null},
				#"NodeB" : {"NodeNumber" : null, "DoorNumber" : null}}, ...],
#	"MapRNGSeed" : int
#}

func init(grammar_dict : Dictionary) -> void:
	WorldState.set_map_rng(grammar_dict["MapRNGSeed"])
	_init_rooms(grammar_dict["Nodes"])
	_init_springs(grammar_dict["Springs"])

func _init_rooms(node_data : Dictionary) -> void:
	for node_n in node_data:
		var current_node_data = node_data[node_n]
		var room_path = current_node_data["RoomPath"]
		var doors = current_node_data["Doors"]
		var pos = current_node_data["Position"]
		_init_room(node_n, room_path, pos, doors)

func _init_room(node_number, room_path : String, pos : Vector2, doors : Array) -> void:
	var room = load(room_path).instantiate()
	room.set_position_snapped(pos)
	room.set_node_number(node_number)
	rooms[node_number] = room
	for door_data in doors:
		var door_node = door_border_scene.instantiate()
		door_node.position = door_data["Position"]
		door_node.door_side = door_data["Side"]
		door_node.door_search_distance = door_data["SearchDistance"]
		door_node.door_width = door_data["Width"]
		door_node.number = door_data["Number"]
		room.spawn_door_without_checking_pos(door_node)
		#rooms[node_number]["Doors"][door_node.number] = door_node

func _init_springs(spring_data_array : Array) -> void:
	for spring_data in spring_data_array:
		var spring = SpringFromServer.new()
		spring.node_a = rooms[spring_data["NodeA"]["NodeNumber"]]
		spring.node_b = rooms[spring_data["NodeB"]["NodeNumber"]]
		spring.door_a = spring.node_a.doors[spring_data["NodeA"]["DoorNumber"]]
		spring.door_b = spring.node_b.doors[spring_data["NodeB"]["DoorNumber"]]
		springs.append(spring)


