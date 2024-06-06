extends Area2D
class_name RoomMobController

@export var door_controller_path: NodePath
@export var mob_scene_paths: Array

var mobs_have_spawned = false
var players_who_have_entered = []
var players_currently_inside = []
var mobs = []
var first_encounter_completed = false

@onready var door_controller = get_node(door_controller_path)
@onready var collision_shape = $CollisionShape2D

func _ready():
	connect("body_entered",Callable(self,"_on_MobSpawner_body_entered"))
	connect("body_exited",Callable(self,"_on_MobSpawner_body_exited"))

func check_for_door_open_on_player_exit(player_node):
	if door_controller.doors_closed:
		if players_currently_inside.is_empty():
			if players_who_have_entered.has(player_node):
				door_controller.open_doors()
				players_who_have_entered.erase(player_node)

func _spawn_mobs():
	if mobs.is_empty():
		for mob_scene_path in mob_scene_paths:
			var new_mob = load(mob_scene_path).instantiate()
			new_mob.connect("mob_death",Callable(self,"_on_mob_death"))
			mobs.append(new_mob)
			new_mob.position = _get_random_spawn_location()
			call_deferred("add_child", new_mob)

func _get_random_spawn_location() -> Vector2:
	var random_spawn_location = Vector2()
	random_spawn_location.x = randf_range(0, collision_shape.shape.size.x)
	random_spawn_location.y = randf_range(0, collision_shape.shape.size.y)
	return random_spawn_location

func _on_MobSpawner_body_entered(body):
	if body.is_in_group("Players"):
		players_currently_inside.append(body)
		if players_who_have_entered.has(body):
			print("Player has already been in this room")
			pass
		else:
			if not first_encounter_completed:
				_on_first_encounter()
			else:
				_on_subsequent_encounter()
			players_who_have_entered.append(body)

func _on_first_encounter():
	_close_doors_and_spawn_mobs()

func _on_subsequent_encounter():
	_spawn_mobs()

func _close_doors_and_spawn_mobs():
	door_controller.close_doors()
	_spawn_mobs()

func _on_mob_death(mob):
	if mob in mobs:
		mobs.erase(mob)
	if mobs.is_empty():
		door_controller.open_doors()
		_on_all_mobs_killed()

func _on_all_mobs_killed():
	if not first_encounter_completed:
		_on_first_encounter_completed()
	else:
		_on_subsequent_encounter_completed()

func _on_first_encounter_completed():
	first_encounter_completed = true

func _on_subsequent_encounter_completed():
	pass

func _on_MobSpawner_body_exited(body):
	if body.is_in_group("Players") and players_currently_inside.has(body):
		players_currently_inside.erase(body)
