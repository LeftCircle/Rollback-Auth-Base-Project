extends RefCounted
class_name HitboxCombatEventParser

var entity
# This is the area of the hitbox that does the hitting
var colliding_area

func init(new_colliding_area, new_entity) -> void:
	entity = new_entity
	colliding_area = new_colliding_area

func on_area_entered(area, weapon_data):
	if "entity" in area:
		if area.entity != entity and not area.is_in_group("BaseHurtbox"):
			var event_type : int
			var combat_event = CombatEvent.new()
			if area.is_in_group("Hurtbox"):
				event_type = CombatEvent.HURTBOX_HIT
			elif area.is_in_group("PastCombatBox") and area.entity_frame_of_reference == entity:
				if area.is_in_group("Hitbox"):
					event_type = _get_event_type_on_Hitbox_hit(area, weapon_data)
				elif area.is_in_group("BlockBox"):
					print("Past blockbox hit")
					event_type = CombatEvent.BLOCK_BOX_HIT
				elif area.is_in_group("ParryBox"):
					print("Past parrybox hit")
					event_type = CombatEvent.SHIELD_PARRY_BOX_HIT
				else:
					return
			else:
				return
			combat_event.init(colliding_area, entity, area.entity, event_type)
			combat_event.weapon_data = weapon_data
#			if "weapon_data" in area:
#					combat_event.weapon_data_that_was_hit = area.weapon_data
			entity.combat_events.queue_event(combat_event)
	else:
		print("Collision area has no entity attribute. Nothing to be done " + area.to_string())

func _get_event_type_on_Hitbox_hit(area, weapon_data) -> int:
	if weapon_data.is_ranged == false:
		print("Melee past hitbox hit")
		return CombatEvent.MELEE_HITBOX_HIT
	assert(false) #,"frame of ref projectiles look for hitbox collisions, not the other way around")
	return -1
