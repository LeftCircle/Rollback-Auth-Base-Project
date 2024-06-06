@tool
extends Node
class_name WeaponData

enum EQUIP_TYPES{PRIMARY, SECONDARY, RANGED}
enum PHYSICAL_HIT_EFFECTS{NONE, STUN, KNOCKBACK}
enum ATTACK_END{PRIMARY, COMBO_PRIMARY, SECONDARY, COMBO_SECONDARY, RANGED,
				COMBO_RANGED, SPECIAL_1, SPECIAL_2, HEAL, DASH, END, DODGE, NONE}

@export var is_ranged: bool = false
@export var two_handed: bool = false
@export var equip_type: EQUIP_TYPES = EQUIP_TYPES.PRIMARY
@export var class_type = "dps" # (String, "dps", "tank", "support")
@export var base_damage = 1 # (int, 0, 1000)
@export var physical_hit_effect: PHYSICAL_HIT_EFFECTS = PHYSICAL_HIT_EFFECTS.NONE
@export var stun_type = 0 # (int, 0, 2)
@export var knockback_speed = 250 # (int, 0, 1000)
@export var knockback_decay = 1000 # (int, 0, 1000)
@export var stamina_cost: int = 1
@export var charge_stamina_cost: int = 1
@export var combo_stamina_cost: int = 1

# Animation Data (These are still export because of advanced exports)

var max_sequence : int
var attack_sequence : int
var speed_mod = 1.0
var main_animation_ended : bool
var is_looping : bool = false
var damage_mod : float
var knockback_mod : float

var entity

# Required for netcode
var attack_direction : Vector2
var animation_frame : int = 0
var previous_attack_sequence : int = 0
var is_in_parry : bool = false
var is_executing : bool = false
var stamina_check_occured : bool = false
var frame : int
var combo_to_occur : bool = false

# Update logic for the weapon to play animations
var animation : String = ""
var attack_end : int = ATTACK_END.NONE
var input_to_check : String

func reset(reset_sequence = true):
	if reset_sequence:
		attack_sequence = 0
	damage_mod = 1.0
	knockback_mod = 1.0
	animation_frame = 0
	stamina_check_occured = false
	is_in_parry = false
	is_looping = false
	combo_to_occur = false

func soft_reset():
	damage_mod = 1.0
	knockback_mod = 1.0
	animation_frame = 0
	stamina_check_occured = false
	is_in_parry = false
	is_looping = false

func hard_reset():
	reset()
	is_executing = false

func get_charging_sequence():
	return max_sequence + 1

func get_charge_attack_sequence():
	return max_sequence + 2

func get_combo_sequence():
	return max_sequence + 3

func _get_property_list():
	var properties = []
	properties.append({
		name = "AnimationData",
		type = TYPE_NIL,
		usage = PROPERTY_USAGE_CATEGORY | PROPERTY_USAGE_SCRIPT_VARIABLE
	})
	properties.append({
		name = "max_sequence",
		type = TYPE_INT
	})
	properties.append({
		name = "attack_sequence",
		type = TYPE_INT
	})
	properties.append({
		name = "speed_mod",
		type = TYPE_FLOAT
	})
	properties.append({
		name = "main_animation_ended",
		type = TYPE_BOOL
	})
#	properties.append({
#		name = "in_anticipation",
#		type = TYPE_BOOL
#	})
	properties.append({
		name = "is_looping",
		type = TYPE_BOOL
	})
#	properties.append({
#		name = "attack_direction",
#		type = TYPE_VECTOR2
#	})
	properties.append({
		name = "damage_mod",
		type = TYPE_FLOAT
	})
	properties.append({
		name = "knockback_mod",
		type = TYPE_FLOAT
	})
	return properties

func is_attack_end_a_combo() -> bool:
	return (attack_end == ATTACK_END.COMBO_PRIMARY or attack_end == ATTACK_END.COMBO_SECONDARY or attack_end == ATTACK_END.COMBO_RANGED)
