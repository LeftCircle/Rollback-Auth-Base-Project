extends RefCounted
class_name ActionFromClient

var action_data = ActionData.new()

var frame : int = 0
var is_from_client : bool = false

var OTHER_ACTIONS = {
	"dash" : 0,
	"dodge" : 1,
	"attack_primary" : 2,
	"attack_secondary" : 3,
	"draw_ranged_weapon" : 4,
	"fire_ranged_weapon" : 5,
	"health_flask" : 6,
	"special_1" : 7,
	"special_2" : 8
}
var bitmap_bits = 9

func get_input_vector():
	return action_data.input_vector

func set_input_vector(new_vec : Vector2):
	action_data.input_vector = new_vec

func get_looking_vector():
	return action_data.looking_vector

func set_looking_vector(direction : Vector2):
	action_data.looking_vector = direction

func reset():
	action_data.input_vector = Vector2.ZERO
	action_data.looking_vector = Vector2.ZERO
	action_data.dodge = false
	action_data.dash = false
	action_data.attack_primary = false
	action_data.attack_secondary = false
	action_data.draw_ranged_weapon = false
	action_data.fire_ranged_weapon = false
	action_data.health_flask = false
	action_data.special_1 = false
	action_data.special_2 = false

func duplicate(other_actions : ActionFromClient):
	action_data.set_data_with_obj(other_actions.action_data)

func action_is_flagged(compressed_actions : int, action : String) -> bool:
	var binary_rep = get_action_binary_rep(action)
	return (compressed_actions & binary_rep) != 0

func get_action_binary_rep(action_str : String) -> int:
	return 1 << OTHER_ACTIONS[action_str]

func is_action_pressed(action : String) -> bool:
	return action_data.get(action)

func has_actions() -> bool:
	return (
		action_data.attack_primary or action_data.attack_secondary or
		action_data.draw_ranged_weapon or action_data.fire_ranged_weapon or action_data.health_flask or
		action_data.special_1 or action_data.special_2 or action_data.dash or action_data.dodge
	)

func get_action_bitmap() -> int:
	var bitfield_int = 0
	bitfield_int = bitfield_int | (get_action_binary_rep("attack_primary") * int(action_data.attack_primary))
	bitfield_int = bitfield_int | (get_action_binary_rep("attack_secondary") * int(action_data.attack_secondary))
	bitfield_int = bitfield_int | (get_action_binary_rep("draw_ranged_weapon") * int(action_data.draw_ranged_weapon))
	bitfield_int = bitfield_int | (get_action_binary_rep("fire_ranged_weapon") * int(action_data.fire_ranged_weapon))
	bitfield_int = bitfield_int | (get_action_binary_rep("health_flask") * int(action_data.health_flask))
	bitfield_int = bitfield_int | (get_action_binary_rep("special_1") * int(action_data.special_1))
	bitfield_int = bitfield_int | (get_action_binary_rep("special_2") * int(action_data.special_2))
	bitfield_int = bitfield_int | (get_action_binary_rep("dash") * int(action_data.dash))
	bitfield_int = bitfield_int | (get_action_binary_rep("dodge") * int(action_data.dodge))
	return bitfield_int

func set_actions_from_bitmap_int(bitmap_int : int) -> void:
	action_data.attack_primary = (get_action_binary_rep("attack_primary") & bitmap_int) != 0
	action_data.attack_secondary = (get_action_binary_rep("attack_secondary") & bitmap_int) != 0
	action_data.draw_ranged_weapon = (get_action_binary_rep("draw_ranged_weapon") & bitmap_int) != 0
	action_data.fire_ranged_weapon = (get_action_binary_rep("fire_ranged_weapon") & bitmap_int) != 0
	action_data.health_flask = (get_action_binary_rep("health_flask") & bitmap_int) != 0
	action_data.special_1 = (get_action_binary_rep("special_1") & bitmap_int) != 0
	action_data.special_2 = (get_action_binary_rep("special_2") & bitmap_int) != 0
	action_data.dash = (get_action_binary_rep("dash") & bitmap_int) != 0
	action_data.dodge = (get_action_binary_rep("dodge") & bitmap_int) != 0

func log_action():
	var bitmap_int = get_action_bitmap()
	Logging.log_line("Looking vec = " + str(action_data.looking_vector) + " iv = " + str(action_data.input_vector) +
	" bitmap = " + str(bitmap_int) + " has actions = " + str(bitmap_int != 0))
