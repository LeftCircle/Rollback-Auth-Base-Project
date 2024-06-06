extends BaseHitbox
class_name SoftHitbox
# Like the base hitbox, except instead of parrying another attack, this attack is
# just canceled


func on_area_entered(area, weapon_data):
	if "entity" in area:
		if area.entity != entity:
			var event_type : int
			var combat_event = CombatEvent.new()
			if area.is_in_group("Hurtbox"):
				event_type = _get_event_type_on_Hurtbox_hit(weapon_data)
			elif area.is_in_group("Hitbox"):
				event_type = _get_event_type_on_Hitbox_hit(area, weapon_data)
			elif area.is_in_group("BlockBox"):
				event_type = CombatEvent.BLOCK_BOX_HIT
			elif area.is_in_group("ParryBox"):
				event_type = CombatEvent.SHIELD_PARRY_BOX_HIT
			combat_event.init(entity, area.entity, event_type)
			combat_event.weapon_data = weapon_data
			if "weapon_data" in area:
					combat_event.weapon_data_that_was_hit = area.weapon_data
			entity.combat_events.queue_event(combat_event)
	else:
		print("Collision area has no entity attribute. Nothing to be done " + area.to_string())
