extends RefCounted
class_name CombatEvent

enum {
	NONE,
	HURTBOX_HIT,
	RANGE_HITBOX_HIT,
	SOFT_MELEE_HITBOX_HIT,
	HARD_MELEE_HITBOX_HIT,
	MELEE_HITBOX_HIT,
	BLOCK_BOX_HIT,
	SHIELD_PARRY_BOX_HIT,
	N_ENUMS
}

var weapon_data : WeaponData
# For collisions, the entity that hits is the entity that did the event
var entity_did_event
# For collisions, the entity that is hit is the entity that receives the event
var entity_received_event
var type : int
var weapon_data_that_was_hit : WeaponData
# These should point back to the weapon/projectile that did the event
var object_did_event

# Could pass a funcref to execute if it actually occurs
func init(object_that_did, entity_that_did, against_entity, event_type : int):
	object_did_event = object_that_did
	entity_did_event = entity_that_did
	entity_received_event = against_entity
	type = event_type

func set_to_none():
	type = NONE

func event_to_string():
	if type == HURTBOX_HIT:
		return "HURTBOX_HIT"
	elif type == RANGE_HITBOX_HIT:
		return "RANGE_HITBOX_HIT"
	elif type == MELEE_HITBOX_HIT:
		return "MELEE_HITBOX_HIT"
	elif type == BLOCK_BOX_HIT:
		return "BLOCK_BOX_HIT"
	elif type == SHIELD_PARRY_BOX_HIT:
		return "SHIELD_PARRY_BOX_HIT"
#	elif type == BLOCK:
#		return "BLOCK"
#	elif type == PARRY:
#		return "PARRY"
#	elif type == SHIELD_PARRY:
#		return "SHIELD_PARRY"
	else:
		return "UNKNOWN"
