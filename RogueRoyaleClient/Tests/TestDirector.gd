extends Node

## This delegates the Map to laod up the appropriate test
#var test_name = ""
#var map_preload = preload("res://MapInfo/Map.tscn")
#
## The test name is sent from the Server, and the desired scene is loaded from
## the test_dict
## { "TestName" : "TestPath"}
#var test_dict = {
#	"SpellTests" : "res://03_Tests/01_TestScenes/00_Spells/SpellTests.tscn",
#	"TestEnemies" : "res://03_Tests/01_TestScenes/Enemy/Test_Enemies.tscn"
#}
#
## TestDirector is instanced from the SceneHandler, which is the main scene
#func _ready():
#	print("Test Director called!")
#	var map = map_preload.instantiate()
#	map.set_name("Map")
#	get_node("/root/SceneHandler").add_child(map)
#	var player_id = get_tree().get_unique_id()
#
## Called once the server connects.
#func set_test_name(new_name : String) -> void:
#	test_name = new_name
#	get_node("/root/SceneHandler/Map").add_child(get_test_scene())
#
#func instance_test_scene(test_path : String) -> void:
#	get_node("/root/SceneHandler/Map").add_child(load(test_path).instantiate())
#
#func get_test_scene():
#	var test_scene = load(test_dict[test_name]).instantiate()
#	test_scene.set_name(test_name)
#	return test_scene
