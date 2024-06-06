extends CharacterBody2D

var test_id = 12345

func _ready():
	add_to_group("Players")
	Server.on_player_verified(test_id)
