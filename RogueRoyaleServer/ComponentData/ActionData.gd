extends RefCounted
class_name ActionData

var input_vector = Vector2.ZERO
var looking_vector = Vector2.ZERO
var attack_primary : bool = false
var attack_secondary : bool = false
var draw_ranged_weapon : bool = false
var fire_ranged_weapon : bool = false
var health_flask : bool = false
var special_1 : bool = false
var special_2 : bool = false
var dash : bool = false
var dodge : bool = false

func set_data_with_obj(other_obj):
	input_vector = other_obj.input_vector
	looking_vector = other_obj.looking_vector
	attack_primary = other_obj.attack_primary
	attack_secondary = other_obj.attack_secondary
	draw_ranged_weapon = other_obj.draw_ranged_weapon
	fire_ranged_weapon = other_obj.fire_ranged_weapon
	health_flask = other_obj.health_flask
	special_1 = other_obj.special_1
	special_2 = other_obj.special_2
	dash = other_obj.dash
	dodge = other_obj.dodge

func set_obj_with_data(other_obj):
	other_obj.input_vector = input_vector
	other_obj.looking_vector = looking_vector
	other_obj.attack_primary = attack_primary
	other_obj.attack_secondary = attack_secondary
	other_obj.draw_ranged_weapon = draw_ranged_weapon
	other_obj.fire_ranged_weapon = fire_ranged_weapon
	other_obj.health_flask = health_flask
	other_obj.special_1 = special_1
	other_obj.special_2 = special_2
	other_obj.dash = dash
	other_obj.dodge = dodge

func matches(other_obj) -> bool:
	return (
	(ModularDataComparer.compare_values(input_vector, other_obj.input_vector) == true) and
	(ModularDataComparer.compare_values(looking_vector, other_obj.looking_vector) == true) and
	(ModularDataComparer.compare_values(attack_primary, other_obj.attack_primary) == true) and
	(ModularDataComparer.compare_values(attack_secondary, other_obj.attack_secondary) == true) and
	(ModularDataComparer.compare_values(draw_ranged_weapon, other_obj.draw_ranged_weapon) == true) and
	(ModularDataComparer.compare_values(fire_ranged_weapon, other_obj.fire_ranged_weapon) == true) and
	(ModularDataComparer.compare_values(health_flask, other_obj.health_flask) == true) and
	(ModularDataComparer.compare_values(special_1, other_obj.special_1) == true) and
	(ModularDataComparer.compare_values(special_2, other_obj.special_2) == true) and
	(ModularDataComparer.compare_values(dash, other_obj.dash) == true) and
	(ModularDataComparer.compare_values(dodge, other_obj.dodge) == true)
	)
