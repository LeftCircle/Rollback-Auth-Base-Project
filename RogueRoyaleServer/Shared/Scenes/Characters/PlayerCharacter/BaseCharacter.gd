#################################################
######   SHARED BETWEEN CLIENT AND SERVER   #####
#################################################
extends KinematicEntity
class_name BaseCharacter
# This is the base character that the Server and Client Character will derive from

signal damaged(frame, amount)
signal landed_melee_attack(frame)

@export var attack_primary_state_path: NodePath
@export var attack_secondary_state_path: NodePath
@export var ranged_weapon_state_path: NodePath

# The player_id is the netcode_id for that player
var player_id : int
var inputs = ActionFromClient.new()
#var animation_transitions = PlayerAnimationTransitions.new()

@onready var primary_weapon #= $Components/Dagger
@onready var ranged_weapon #= $Components/Pistol
@onready var secondary_weapon #= $Components/StarterShield

@onready var dash = $Components/Dash
@onready var move = $Components/Move
@onready var stamina = $Components/BaseStamina
@onready var health = $Components/BaseHealth
@onready var ammo = $Components/AmmoBase
@onready var healing_flask = $Components/Healing
@onready var knockback = $Components/Knockback
@onready var input_queue = $Components/InputQueue

@onready var animations = $AnimationPlayer
@onready var hurtbox = $PlayerHurtbox
@onready var animation_tree : RollbackAnimationTree = $AnimationTree

func _ready():
	super._ready()
	add_to_group("Players")

func add_weapon(frame : int, new_weapon, add_to_components = true):
	var equip_type = new_weapon.weapon_data.equip_type
	if equip_type == WeaponData.EQUIP_TYPES.PRIMARY:
		if primary_weapon != new_weapon and is_instance_valid(primary_weapon):
			components.remove_component(frame, primary_weapon)
		primary_weapon = new_weapon
		primary_weapon.init(self, stamina, move, true)
	elif equip_type == WeaponData.EQUIP_TYPES.SECONDARY:
		if secondary_weapon != new_weapon and is_instance_valid(secondary_weapon):
			components.remove_component(frame, secondary_weapon)
		secondary_weapon = new_weapon
		secondary_weapon.init(self, stamina, move, false)
	elif equip_type == WeaponData.EQUIP_TYPES.RANGED:
		if ranged_weapon != new_weapon and is_instance_valid(ranged_weapon):
			components.remove_component(frame, ranged_weapon)
		ranged_weapon = new_weapon
		ranged_weapon.init(frame, self, get_component("Ammo"))
	if add_to_components:
		add_component(frame, new_weapon)

func get_input_queue_data() -> InputQueueData:
	return input_queue.data_container

