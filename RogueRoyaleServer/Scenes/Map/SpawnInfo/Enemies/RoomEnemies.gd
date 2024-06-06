# Controlls the logic for spawning enemies in a room
extends Node2D
class_name RoomEnemies

@export var max_enemies : int = 4 : set = set_max_enemies
@export var min_enemies : int = 2 : set = set_min_enemies
@export var spawn_locations : Array = [] : set = set_spawn_locations
@export var allowed_enemies : Array = [] : set = set_allowed_enemies
@export var enemy_scene: PackedScene

var n_enemies : int = 0
var n_have_spawned : int = 0
var rng = RandomNumberGenerator.new()

@onready var room_outline = get_parent()

signal get_room_r2_world
signal get_room_name

func set_max_enemies(new_value : int) -> void:
	new_value = max(0, new_value)
	max_enemies = new_value

func set_min_enemies(new_value : int) ->  void:
	new_value = max(0, new_value)
	new_value = min(new_value, max_enemies)
	min_enemies = new_value

func set_spawn_locations(new_locations : Array) -> void:
	spawn_locations = new_locations

func set_allowed_enemies(new_enemies : Array) -> void:
	allowed_enemies = new_enemies

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("EnemyContainers")
	rng.randomize()
	# We cannot spawn enemies in the ready function since the map has not loaded
	n_enemies = rng.randi_range(min_enemies, max_enemies)
	#_create_enemy_preload_list()
	spawn_enemies()

func pick_random_spawn_locations() -> void:
	# TO DO -> only spawn enemies on valid tiles in the dungeon
	#var room_r2 = emit_signal("get_room_r2_world")
	var room_r2 = room_outline.room_rect2
	spawn_locations = []
	for _i in range(max_enemies):
		var r_x = rng.randi_range(32, room_r2.size.x - 32)
		var r_y = rng.randi_range(32, room_r2.size.y - 32)
		spawn_locations.append(Vector2(r_x, r_y))

func spawn_enemies() -> void:
	#var room_name = get_node(room_border_path).get_name()
	print("Spawn enemies is broken DEBUG")
	pass
#	if spawn_locations == []:
#		pick_random_spawn_locations()
#	if n_have_spawned != n_enemies:
#		for i in range(n_enemies):
#			#var new_enemy = allowed_enemies[i].instantiate()
#			var new_enemy = enemy_scene.instantiate()
#			new_enemy.position = spawn_locations[i]
#			add_child(new_enemy)
#			n_have_spawned += 1

func _create_enemy_preload_list() -> void:
	pass
#	if allowed_enemies == []:
#		allowed_enemies = Preloads.pick_random_preload(Preloads.enemy_dict, n_enemies)
#	else:
#		var temp_array = []
#		for enemy_name in allowed_enemies:
#			temp_array.append(Preloads.enemy_dict[enemy_name])
#		allowed_enemies = temp_array
