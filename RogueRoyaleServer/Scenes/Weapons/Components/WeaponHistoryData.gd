extends Resource
class_name WeaponHistoryData

var player_speed = 0
var frames_since_attack = 0
var attack_sequence = 0
var is_executing = false
var attack_direction : Vector2 = Vector2.ZERO

func set_data(weapon_node) -> void:
	player_speed = weapon_node.player_speed
	frames_since_attack = weapon_node.frames_since_attack
	attack_sequence = weapon_node.attack_sequence
	is_executing = weapon_node.is_executing
	attack_direction = weapon_node.attack_direction

func copy_data(other_data) -> void:
	player_speed = other_data.player_speed
	frames_since_attack = other_data.frames_since_attack
	attack_sequence = other_data.attack_sequence
	attack_direction = other_data.attack_direction
	is_executing = other_data.is_executing

func log_data():
	Logging.log_line("WeaponData: PS = " + str(player_speed) + " FSA = " + str(frames_since_attack) +
	" AS = " + str(attack_sequence) + " Executing = " + str(is_executing) + " AD = " + str(attack_direction))
