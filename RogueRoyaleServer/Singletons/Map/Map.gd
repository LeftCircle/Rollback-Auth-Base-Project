@tool
extends Node
# This script is responsible for spawning enemies, projectiles, and pretty
# much anything on the map!
@export var region_generator: PackedScene
@export var player_template: PackedScene

#var region_generator = preload("res://Scenes/Map/RegionGeneration/RegionFromGrammar/RegionFromGrammar.tscn")
var projectiles_path = "TempProjectiles"
#var player_template = preload("res://Scenes/Characters/PlayerCharacter/S_PlayerCharacter.tscn")
var test : bool = false
var test_scene_path = null
var map_rng : RandomNumberGenerator
var region_from_grammar = null
var map_rng_seed : int

func _ready():
	_build_map_rng()

func _build_map_rng():
	map_rng = RandomNumberGenerator.new()
	map_rng.randomize()
	map_rng_seed = map_rng.seed

func build_dungeon(is_test : bool = false, test_path : String = "") -> void:
	test = is_test
	test_scene_path = test_path
	_create_player_ysort()
	_add_dungeon_to_scene_tree()

func _add_dungeon_to_scene_tree():
	var dungeon_map = null
	if test:
		dungeon_map = load(test_scene_path).instantiate()
	else:
		dungeon_map = region_generator.instantiate()
	region_from_grammar = dungeon_map
	add_child(dungeon_map)
	var projectiles_container = Node.new()
	projectiles_container.set_name("TempProjectiles")
	add_child(projectiles_container, true)

func _create_player_ysort() -> void:
	var ysort_for_players = Node2D.new()
	ysort_for_players.set_name("Players")
	add_child(ysort_for_players, true)

func send_map_data():
	region_from_grammar.prep_region_data_to_send()
	MapClientSpawner.send_map_data()

func spawn_all_enemies():
	for enemy_container in get_tree().get_nodes_in_group("EnemyContainers"):
		enemy_container.spawn_enemies()

func spawn_new_player(player_id : int) -> void:
	if get_node_or_null("Players/" + str(player_id)) == null:
		var new_player = player_template.instantiate()
		new_player.name = str(player_id)
		new_player.player_id = player_id
		new_player.position = Vector2(randf_range(-10, 10), randf_range(-10, 10))
		$Players.add_child(new_player, true)

func get_player_node(player_id : int):
	var player_node = $Players.get_node_or_null(str(player_id))
	if player_node == null:
		Logging.log_line("Failed to find a player with id " + str(player_id))
		return null
	else:
		return (player_node)
