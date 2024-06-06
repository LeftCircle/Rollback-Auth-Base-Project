extends Node


# NOTE - may have to write a json file reader with a json with username and password around
# 8:30 in the third multiplayer tutorial
var player_ids
var player_id_path = "user://PlayerIDs.json"
# Called when the node enters the scene tree for the first time.

func _ready():
	#var player_data_file = FileAccess.open(player_id_path, FileAccess.READ_WRITE)
	if not FileAccess.file_exists(player_id_path):
		var player_data_file = FileAccess.open(player_id_path, FileAccess.WRITE)
		player_data_file.store_line(JSON.stringify({}))
		player_ids = {}
		player_data_file.close()
	else:
		var player_data_file = FileAccess.open("user://PlayerIDs.json", FileAccess.READ)
		var test_json_conv = JSON.new()
		test_json_conv.parse(player_data_file.get_as_text())
		var player_data_json = test_json_conv.get_data()
		player_data_file.close()
		player_ids = player_data_json

func save_player_ids():
	var save_file = FileAccess.open("user://PlayerIDs.json", FileAccess.WRITE)
	save_file.store_line(JSON.stringify(player_ids))
	save_file.close()
