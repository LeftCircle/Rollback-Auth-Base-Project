extends Node2D

# The name of this test will be the name of this scene. This name MUST match
# the test being sent to the client.

var test_name : String
var spawn_location = [Vector2(0, 0)]
var enemy = []#[Preloads.enemy_dict["EnemyDummy"]]

func _ready():
	set_name("TestSpells")
	test_name = self.get_name()
	get_node("/root/Server").test_name = test_name
	get_node("RoomBorder/Node2D/Enemies").set_spawn_locations(spawn_location)
	get_node("RoomBorder/Node2D/Enemies").set_allowed_enemies(enemy)
	get_node("RoomBorder/Node2D/Enemies").spawn_enemies()

