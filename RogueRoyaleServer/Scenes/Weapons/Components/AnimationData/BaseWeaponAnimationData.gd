extends Resource
class_name BaseWeaponAnimationData

@export var max_sequence: int
@export var attack_sequqnce: int
@export var speed_mod: float
@export var main_animation_ended: bool = false
@export var is_finisher: bool = false
@export var attack_direction: Vector2

var entity
var queued_input : ActionData
