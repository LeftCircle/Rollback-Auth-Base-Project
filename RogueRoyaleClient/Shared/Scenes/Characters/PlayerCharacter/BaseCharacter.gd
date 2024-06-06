extends KinematicEntity
class_name BaseCharacter
# This is the base character that the Server and Client Character will derive from

signal damaged(frame, amount)
signal landed_melee_attack(frame)

# The player_id is the netcode_id for that player
var player_id : int
var inputs = ActionFromClient.new()
#var animation_transitions = PlayerAnimationTransitions.new()

@onready var primary_weapon# = $Components/Dagger
@onready var ranged_weapon# = $Components/Pistol
@onready var secondary_weapon# = $Components/StarterShield

@onready var dash# = $Components/Dash
@onready var move# = $Components/Move
@onready var stamina# = $Components/ClientStamina
@onready var health# = $Components/BaseHealth
@onready var ammo# = $Components/AmmoBase
@onready var healing_flask# = $Components/Healing
@onready var knockback# = $Components/Knockback
@onready var input_queue# = $Components/InputQueue

@onready var animations = $AnimationPlayer
@onready var hurtbox = $PlayerHurtbox
@onready var animation_tree : LocalRollbackAnimationTree = $LocalRollbackAnimationTree

func _ready():
	super._ready()
	add_to_group("Players")

func add_weapon(frame : int, new_weapon, add_to_components = true):
	var equip_type = new_weapon.weapon_data.equip_type
	if equip_type == WeaponData.EQUIP_TYPES.PRIMARY:
		if primary_weapon != new_weapon and is_instance_valid(primary_weapon):
			components.remove_component(primary_weapon)
		primary_weapon = new_weapon
		primary_weapon.init(self, stamina, move, true)
	elif equip_type == WeaponData.EQUIP_TYPES.SECONDARY:
		if secondary_weapon != new_weapon and is_instance_valid(secondary_weapon):
			components.remove_component(secondary_weapon)
		secondary_weapon = new_weapon
		secondary_weapon.init(self, stamina, move, false)
	elif equip_type == WeaponData.EQUIP_TYPES.RANGED:
		if ranged_weapon != new_weapon and is_instance_valid(ranged_weapon):
			components.remove_component(ranged_weapon)
		ranged_weapon = new_weapon
		ranged_weapon.init(frame, self, get_component("Ammo"))
	if add_to_components:
		add_component(frame, new_weapon)

func get_input_queue_data() -> InputQueueData:
	return get_component("InputQueue").data_container

func _set_state_from_physical_hit_effect(frame : int, weapon_data : WeaponData, dir_to_entity : Vector2) -> void:
	if weapon_data.physical_hit_effect == WeaponData.PHYSICAL_HIT_EFFECTS.STUN:
		print("Stun state not yet implemented for " + self.to_string())
	elif weapon_data.physical_hit_effect == WeaponData.PHYSICAL_HIT_EFFECTS.KNOCKBACK:
		var new_knockback = C_Knockback.new()
		new_knockback.set_data(-dir_to_entity, weapon_data.knockback_speed, weapon_data.knockback_decay)
		add_component(frame, new_knockback)

################################################################################
### KinematicEntity functions
###############################################################################

func on_attack_hit_entity(frame : int, event : CombatEvent, was_blocked = false) -> void:
	assert(event.entity_did_event == self) #,"debug")
	emit_signal("landed_melee_attack", CommandFrame.frame)
	super.on_attack_hit_entity(frame, event, was_blocked)

func on_range_attack_hit_entity(frame : int, event : CombatEvent) -> void:
	assert(event.entity_did_event == self) #,"debug")
	var damage = damage_calculator.get_damage(event.weapon_data)
	event.entity_received_event.on_hurtbox_hit_by(event, damage)

func on_hurtbox_hit_by(frame : int, event : CombatEvent, damage : int) -> void:
	assert(event.entity_did_event != self) #,"debug")
	var dir_to_entity = global_position.direction_to(event.entity_did_event.global_position)
	dir_to_entity.x = round(dir_to_entity.x * 10) / 10
	dir_to_entity.y = round(dir_to_entity.y * 10) / 10
	emit_signal("damaged", CommandFrame.frame, damage)
	_set_state_from_physical_hit_effect(frame, event.weapon_data, dir_to_entity)

func on_melee_hitbox_hit(event : CombatEvent):
	event.object_did_event.on_parry(CommandFrame.frame)

func on_projectile_hit_by_melee(event : CombatEvent) -> void:
	get_component("Ammo").refill_ammo(CommandFrame.frame)

