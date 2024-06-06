extends Node2D
class_name RegionFromGrammar

# See this issue: https://github.com/godotengine/godot/issues/67056
# Having this variable keeps the script from matching the previous regionFromGrammar script, and
# therefore the engine doesn't get confused
#var debug_shadow_file_hider = true

#const WAIT_TIME_FOR_NODE_PROCESSING = 0.2
signal region_generation_complete()

#@export var floor_to_load: String = "PlayTest"
#export var floor_to_load: String = "TestFloor"
#export var floor_to_load: String = "FirstFloor"
@export var floor_to_load = "GutRegionGeneration"
@export_dir var base_path_to_grammars # (String, DIR)
@export_dir var base_path_to_rooms # (String, DIR)
@export var SpawnResource: Resource
@export var is_test: bool = false
@export var grammar_path_to_test = "res://Scenes/Map/regionGeneration/RegionFromGrammar/GrammarSaves/FirstFloor/TestFIrstFloorSpawn_grammar.res" # (String, FILE, "*.res")

var n_tiles_to_grow_region = 4
var grammar_data : GRuleInfoReader
var file_lister = FileLister.new()
var test_path = "res://Scenes/Map/RegionGeneration/RegionFromGrammar/GrammarSaves/FirstFloor/tri_start_no_rules_grammar.res"
var region_data_sender = RegionDataSender.new()
#var path_between_room_generator = PathBetweenRoomGenerator.new()
var region_built = false
var data_sent = false

# This one will be used for godot 4 when the other is depricated
@onready var rule_applier = $GrammarRuleApplier
@onready var path_between_room_generator = $PathsBetweenRoomGenerator
@onready var spring_container = $SpringContainer
@onready var node_container = $NodeContainer
@onready var room_container = $RoomContainer
@onready var region_filler_tilemap = $FillerTiles

func set_floor_to_load(floor_name : String) -> void:
	floor_to_load = floor_name

func _ready():
	if not is_test:
		_on_ready()
		build_region()
	else:
		_on_ready()

func _on_ready():
	var room_path_locations = RoomPathLocations.new()
	room_path_locations.set_floor_to_load(floor_to_load)
	rule_applier.set_room_paths(room_path_locations)
	rule_applier.connect("all_rules_applied",Callable(self,"_on_all_rules_applied"))

func build_region():
	var floor_grammars_path = base_path_to_grammars + "/" + floor_to_load
	_build_graph_and_wait_for_signal(floor_grammars_path)

func _build_graph_and_wait_for_signal(floor_folder_path : String):
	clear_old_nodes()
	var random_path : String
	if not is_test:
		random_path = _get_random_path_to_graph(floor_folder_path)
	else:
		random_path = grammar_path_to_test
	_spawn_new_nodes(random_path)

func clear_old_nodes():
	var objs = node_container.get_children() + spring_container.get_children()
	for obj in objs:
		obj.call_deferred("queue_free")

func _get_random_path_to_graph(floor_folder_path : String) -> String:
	file_lister.folder_path = floor_folder_path
	file_lister.file_ending = ".res"
	file_lister.load_resources()
	return _get_random_path(file_lister.all_file_paths)

func _get_random_path(paths):
	return paths[Map.map_rng.randi() % paths.size()]

func _spawn_new_nodes(path_to_grammar_save : String) -> void:
	var grammar_save
	if FileAccess.file_exists(path_to_grammar_save):
		grammar_save = load(path_to_grammar_save)
		grammar_data = GRuleInfoReader.new()
		grammar_data.connect_reader_to_rule(grammar_save.starting_save)
		rule_applier.apply_rules_from_array(node_container, spring_container, grammar_data, grammar_save.rule_saves)

func _on_all_rules_applied():
	_deactivate_nodes_and_springs()
	_spawn_rooms()
	path_between_room_generator.init(get_region_rect2(), get_rect2_from_rooms(), region_filler_tilemap, get_rect2_tiles_from_rooms(), get_rooms())
	path_between_room_generator.generate_paths(self)
	#path_between_room_generator.generate_paths_surrounding_rooms(get_rooms())
	#path_between_room_generator.clear_tiles_from_rects()
	#_add_noise()
	region_built = true
	#_free_rule_and_grammar()
	emit_signal("region_generation_complete")

func _deactivate_nodes_and_springs():
	var objects = grammar_data.LHS_nodes
	for obj in objects:
		obj.deactivate()

func _spawn_rooms():
	for node in grammar_data.LHS_nodes:
		var border_shift = ((Vector2.ONE * node.room_scene.border_size_tiles) *
						ProjectSettings.get_setting("global/TILE_SIZE"))
		var node_rect = node.get_node_rect()
		node.room_scene.set_position_snapped(node_rect.position + border_shift)
		room_container.add_child(node.room_scene)
		node.room_scene.build_room_rect2aabb()

func _send_region_data():
	var data = {}
	for node in grammar_data.LHS_nodes:
		data[node.node_info.node_number] = node.get_data_to_send()

func _add_noise():
	#var tile_setter = TileMapSetter.new()
	#tile_setter.init(region_filler_tilemap)
	#var region_rect2_tiles = get_region_rect2_tiles()
	#region_rect2_tiles = region_rect2_tiles.grow(n_tiles_to_grow_region)
	#var room_rect2_tiles = get_rect2_tiles_from_rooms()
	#tile_setter.set_tile_in_rect2_and_avoid_rects(0, region_rect2_tiles, room_rect2_tiles)

	var non_room_tiles_finder = NonRoomTiles.new()
	non_room_tiles_finder.init(self, n_tiles_to_grow_region)
	var non_room_tiles = non_room_tiles_finder.build_non_room_tiles_array()
	print("Cells placed = ", non_room_tiles_finder.placed)
	region_filler_tilemap.update_bitmask_region()

func get_region_rect2_tiles():
	var rect2 = Rect2()
	for node in grammar_data.LHS_nodes:
		rect2 = rect2.merge(node.room_scene.border_rect2_tiles)
	return rect2

func get_region_rect2():
	var rect2 = Rect2()
	for node in grammar_data.LHS_nodes:
		rect2 = rect2.merge(node.room_scene.border_rect2)
	return rect2

func get_rooms():
	return room_container.get_children()

func get_spawn_room():
	for node in grammar_data.LHS_nodes:
		if node.node_info.room_type == "SpawnRooms":
			return node.room_scene

func get_player_spawn_point(player_id : int) -> Vector2:
	return SpawnResource.region_spawn_point(self, player_id)

func prep_region_data_to_send():
#	if not region_built:
#		call_deferred("send_region_data")
#	elif not data_sent:
	region_data_sender.prep_data_to_send(grammar_data)
	data_sent = true

func get_rect2_tiles_from_rooms() -> Array:
	var rooms = room_container.get_children()
	var rect2s = []
	for room in rooms:
		rect2s.append(room.border_rect2_tiles)
	return rect2s

func get_rect2_from_rooms() -> Array:
	var rooms = room_container.get_children()
	var rect2s = []
	for room in rooms:
		rect2s.append(room.border_rect2)
	return rect2s

func _exit_tree():
	_free_rule_and_grammar()

func _free_rule_and_grammar():
	if is_instance_valid(rule_applier):
		rule_applier.queue_free()
	if is_instance_valid(grammar_data):
		grammar_data.free_resource()
