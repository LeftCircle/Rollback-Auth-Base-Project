extends Node
class_name PlayerCharacterLoader

@export var player_template_scene: PackedScene
@export var player_character_scene: PackedScene

var unclaimed_templates = []
var unclaimed_character = []

func _ready():
	#print("Player character ready")
	for _i in range(39):
		unclaimed_templates.append(player_template_scene.instantiate())
	unclaimed_character.append(player_character_scene.instantiate())
	#print("Player character ready is finished")

func _exit_tree():
	if not unclaimed_character.is_empty():
		if is_instance_valid(unclaimed_character[0]):
			unclaimed_character[0].queue_free()
	for template in unclaimed_templates:
		if is_instance_valid(template):
			template.queue_free()

func get_character(class_instance_id : int):
	Logging.log_line("Character spawner called")
	var character_scene
	if class_instance_id == ObjectCreationRegistry.client_character_class_instance_id:
		character_scene = unclaimed_character.pop_back()
		print("Spawning character")
		Logging.log_line("Spawning character for class instance id " + str(class_instance_id))
	else:
		#if ProjectSettings.get_setting("global/rollback_enabled"):
		character_scene = unclaimed_templates.pop_back()
#		else:
#			character_scene = lag_comp_template.instantiate()
		print("Spawning template")
		Logging.log_line("Spawning template for class instance id " + str(class_instance_id))
	character_scene.netcode.class_id = "CHR"
	character_scene.netcode.class_instance_id = class_instance_id
	_assign_player_id(character_scene, class_instance_id)
	return character_scene

func _assign_player_id(character_scene, class_instance_id : int):
	for player_id in ObjectCreationRegistry.network_id_to_instance_id.keys():
		if class_instance_id == ObjectCreationRegistry.network_id_to_instance_id[player_id]:
			character_scene.player_id = player_id
			print("Setting player id to ", player_id)
