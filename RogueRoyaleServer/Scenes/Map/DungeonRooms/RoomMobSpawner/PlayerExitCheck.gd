extends Area2D
class_name PlayerExitCheck

var players_currently_inside = []

@onready var room_mob_spawner = get_node("%RoomMobSpawner")

func _ready():
	connect("body_entered",Callable(self,"_on_PlayerExitCheck_body_entered"))
	connect("body_exited",Callable(self,"_on_PlayerExitCheck_body_exited"))

func _on_PlayerExitCheck_body_entered(body):
	if body.is_in_group("Players"):
		players_currently_inside.append(body)

func _on_PlayerExitCheck_body_exited(body):
	if body in players_currently_inside:
		players_currently_inside.erase(body)
		room_mob_spawner.check_for_door_open_on_player_exit(body)

