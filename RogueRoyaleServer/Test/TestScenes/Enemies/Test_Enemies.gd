extends Node2D

# The name of this test will be the name of this scene. This name MUST match
# the test being sent to the client.
var test_name = "TestEnemies"
var enemy_spawn_locations = [Vector2(0, 0)]
var enemies_list = []#[Preloads.enemy_dict["EnemyDummy"]]
var player_spawn = Vector2(0, 64)
var test_player_id : int

@onready var EnemyContainer : RoomEnemies = $RoomBorder/Node2D/Enemies

func _ready():
	print("--------------------------------------------------------------------")
	print("Starting enemy test")
	set_name("TestEnemies")
	get_node("/root/SceneHandler").test_name = test_name
	spawn_enemies()
	#print("Enemy test completed and passed on the server!")

func spawn_enemies():
	EnemyContainer.set_spawn_locations(enemy_spawn_locations)
	EnemyContainer.set_allowed_enemies(enemies_list)
	EnemyContainer.spawn_enemies()

func get_player_spawn_point(player_id : int) -> Vector2:
	test_player_id = player_id
	return player_spawn
