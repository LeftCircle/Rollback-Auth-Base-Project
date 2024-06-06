extends Node
class_name CharacterSpawner

@export var player_character_scene: PackedScene
@export var lag_comp_template: PackedScene
@export var rollback_template: PackedScene

var netcode = NetcodeBase.new()

func _init():
	netcode.class_id = "CHR"
	add_to_group("Spawner")

# This entire script might be deprecated

#func get_object():
#	Logging.log_line("Character spawner called")
#	var character_scene
#	if netcode.class_instance_id == ObjectCreationRegistry.client_character_class_instance_id:
#		#if ProjectSettings.get_setting("global/spawn_test_characters"):
#		#	pass
#		#else:
#		character_scene = player_character_scene.instantiate()
#		Logging.log_line("Spawning character for class id " + str(netcode.class_instance_id))
#	else:
#		if ProjectSettings.get_setting("global/rollback_enabled"):
#			character_scene = rollback_template.instantiate()
#		else:
#			character_scene = lag_comp_template.instantiate()
#		Logging.log_line("Spawning template for class id " + str(netcode.class_id))
#	character_scene.netcode.class_id = netcode.class_id
#	character_scene.netcode.class_instance_id = netcode.class_instance_id
#	_assign_player_id(character_scene, netcode.class_instance_id)
#	return character_scene

func _assign_player_id(character_scene, class_instance_id : int):
	for player_id in ObjectCreationRegistry.network_id_to_instance_id.keys():
		if class_instance_id == ObjectCreationRegistry.network_id_to_instance_id[player_id]:
			character_scene.player_id = player_id
			print("Setting player id to ", player_id)
