extends MeleeWeaponData
class_name StarterShieldData

var state : int
var just_raised : bool

func set_data_with_obj(other_obj): 
	state = other_obj.state
	just_raised = other_obj.just_raised
	attack_sequence = other_obj.attack_sequence
	is_executing = other_obj.is_executing
	attack_direction = other_obj.attack_direction
	animation_frame = other_obj.animation_frame
	is_in_parry = other_obj.is_in_parry
	stamina_check_occured = other_obj.stamina_check_occured
	combo_to_occur = other_obj.combo_to_occur
	frame = other_obj.frame

func set_obj_with_data(other_obj): 
	other_obj.state = state
	other_obj.just_raised = just_raised
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
	(ModularDataComparer.compare_values(state, other_obj.state) == true) and
	(ModularDataComparer.compare_values(just_raised, other_obj.just_raised) == true) and
	(ModularDataComparer.compare_values(attack_sequence, other_obj.attack_sequence) == true) and
	(ModularDataComparer.compare_values(is_executing, other_obj.is_executing) == true) and
	(ModularDataComparer.compare_values(attack_direction, other_obj.attack_direction) == true) and
	(ModularDataComparer.compare_values(animation_frame, other_obj.animation_frame) == true) and
	(ModularDataComparer.compare_values(is_in_parry, other_obj.is_in_parry) == true) and
	(ModularDataComparer.compare_values(stamina_check_occured, other_obj.stamina_check_occured) == true) and
	(ModularDataComparer.compare_values(combo_to_occur, other_obj.combo_to_occur) == true) and
	(ModularDataComparer.compare_values(frame, other_obj.frame) == true)
	)
