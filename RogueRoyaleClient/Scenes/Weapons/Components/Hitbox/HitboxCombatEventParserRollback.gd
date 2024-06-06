extends RefCounted
class_name HitboxCombatEventParserRollback

# This is the area of the hitbox that does the hitting
var obj_that_hits

func init(new_obj_that_hits) -> void:
	obj_that_hits = new_obj_that_hits

func on_area_entered(area, weapon_data):
	if "entity" in area:
		if area.entity != obj_that_hits.entity:
			if area.entity.is_in_group("Players"):
				_on_player_hit(area, weapon_data)
			else:
				print("Hitting mobs not yet implemented")
				return
	else:
		print("Collision area has no entity attribute. Nothing to be done " + area.to_string())

func _on_player_hit(area, weapon_data) -> void:
	var event_type : int
	var combat_event = CombatEvent.new()
	if not area.is_in_group("Rollback"):
		return
	elif area.is_in_group("Hurtbox"):
		event_type = CombatEvent.HURTBOX_HIT
	elif area.is_in_group("Hitbox"):
		event_type = _get_event_type_on_Hitbox_hit(area, weapon_data)
	elif area.is_in_group("BlockBox"):
		print("Past blockbox hit")
		event_type = CombatEvent.BLOCK_BOX_HIT
	elif area.is_in_group("ParryBox"):
		print("Past parrybox hit")
		event_type = CombatEvent.SHIELD_PARRY_BOX_HIT
	else:
		return
	combat_event.init(obj_that_hits, obj_that_hits.entity, area.entity, event_type)
	combat_event.weapon_data = weapon_data
#			if "weapon_data" in area:
#					combat_event.weapon_data_that_was_hit = area.weapon_data
	obj_that_hits.entity.combat_events.queue_event(combat_event)

func _get_event_type_on_Hitbox_hit(area, weapon_data) -> int:
	if weapon_data.is_ranged == false:
		return CombatEvent.MELEE_HITBOX_HIT
	else:
		return CombatEvent.RANGE_HITBOX_HIT
