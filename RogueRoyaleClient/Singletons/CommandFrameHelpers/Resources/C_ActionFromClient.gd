extends RefCounted
class_name ActionFromClient

const DECIMAL_PRECISION : Vector2 = Vector2(0.001, 0.001)
const OTHER_ACTIONS = {
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

var action_data = ActionData.new()
var is_from_client : bool = false

# NOTE -> IF THESE CHANGE THEN WE NEED TO UPDATE RESET()
var bitmap_bits = 9

var frame = 0
# Could be tracked with FrameLoopingArray
var previous_looking_vector = Vector2.ZERO

func track_inputs(entity):
	var raw_input_vec = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var quantized_vec = InputVecQuantizer.quantize_vec(raw_input_vec)
	action_data.input_vector = quantized_vec
	_calculate_looking_vector(action_data, entity)
	action_data.dodge = Input.is_action_pressed("dodge")
	action_data.dash = Input.is_action_pressed("dash")
	action_data.attack_primary = Input.is_action_pressed("attack_primary")
	action_data.attack_secondary = Input.is_action_pressed("attack_secondary")
	action_data.draw_ranged_weapon = Input.is_action_pressed("draw_ranged_weapon")
	action_data.fire_ranged_weapon = Input.is_action_pressed("fire_ranged_weapon")
	action_data.health_flask = Input.is_action_pressed("health_flask")
	action_data.special_1 = Input.is_action_pressed("special_1")
	action_data.special_2 =  Input.is_action_pressed("special_2")

func random_input(just_attack : bool = false):
	#var just_attack = true
	if just_attack:
		#action_data.draw_ranged_weapon = true
		action_data.attack_primary = CommandFrame.frame % 60 == 0
		#if randf() < 0.025:
		#	action_data.input_vector = Vector2.LEFT if randf() < 0.5 else Vector2.RIGHT
		#	action_data.looking_vector = Vector2(rand_from_neg_one_to_one(), rand_from_neg_one_to_one()).normalized()
		#	action_data.input_vector = Vector2(rand_from_neg_one_to_one(), rand_from_neg_one_to_one()).normalized()
	else:
		if randf() < 0.025:
			action_data.input_vector = Vector2(rand_from_neg_one_to_one(), rand_from_neg_one_to_one()).normalized()
			action_data.input_vector = InputVecQuantizer.quantize_vec(action_data.input_vector)
			action_data.looking_vector = Vector2(rand_from_neg_one_to_one(), rand_from_neg_one_to_one()).normalized()
			action_data.dodge = randf() < 0.01
			action_data.dash = randf() < 0.01
			action_data.attack_primary = randf() < 0.5
			action_data.attack_secondary = randf() < 0.01
			action_data.draw_ranged_weapon = randf() < 0.01
			action_data.fire_ranged_weapon = randf() < 0.01
			action_data.health_flask = randf() < 0.01
			action_data.special_1 = randf() < 0.01
			action_data.special_2 =  randf() < 0.01

func rand_from_neg_one_to_one():
	return 1 - 2 * randf()

func _calculate_looking_vector(actionData : ActionData, entity) -> void:
	if Input.get_mouse_mode() == Input.MOUSE_MODE_HIDDEN:
		# A controller is connected!
		if actionData.input_vector == Vector2.ZERO:
			actionData.looking_vector = previous_looking_vector
		else:
			actionData.looking_vector = actionData.input_vector
	else:
		var dir_to_mouse : Vector2 = entity.global_position.direction_to(entity.get_global_mouse_position())
		var snapped_dir = dir_to_mouse.snapped(DECIMAL_PRECISION)
		actionData.looking_vector = snapped_dir

	previous_looking_vector = actionData.looking_vector

func get_input_vector():
	return action_data.input_vector

func set_input_vector(new_vec : Vector2):
	action_data.input_vector = new_vec

func get_looking_vector():
	return action_data.looking_vector

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

#func matches_action(other_action : ActionFromClient) -> bool:
#	if action_dict.size() != other_action.action_dict.size():
#		return false
#	if action_dict.is_empty() and other_action.action_dict.is_empty():
#		return true
#	var nonvector_actions = OTHER_ACTIONS.keys()
#	for action in VECTOR_ACTIONS:
#		if not vectors_match(action_dict[action], other_action.action_dict[action], 0.25):
#			return false
#	for action in nonvector_actions:
#		if action_dict[action] != other_action.action_dict[action]:
#			return false
#	return true

func vectors_match(vector1, vector2, threshold = 0.1) -> bool:
	var matches =  (vector1 - vector2).length_squared() < threshold
	if matches:
		return true
	else:
		Logging.log_line("Vectors do not match. length squared = " + str((vector1 - vector2).length_squared()))
		return false

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
