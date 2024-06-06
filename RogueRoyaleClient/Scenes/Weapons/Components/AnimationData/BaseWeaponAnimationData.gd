extends Resource
class_name BaseWeaponAnimationData

enum ATTACK_END{COMBO_PRIMARY, COMBO_SECONDARY, COMBO_RANGED, CHARGE_PRIMARY, END, NONE}

@export var max_sequence: int = 0 #: set = set_max_sequence
@export var attack_sequence: int = 0
@export var speed_mod: float = 1.0
@export var main_animation_ended: bool = false
@export var in_anticipation: bool = false
@export var attack_direction: Vector2 = Vector2.ZERO
@export var damage_mod: float = 1.0
@export var knockback_mod: float = 1.0
@export var stamina_cost: int = 1

var entity
var queued_input = QueuedInput.new()

# These are some things that the base weapon has that I'm not entirely sure if they are best stuck in here or not
var animation_frame : int = 0
var execution_frame : int = 0
var is_executing : bool = false
var is_in_parry : bool = false
var animation : String = ""
var frame_end_result : int = ATTACK_END.NONE

var animation_player : AnimationPlayer
var stamina
var move

func reset(reset_sequence = true):
	if reset_sequence:
		attack_sequence = 0
	damage_mod = 1.0
	knockback_mod = 1.0
	stamina_cost = 1
	queued_input.reset()
	animation_frame = 0

func get_charging_sequence():
	return max_sequence + 1

func get_charge_attack_sequence():
	return max_sequence + 2

func get_combo_sequence():
	return max_sequence + 3
