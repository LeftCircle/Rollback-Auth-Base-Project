extends BaseModuleData
class_name MeleeWeaponData

var attack_sequence = 0
var is_executing = false
var attack_direction : Vector2 = Vector2.ZERO
var animation_frame : int = 0
var is_in_parry = false
var stamina_check_occured : bool = false
var combo_to_occur : bool = false

func set_data_with_obj(other_obj): 
	attack_sequence = other_obj.attack_sequence
	is_executing = other_obj.is_executing
	attack_direction = other_obj.attack_direction
	animation_frame = other_obj.animation_frame
	is_in_parry = other_obj.is_in_parry
	stamina_check_occured = other_obj.stamina_check_occured
	combo_to_occur = other_obj.combo_to_occur
	frame = other_obj.frame

func set_obj_with_data(other_obj): 
	other_obj.attack_sequence = attack_sequence
	other_obj.is_executing = is_executing
	other_obj.attack_direction = attack_direction
	other_obj.animation_frame = animation_frame
	other_obj.is_in_parry = is_in_parry
	other_obj.stamina_check_occured = stamina_check_occured
	other_obj.combo_to_occur = combo_to_occur
	other_obj.frame = frame

func matches(other_obj) -> bool: 
	return (
	(ModularDataComparer.compare_values(attack_sequence, other_obj.attack_sequence) == true) and
	(ModularDataComparer.compare_values(is_executing, other_obj.is_executing) == true) and
	(ModularDataComparer.compare_values(attack_direction, other_obj.attack_direction) == true) and
	(ModularDataComparer.compare_values(animation_frame, other_obj.animation_frame) == true) and
	(ModularDataComparer.compare_values(is_in_parry, other_obj.is_in_parry) == true) and
	(ModularDataComparer.compare_values(stamina_check_occured, other_obj.stamina_check_occured) == true) and
	(ModularDataComparer.compare_values(combo_to_occur, other_obj.combo_to_occur) == true) and
	(ModularDataComparer.compare_values(frame, other_obj.frame) == true)
	)
