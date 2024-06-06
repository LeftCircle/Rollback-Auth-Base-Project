extends Node
class_name SceneHandler

@export var test_path : String = "" : set = set_test_to_run

# Set from the test once it is loaded
var test_name : String

@onready var lobby = preload("res://Scenes/Lobby/Lobby.tscn")

func _ready():
	build_lobby()
	var is_test = test_path != ""
	Map.build_dungeon(is_test, test_path)

func build_lobby():
	var new_lobby = lobby.instantiate()
	new_lobby.set_name("Lobby")
	self.add_child(new_lobby, true)

func set_test_to_run(node_to_load : String) -> void:
	test_path = node_to_load
